//
//  ToDoTableViewCell.swift
//  ToDoApp
//
//  Created by Laura Evans on 1/21/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit

protocol TodoCellDelegate {
    func didRequestDelete( cell: ToDoTableViewCell)
    func didRequestComplete( cell: ToDoTableViewCell )
    func didRequestShare( cell: ToDoTableViewCell )
}

class ToDoTableViewCell: UITableViewCell {

    @IBOutlet weak var todoLabel: UILabel!
    var delegate: TodoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func completeTodo(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestComplete(cell: self)
        }
    }
    
    @IBAction func deleteTodo(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestDelete(cell: self)
        }
    }
    
    @IBAction func shareTodo(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestShare(cell: self)
        }
    }
    
    func strikeThroughText(_ text: String) -> NSAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

