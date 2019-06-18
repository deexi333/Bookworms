//
//  DetailsSegementViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class DetailsSegementViewController: UIViewController, UITextViewDelegate, DatabaseListener {
   
    // MARK: - Variables
    // The listener
    var listenerType = ListenerType.all

    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // variables to track the user and the view that is being used
    var selectView: String?         // the view to check whether it is profile and people view controller
    var loggedOnUser: User?         // currently logged on user
    var trackUser: User?            // Users potential friend
    
    var allUsers: [User] = []       // All the users in the database
    
    // Variables from the story board
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    
    // MARK: - Functions
    override func viewDidLoad() {
         super.viewDidLoad()
        
        // App delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
       
        // check which view
        if selectView == "People" {
            // Disable edit of biotext
            bioTextView.isEditable = false
        
            userNameLabel.text = "\(trackUser!.userFirstName) \(trackUser!.userLastName)"
            bioTextView.text = "\(trackUser!.userBio)"
        }
        
        else {
            // display necessary details for the current user
            userNameLabel.text = "\(loggedOnUser!.userFirstName) \(loggedOnUser!.userLastName)"
            bioTextView.text = "\(loggedOnUser!.userBio)"
            
            // Fixing the keyboard
            bioTextView.delegate = self
        }
    }
    
    
    // MARK: - fixing keyboard
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // once the user touches outside of the bio text view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // update the bio text in the database
        if selectView != "People" {
            self.view.endEditing(true)
            databaseController!.updateUserBio(userBio: bioTextView.text, userEmail: (loggedOnUser?.userEmail)!)
        }
    }
    
    
    // MARK: - Database protocol
    func onUserChange(change: DatabaseChange, users: [User]) {
        // For all the users in the database
        for user in users {
            // get the updated logged on user
            if user.userEmail == loggedOnUser?.userEmail {
                self.loggedOnUser = user
            }
            // get the updated track user
            if user.userEmail == trackUser?.userEmail {
                self.trackUser = user
            }
        }
        
        allUsers = users
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) { }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }
    
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) { }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) { }
    
    
    // MARK: - View will appear and disappear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
    }
    
    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
    */

}
