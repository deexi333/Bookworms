//
//  ChatViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UISearchBarDelegate, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
   
    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // The currently logged in user
    var loggedOnUser: User?
    
    // Adding the listeners
    var listenerType = ListenerType.all

    // Elements from the storyboard
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // All the users in the application
    var allUsers: [User] = []
    // All the conversations that the user has
    var allConversations: [(String, Conversation)] = []
    // The filtered conversations of the names
    var filteredConversations: [(String, Conversation)] = []
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the navigation controller title
        self.navigationController?.title = "CHAT"
        
        // Setting the appdelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Search set up
        searchBar.delegate = self
        definesPresentationContext = true

        // Initialise table view
        friendsTableView.reloadData()
        friendsTableView.delegate  = self
        friendsTableView.dataSource = self
        friendsTableView.reloadData()
    }
    
    // MARK: - The view appear and disappear functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        databaseController?.addListener(listener: self)
        // Reloading the freinds table view
        self.friendsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
        // Reloading the friends table view
        self.friendsTableView.reloadData()
    }
    
    
    // MARK: - Database Protocols
    func onUserChange(change: DatabaseChange, users: [User]) {
        allUsers = users
    }
    
    func onConversationChange(change: DatabaseChange, conversations: [Conversation]) {
        // All the conversations
        allConversations = []
        filteredConversations = []
        
        // Interate through each user
        for user in allUsers {
            // If the user is the logged on user
            if user.userEmail == loggedOnUser?.userEmail {
                // Iterate throgugh the user conversations
                for conversationID in user.userConversations {
                    // Iterate through all the conversations
                    for conversation in conversations {
                        // if the conversationID is the id in the conversation
                        if conversationID == conversation.conversationID {
                            // String consisting of the names
                            var names: String = ""
                            
                            // Iterate through the conversation emails
                            for email in conversation.conversationUsers! {
                                // Iterate through all the users
                                for user in allUsers {
                                    // If the email is not the logged in user and if the user email is the email in the conversation
                                    if  email != loggedOnUser?.userEmail && user.userEmail == email {
                                        // Append the names together
                                        names = names + "\(user.userFirstName)" + "\(user.userLastName)" + ", "
                                    }
                                }
                            }
                            
                            // Add the conversation and the names as a tuple
                            allConversations.append((names, conversation))
                            filteredConversations.append((names, conversation))
                        }
                    }
                }
            }
        }
    }
    
    func onMessageChange(change: DatabaseChange, messages: [Message]) { }
    
    func onBookChange(change: DatabaseChange, books: [Book]) { }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }
    
    
    // MARK: - Table View
    // Table view variables
    let SECTION_FRIENDS = 0
    let CELL_FRIEND = "friendCell"

    // Search Functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the search textis not emptythen get allBooks
        filteredConversations = searchText.isEmpty ? allConversations : allConversations.filter({(dataString: (String, Conversation)) -> Bool in
            // return the entries that have the same name as the search text
            return dataString.0.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        // reload the data
        self.friendsTableView.reloadData()
    }
    
    // Table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        // there is one sections therefore return 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_FRIENDS {
            return filteredConversations.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendCell = tableView.dequeueReusableCell(withIdentifier: CELL_FRIEND, for: indexPath) as! FriendTableViewCell
        friendCell.friendUserName.text = filteredConversations[indexPath.row].0
        friendCell.friendProfileImage.image = UIImage(named: "defaultProfilePicture")
        friendCell.friendProfileImage.layer.cornerRadius = friendCell.friendProfileImage.frame.size.width / 2;
        friendCell.friendProfileImage.clipsToBounds = true;
        friendCell.friendProfileImage.layer.borderWidth = 1;
        
        return friendCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // checks whether or not the row is a task
        if indexPath.section == SECTION_FRIENDS {
            return true
        }
        return false
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showMessagesSegue" {
            let destination = segue.destination as! ShowChatViewController
            destination.currentConversation = self.filteredConversations[friendsTableView.indexPathForSelectedRow!.row].1
            destination.loggedOnUser = self.loggedOnUser
        }
    }
    

}
