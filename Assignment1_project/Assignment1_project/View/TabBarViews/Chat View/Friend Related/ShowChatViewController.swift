//
//  ShowChatViewController.swift
//  Assignment1_project
//
//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class ShowChatViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    // Listener
    var listenerType = ListenerType.all
    
    // The conversation that is currently taking place tracker
    var currentConversation: Conversation?
    
    // All the users in the application
    var allUsers: [User] = []
    // All the conversations in the application
    var allConversations: [Conversation] = []
    // All the messages from the conversation
    var allMessages: [Message] = []
    
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // Elements from the storyboard
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextView!
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Swt up the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Initialise table view
        chatTableView.reloadData()
        chatTableView.delegate  = self
        chatTableView.dataSource = self
        chatTableView.reloadData()
    }
    
    
    // MARK: - Listeners
    func onUserChange(change: DatabaseChange, users: [User]) {
        allUsers = users
    }
    
    func onConversationChange(change: DatabaseChange, conversations: [Conversation]) {
        allConversations = conversations
    }
    
    func onMessageChange(change: DatabaseChange, messages: [Message]) {
        // All the messages in a given conversation
        allMessages = []
        
        // Iterate through all the conversations
        for conversation in allConversations {
            // If the conversationID's match
            if conversation.conversationID == currentConversation?.conversationID {
                // Iterate through the messages
                for message in messages {
                    // Iterate through the messageID conversations
                    for messageID in conversation.conversationMessages! {
                        // If the messageID's match
                        if message.messageID == messageID {
                            // Append the message
                            allMessages.append(message)
                        }
                    }
                }
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) { }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }

    
    // MARK: - View will appear and disapper functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        databaseController?.addListener(listener: self)
        // Reloads the chat table view
        self.chatTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
        // Reloads the chat table view
        self.chatTableView.reloadData()
    }
    
    
    // MARK: - Table View
    // Variables
    let SECTION_MESSAGE = 0
    let CELL_MESSAGE = "chatMessageCell"
    
    // Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        // there is one section therefore return 1
        return 1
    }
    
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
        
        messageCell.messageLabel.text = "\(message.messageSent)"
        
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
