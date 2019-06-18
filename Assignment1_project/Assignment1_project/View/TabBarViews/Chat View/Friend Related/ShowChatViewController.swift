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
    // The user that is logged on
    var loggedOnUser: User?
    
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

        // Set up the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Initialise table view
        chatTableView.reloadData()
        chatTableView.delegate  = self
        chatTableView.dataSource = self
        chatTableView.reloadData()
        
        // Making the keyboard move up so that the bio text view is not blocked
        // REF: https://stackoverflow.com/questions/50325019/moving-view-up-with-textfield-and-button-when-keyboard-appear-swift
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    // MARK: - Fixing the keyboard
    // When the user touches outside the keyboard the keyboard resigns down
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // making the keyboard move up
    @objc func keyboard(notification:Notification) {
        guard let keyboardReact = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||  notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.view.frame.origin.y = -keyboardReact.height
        } else{
            self.view.frame.origin.y = 0
        }
    }
    
    
    // MARK: - Send message
    @IBAction func sendMessage(_ sender: Any) {
        // REF: - https://stackoverflow.com/questions/46376823/ios-swift-get-the-current-local-time-and-date-timestamp/46390754
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: now)
        
        var messageReceivers: [String] = []
        
        for user in currentConversation!.conversationUsers! {
            if user != loggedOnUser?.userEmail{
                messageReceivers.append(user)
            }
        }
        
        databaseController?.addMessage(messageTime: dateString, messageReceiver: messageReceivers, messageSender: loggedOnUser!.userEmail, messageSent: messageTextField.text, conversationID: currentConversation!.conversationID!)
        
        self.messageTextField.text = ""
    }
    
    
    // MARK: - Listeners
    func onUserChange(change: DatabaseChange, users: [User]) {
        allUsers = users
        
        for user in users {
            if user.userEmail == loggedOnUser?.userEmail {
                loggedOnUser = user
            }
        }
    }
    
    func onConversationChange(change: DatabaseChange, conversations: [Conversation]) {
        allConversations = conversations
        
        // iterate through the conversations
        for conversation in conversations {
            if currentConversation?.conversationID == conversation.conversationID {
                currentConversation = conversation
            }
        }
    }
    
    func onMessageChange(change: DatabaseChange, messages: [Message]) {
        // All the messages in a given conversation
        allMessages = []
        
        // Iterate through the messages
        for message in messages {
            // Iterate through the messageID conversations
            for messageID in currentConversation!.conversationMessages! {
                // If the messageID's match
                if message.messageID == messageID {
                    // Append the message
                    allMessages.append(message)
                }
            }
        }
        
        self.chatTableView.reloadData()
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
    let SECTION_FRIENDMESSAGE = 0
    let CELL_FRIENDMESSAGE = "friendChatMessageCell"
    
    // Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        // there are two sections therefore return 2
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if allMessages.count > 0 {
            if indexPath.section == SECTION_FRIENDMESSAGE {
                let messageCell = tableView.dequeueReusableCell(withIdentifier: CELL_FRIENDMESSAGE, for: indexPath) as! FriendChatMessageTableViewCell
                let message = allMessages[indexPath.row]
                
                // get the current user
                var friend: User?
                
                for user in allUsers {
                    if user.userEmail == message.messageSender {
                        friend = user
                    }
                }
                
                // align to the right if it is the user
                if message.messageSender == loggedOnUser?.userEmail {
                    messageCell.friendMessageLabel.textAlignment = .right
                    messageCell.friendNameLabel.textAlignment = .right
                }
                
                // align to the left if it a friend
                else {
                    messageCell.friendMessageLabel.textAlignment = .left
                    messageCell.friendNameLabel.textAlignment = .left
                }
                
                messageCell.friendNameLabel.text = friend!.userFirstName + " " + friend!.userLastName
                messageCell.friendMessageLabel.text = message.messageSent
                
                return messageCell
            }
        }
        
        return UITableViewCell()
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
