//
//  ChatViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UISearchBarDelegate, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) {
        
    }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) {
        
   }
    
    
    // MARK: - Variables
    weak var databaseController: DatabaseProtocol?
    
    var loggedOnUser: User?

    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title of the chat tab
        self.tabBarItem = UITabBarItem(title: "CHAT", image: nil, selectedImage: nil)
        self.navigationController?.title = "CHAT"
        
        // App delegate
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
    
    var listenerType = ListenerType.all
    
    let SECTION_FRIENDS = 0
    let CELL_FRIEND = "friendCell"
    
    var allUsers: [User] = []
    var allFriends: [User] = []
    var filteredFriends: [User] = []
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        
        allFriends = []
        filteredFriends = []
        
        for user in users {
            if loggedOnUser?.userEmail == user.userEmail {
                loggedOnUser = user
            }
        }
        
        
        for friendID in (loggedOnUser?.userFriends)! {
            for user in users {
                if friendID == user.userEmail {
                    allFriends.append(user)
                    filteredFriends.append(user)
                }
            }
        }
        
        allUsers = users
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        databaseController?.addListener(listener: self)
        self.friendsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
        self.friendsTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the search textis not emptythen get allBooks
        filteredFriends = searchText.isEmpty ? allFriends : allFriends.filter({(dataString: User) -> Bool in
            // return the entries that have the same name as the search text
            return dataString.userEmail.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        // reload the data
        friendsTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // there is one sections therefore return 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_FRIENDS {
            return filteredFriends.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendCell = tableView.dequeueReusableCell(withIdentifier: CELL_FRIEND, for: indexPath) as! FriendTableViewCell
        let friend = filteredFriends[indexPath.row]
        
        friendCell.friendUserName.text = "\(friend.userFirstName) \(friend.userLastName)"
        friendCell.friendProfileImage.image = UIImage(named: friend.userProfilePicture)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
