//
//  PeopleViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController, DatabaseListener {
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) {
        
    }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) {
        
    }
    

    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // variables from the storyboard
    @IBOutlet weak var detailsSegmentView: UIView!
    @IBOutlet weak var bookSegmentView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileView: UIView!
    
    var userTrack = 0
    
    // the user that is currently logged on
    var loggedOnUser: User?
    var trackUser: User?
    var allUsers: [User]?
    
    var listenerType = ListenerType.user
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        allUsers = users
        
        for user in users {
            if user.userEmail == loggedOnUser!.userEmail {
                loggedOnUser = user
            }
        }
        
        trackUser = allUsers![0]
        self.profilePicture.image = UIImage(named: (trackUser?.userProfilePicture)!)
        
        // Format the profile picture
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1;
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // App delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Set the title of the people tab
        self.tabBarItem = UITabBarItem(title: "PEOPLE", image: nil, selectedImage: nil)
        
        // Fixing the keyboard
        self.segmentController.selectedSegmentIndex = 0
        detailsSegmentView.isHidden = false
        bookSegmentView.isHidden = true
    }
    
    // Change depending on what segment
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
    
    @IBAction func addFriendToUser(_ sender: Any) {
        let _ = databaseController!.addFriendToUser(userEmail: loggedOnUser!.userEmail, friendEmail: trackUser!.userEmail)
        let _ = self.tabBarController!.viewControllers![1] as! ChatViewController
    }
    
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
            let uiView = segue.destination as! DetailsSegementViewController
            uiView.selectView = "People"
            uiView.trackUser = self.loggedOnUser
            uiView.loggedOnUser = self.loggedOnUser
        }
        
        if segue.identifier == "peopleBookSegementSegue" {
            let uiView = segue.destination as! BookSegmentViewController
            uiView.selectView = "People"
            uiView.trackUser = self.loggedOnUser
            uiView.loggedOnUser = self.loggedOnUser
        }
        
        if segue.identifier == "addFriendSegue" {
            let tabbarController = segue.destination as! UITabBarController
            let chatViewController = tabBarController?.viewControllers?[1] as! ChatViewController
            chatViewController.loggedOnUser = self.loggedOnUser
        }
    }
}
