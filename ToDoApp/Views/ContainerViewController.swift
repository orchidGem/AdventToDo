//
//  ContainerViewController.swift
//  ToDoApp
//
//  Created by Laura Evans on 1/23/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var connectionButtion: UIButton!
    @IBOutlet weak var addButton: UIButton!

    var todoTableViewController: ToDoTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "ToDoVC" {
            return
        }
        
        todoTableViewController = (segue.destination as! UINavigationController).childViewControllers.first as! ToDoTableViewController
        
        todoTableViewController.connectionButtonReference = connectionButtion
        
    }
    
    @IBAction func addNewTodoItem(_ sender: Any) {
        todoTableViewController.showAddTodoAlert()
    }
    
    @IBAction func triggerConnection(_ sender: Any) {
        todoTableViewController.showConnectivityAction()
    }

}
