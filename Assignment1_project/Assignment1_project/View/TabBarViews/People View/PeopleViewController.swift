//
//  PeopleViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase

class PeopleViewController: UIViewController, DatabaseListener {
    
    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // variables from the storyboard
    @IBOutlet weak var detailsSegmentView: UIView!
    @IBOutlet weak var bookSegmentView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var errorView: UIView!
    
    // variables to save the UIViews
    var detailsView: DetailsSegementViewController?
    var bookView: BookSegmentViewController?
    
    // tracking the index of the tracked user
    var userTrack = 0
    // the user that is currently logged on
    var loggedOnUser: User?
    // the tracked user
    var trackUser: User?
    // All the users in the databases
    var allUsers: [User]?
    
    // Listeners
    var listenerType = ListenerType.all
    
    // References
    var collectionReference = Firestore.firestore().collection("user")
    var storageReference = Storage.storage()
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // App delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Adding a swipe gesture to the right of the view
        // REF: https://www.youtube.com/watch?v=mhoCulcSbeY#action=share
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        swipeLeftGesture.direction = UISwipeGestureRecognizer.Direction.left
        self.profileView.addGestureRecognizer(swipeLeftGesture)
        
        // Fixing the keyboard
        self.segmentController.selectedSegmentIndex = 0
        detailsSegmentView.isHidden = false
        bookSegmentView.isHidden = true
    }
    
    
    // MARK: - Database protocol
    func onUserChange(change: DatabaseChange, users: [User]) {
        allUsers = []
        
        // get the currently logged in user
        for user in users {
            if user.userEmail == loggedOnUser!.userEmail {
                loggedOnUser = user
            }
        }
        
        // Get all the users that the user has
        for user in users {
            if user.userEmail != loggedOnUser?.userEmail {
                
                if (loggedOnUser?.userFriends.count)! > 0 {
                    for friend in loggedOnUser!.userFriends {
                        if user.userEmail != friend {
                            allUsers?.append(user)
                        }
                    }
                }
                
                else {
                    allUsers?.append(user)
                }
            }
        }
        
        // If there is onlyone user
        if users.count == 1 {
            errorView.isHidden = false
            profileView.isHidden = true
        }
        
        // if there is noone else to add
        if allUsers?.count == 0 {
            errorView.isHidden = false
            profileView.isHidden = true
        }
        
        else {
            errorView.isHidden = true
            profileView.isHidden = false
            
            // get the first user
            trackUser = allUsers![userTrack]
            
            // Set the profile pciture
            if trackUser?.userProfilePicture == "defaultProfilePicture" {
                self.profilePicture.image = UIImage(named: trackUser!.userProfilePicture)
            }
                
            // If the image is not the default one then assisng the URL from the user
            else {
                self.storageReference.reference(forURL: trackUser!.userProfilePicture).getData(maxSize: 5 * 1024 * 1024,
                completion: { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else {
                        let image = UIImage(data: data!)
                        // Assign image
                        self.profilePicture.image = image
                    }
                }
                )
            }
            
            // Format the profile picture
            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
            self.profilePicture.clipsToBounds = true;
            self.profilePicture.layer.borderWidth = 1;
            
            // View did load called for the details view
            self.detailsView?.trackUser = trackUser
            self.detailsView?.viewDidLoad()
            
            // View did load called for the book view
            self.bookView?.trackUser = trackUser
            self.bookView?.viewDidLoad()
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) { }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }
    
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) { }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) { }
    
  
    // MARK: - Segment controller
    @IBAction func onSegmentChange(_ sender: Any) {
        switch  segmentController.selectedSegmentIndex {
        // If segment is the details view
        case 0:
            detailsSegmentView.isHidden = false
            bookSegmentView.isHidden = true
            break
        // If segment is books view
        case 1:
            detailsSegmentView.isHidden = true
            bookSegmentView.isHidden = false
            break
        default:
            break
        }
    }
    
    
    // MARK: - Gesture swipe
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        if userTrack == allUsers!.count - 1 {
            userTrack = 0
        }
            
        else {
            userTrack += 1
        }
        
        trackUser = allUsers![userTrack]
        
        if trackUser?.userProfilePicture == "defaultProfilePicture" {
            self.profilePicture.image = UIImage(named: trackUser!.userProfilePicture)
        }
            
            // If the image is not the default one then assisng the URL from the user
        else {
            self.storageReference.reference(forURL: trackUser!.userProfilePicture).getData(maxSize: 5 * 1024 * 1024,
            completion: { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                let image = UIImage(data: data!)
                self.profilePicture.image = image
            }
            }
            )
        }
        
        // Format the profile picture
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1;
        
        self.detailsView?.trackUser = trackUser
        self.detailsView?.viewDidLoad()
        
        self.bookView?.trackUser = trackUser
        self.bookView?.viewDidLoad()
        
        self.viewDidLoad()
    }
    
    
    // Once the message button is pressed
    @IBAction func addFriendToUser(_ sender: Any) {
        let _ = self.databaseController!.addFriendToUser(userEmail: self.loggedOnUser!.userEmail, friendEmail: self.trackUser!.userEmail)
        let _ = self.databaseController!.addConversation(userEmail: self.loggedOnUser!.userEmail, friendEmail: self.trackUser!.userEmail)
    }
    
    
    // MARK: - View will appear and disappear functions
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

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check the segue and go to the detailsSegmentViewController
    
        if segue.identifier == "peopleDetailsProfileSegue" {
            self.detailsView = (segue.destination as! DetailsSegementViewController)
            self.detailsView!.selectView = "People"
            self.detailsView!.trackUser = self.loggedOnUser
            self.detailsView!.loggedOnUser = self.loggedOnUser
        }
        
        if segue.identifier == "peopleBookSegementSegue" {
            self.bookView = (segue.destination as! BookSegmentViewController)
            self.bookView!.selectView = "People"
            self.bookView!.trackUser = self.loggedOnUser
            self.bookView!.loggedOnUser = self.loggedOnUser
        }
        
        if segue.identifier == "addFriendSegue" {
            let _ = segue.destination as! UITabBarController
            let chatViewController = tabBarController?.viewControllers?[1] as! ChatViewController
            chatViewController.loggedOnUser = self.loggedOnUser
        }
    }
}
