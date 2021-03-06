//
//  TitlePageViewController.swift
//  Assignment1_project
//
//  Created by ME on 5/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class TitlePageViewController: UIViewController, DatabaseListener, UITextFieldDelegate {
    
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
    
    // All the users that are in the application
    var allUsers: [User] = []
    
 
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Setting the keybard delegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    // MARK: - Keyboard
    // Return button makes the keyboard dissapear
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // When the user touches outside the keyboard the keyboard resigns down
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    // MARK: - Listener functions
    func onUserChange(change: DatabaseChange, users: [User]) {
        allUsers = users
        for user in users {
            if user.userEmail == loggedOnUser?.userEmail {
                loggedOnUser = user
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) { }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }
    
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) { }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) { }
    
    
    // MARK: - The View appear and disappear functions
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
        if segue.identifier == "tutorialSignInSegue" {
            let tutorialView = segue.destination as! TutorialViewController
            tutorialView.loggedOnUser = loggedOnUser
            
            // REF: https://medium.com/@tjcarney89/implementing-a-custom-back-button-in-swift-39e4ab55c71
            // Set the log out button
            let backItem = UIBarButtonItem()
            backItem.title = "Logout"
            // Set to the cutom font
            let customFont = UIFont(name: "Mali-SemiBold", size: 17.0)!
            backItem.setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            
            // Setting the back button
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    // Checks whether or not a certain segue should be performed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // Checks that the segue is for signing up
        if identifier == "tutorialSignInSegue" {
            
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
}
