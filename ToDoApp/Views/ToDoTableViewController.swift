//
//  ToDoTableViewController.swift
//  ToDoApp
//
//  Created by Laura Evans on 1/21/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ToDoTableViewController: UITableViewController {
    
    var todoItems: [TodoItem]! {
        didSet {
            self.progressBar.setProgress(progress, animated: true)
        }
    }
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var connectionButtonReference: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var progress: Float {
        if todoItems.count > 0 {
            return Float(todoItems.filter({$0.completed}).count) / Float(todoItems.count)
        } else {
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setUpConnectivity()
    }
    
    func loadData() {
        todoItems = [TodoItem]()
        todoItems = DataManager.loadAll(TodoItem.self).sorted(by: {
            $0.createdAt < $1.createdAt
        })
        tableView.reloadData()
    }
    
    func setUpConnectivity() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    func showConnectivityAction() {
        let actionSheet = UIAlertController(title: "Todo Exchange", message: "Do you want to host or join a session?", preferredStyle: .actionSheet)
        
        let hostAction = UIAlertAction(title: "Host Action", style: .default) { (action) in
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
        }
        
        let joinAction = UIAlertAction(title: "Join Action", style: .default) { (action) in
            let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(hostAction)
        actionSheet.addAction(joinAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showAddTodoAlert() {
        let addAlert = UIAlertController(title: "New Todo", message: "Enter a title", preferredStyle: .alert)
        addAlert.addTextField { (textField) in
            textField.placeholder = "Todo Item Title"
        }
        
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            guard let title = addAlert.textFields?.first?.text else { return }
            self.addNewTodo(title: title)
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(addAlert, animated: true, completion: nil)
    }
    
    func addNewTodo(title: String) {
        let todo = TodoItem(title: title, completed: false, createdAt: Date(), itemIdentifier: UUID())
        todo.saveItem()
        
        self.todoItems.append(todo)
        let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ToDoTableViewCell
        
        let todoItem = todoItems[indexPath.row]
        
        if todoItem.completed {
            cell.todoLabel.attributedText = cell.strikeThroughText(todoItem.title)
        } else {
            cell.todoLabel.text = todoItem.title
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completeTodoItem(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let shareAction = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            let todoItem = self.todoItems[indexPath.row]
            self.sendTodo(todoItem)
        }
        shareAction.backgroundColor = UIColor(named: "mainBlueColor")
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.todoItems[indexPath.row].deleteItem()
            self.todoItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = UIColor(named: "mainYellowColor")
        
        return [shareAction, deleteAction]
        
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ToDoTableViewController {
    
    func completeTodoItem(indexPath: IndexPath) {
        var todoItem = todoItems[indexPath.row]
        todoItem.markAsCompleted()
        todoItems[indexPath.row] = todoItem // need to update the object since it's a struct (value type) and not a class (reference type)
        
        guard let cell = tableView.cellForRow(at:  indexPath) as? ToDoTableViewCell else { return }
        
        // change style of label and animate
        cell.todoLabel.attributedText = cell.strikeThroughText(todoItem.title)

        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = cell.transform.scaledBy(x: 1.5, y: 1.5)
        }) { (_) in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
        }
        
    }
    
    func sendTodo(_ todoItem: TodoItem) {
        if mcSession.connectedPeers.count < 1 {
            showConnectivityAction()
            return
        }
        
        if let todoData = DataManager.loadData(todoItem.itemIdentifier.uuidString) {
            do {
                try mcSession.send(todoData, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                fatalError("could not send todo item")
            }
        }
    }
}

extension ToDoTableViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        var stateText: String?
        
        switch state {
        case .connected:
            stateText = "Connected"
        case .connecting:
            stateText = "Connecting"
        case .notConnected:
            stateText = "Not Connected"
        }
        
        if let text = stateText {
            DispatchQueue.main.async {
                self.connectionButtonReference.setTitle(text, for: .normal)
            }
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            let todoItem = try JSONDecoder().decode(TodoItem.self, from: data)
            DataManager.save(todoItem, with: todoItem.itemIdentifier.uuidString)
            DispatchQueue.main.async {
                self.loadData()
            }
        } catch {
            fatalError("unable to process the received data")
        }
        
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}

extension ToDoTableViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
