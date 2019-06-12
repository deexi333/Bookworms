//
//  ShowChatViewController.swift
//  Assignment1_project
//
//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class ShowChatViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource{
    var listenerType = ListenerType.all
    
    var allUsers: [User] = []
    var allMessages: [String] = ["hi", "cool", "very good"]
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        
    }
    
    func onConversationChange(change: DatabaseChange, conversations: [Conversation]) {
        
    }
    
    func onMessageChange(change: DatabaseChange, messages: [Message]) {
        
    }
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextView!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Initialise table view
        chatTableView.reloadData()
        chatTableView.delegate  = self
        chatTableView.dataSource = self
        chatTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        databaseController?.addListener(listener: self)
        self.chatTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
        self.chatTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // there is one sections therefore return 1
        return 1
    }
    
    let SECTION_MESSAGE = 0
    let CELL_MESSAGE = "chatMessageCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_MESSAGE {
            return allMessages.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageCell = tableView.dequeueReusableCell(withIdentifier: CELL_MESSAGE, for: indexPath) as! ChatMessageTableViewCell
        let message = allMessages[indexPath.row]
        
        
        messageCell.messageLabel.text = "\(message)"
        
        return messageCell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
