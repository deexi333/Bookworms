//
//  TitlePageViewController.swift
//  Assignment1_project
//
//  Created by ME on 5/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class TitlePageViewController: UIViewController, DatabaseListener {
    
    // MARK: - Variables
    // Database related variables
    weak var databaseController: DatabaseProtocol?
    
    // Listener type
    var listenerType = ListenerType.all
    
    // User that has logged in
    var loggedOnUser: User?
    
    // Text fields and labels
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var allUsers: [User] = []
    
    // MARK: - Listener functions
    func onUserChange(change: DatabaseChange, users: [User]) {
        allUsers = users
        for user in users {
            if user.userEmail == loggedOnUser?.userEmail {
                loggedOnUser = user
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        
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
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    
    // Checks whether or not a certain segue should be performed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // Checks that the segue is for signing up
        if identifier == "signInSegue" {
            
            // Checks whether the email text field is empty
            let email = emailTextField.text
            if (email?.isEmpty)! {
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            // Checks whether the password text field is empty
            let password = passwordTextField.text
            if (password?.isEmpty)! {
                errorLabel.text = "Password cannot be empty"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            // Check whether the user exists in the database
            var isRegisteredUser: Bool  = false
            
            for user in allUsers {
                print("\(user.userEmail)")
                if user.userEmail == email {
                    isRegisteredUser = true
                }
            }
            
            if !isRegisteredUser {
                // set the error label
                errorLabel.text = "You are not a registered user"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            else {
                // Get all the users from the database
                let registeredUsers = allUsers
                for user in registeredUsers {
                    if email == user.userEmail {
                        if password != user.userPassword {
                            // if the password does not match then set up the error label
                            errorLabel.text = "Your username or password is incorrect"
                            errorLabel.textColor = UIColor.red
                            return false
                        }
                        // Set the logged in user
                        self.loggedOnUser = user
                    }
                }
            }
            return true
        }
        return true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // check the segue
        if segue.identifier == "signInSegue" {
            
            let tabbarController = segue.destination as! UITabBarController
            tabbarController.navigationItem.setHidesBackButton(true, animated:true)
            
            // Set the user in the profile view
            let profile = tabbarController.viewControllers![2] as! ProfileViewController
            profile.loggedOnUser = self.loggedOnUser
            
            // Set the user in the people view
            let people = tabbarController.viewControllers![0] as! PeopleViewController
            people.loggedOnUser = self.loggedOnUser
            
            // Set the user in the chat view
            let chat = tabbarController.viewControllers![1] as! ChatViewController
            chat.loggedOnUser = self.loggedOnUser
            
            // Set the tabbar to the people view
            tabbarController.selectedIndex = 2
        }
    }
}
