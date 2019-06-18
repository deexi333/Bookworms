//
//  ChatViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase

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
    
    // References in firebase
    var collectionReference = Firestore.firestore().collection("user")
    var storageReference = Storage.storage()
    
    
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
    
    
    // MARK: - Fixing the keyboard
    // Return button makes the keyboard dissapear
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
        
        for user in users {
            if user.userEmail == loggedOnUser?.userEmail {
                loggedOnUser = user
            }
        }
    }
    
    func onConversationChange(change: DatabaseChange, conversations: [Conversation]) {
        // All the conversations
        allConversations = []
        filteredConversations = []
        
        // For each conversation in the logged on user
        for conversationID in (loggedOnUser?.userConversations)! {
            // iterate through the conversations
            for conversation in conversations {
                if conversation.conversationID == conversationID {
                    var names: String = ""
                    
                    for email in conversation.conversationUsers! {
                        for user in allUsers {
                            if email != loggedOnUser?.userEmail && user.userEmail == email {
                                names = names + "\(user.userFirstName)" + " \(user.userLastName)"
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
    
    func onMessageChange(change: DatabaseChange, messages: [Message]) { }
    
    func onBookChange(change: DatabaseChange, books: [Book]) { }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }
    
    
    // MARK: - Table View
    // Table view variables
    let SECTION_FRIENDS = 0
    let CELL_FRIEND = "friendCell"

    // Search Functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the search text is not empty then get allBooks
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
        return filteredConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendCell = tableView.dequeueReusableCell(withIdentifier: CELL_FRIEND, for: indexPath) as! FriendTableViewCell
        friendCell.friendUserName.text = filteredConversations[indexPath.row].0
        
        if loggedOnUser?.userProfilePicture == "defaultProfilePicture" {
            friendCell.friendProfileImage.image = UIImage(named: "defaultProfilePicture")
        }
            
        // If the image is not the default one then assisng the URL from the user
        else {
            self.storageReference.reference(forURL: loggedOnUser!.userProfilePicture).getData(maxSize: 5 * 1024 * 1024, completion: { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else {
                        let image = UIImage(data: data!)
                        friendCell.friendProfileImage.image = image
                    }
            }
            )
        }
    
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
            
            // REF: https://medium.com/@tjcarney89/implementing-a-custom-back-button-in-swift-39e4ab55c71
            // Set the log out button
            let logOutItem = UIBarButtonItem()
            logOutItem.title = "Back"
            // Set to the cutom font
            let customFont = UIFont(name: "Mali-SemiBold", size: 17.0)!
            // Logout button - setting the color to black
            logOutItem.setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            logOutItem.tintColor = UIColor.black
            
            // Setting the back button
            navigationItem.backBarButtonItem = logOutItem
            
            destination.currentConversation = self.filteredConversations[friendsTableView.indexPathForSelectedRow!.row].1
            destination.loggedOnUser = self.loggedOnUser
        }
    }
    

}
