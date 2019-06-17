//
//  SignUpViewController.swift
//  Assignment1_project
//
//  Created by ME on 5/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, DatabaseListener {
    
    
    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // Listener
    var listenerType = ListenerType.all
    
    // The user that has logged on
    var loggedOnUser: User?
    
    // Active field to see what text field has been selected
    var activeField: UITextField?
    
    // TextFields from the story board
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userReenterPasswordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    // DataListener Variables
    var allUsers: [User] = []
    
   
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // The app delegate for the database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Fixing the keyboard
        userFirstNameTextField.delegate = self
        userLastNameTextField.delegate = self
        userPasswordTextField.delegate = self
        userEmailTextField.delegate = self
        userReenterPasswordTextField.delegate = self
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
        if segue.identifier == "signUpSegue" {
            let tabbarController = segue.destination as! UITabBarController
            
            // REF: https://medium.com/@tjcarney89/implementing-a-custom-back-button-in-swift-39e4ab55c71
            // Set the log out button
            let logOutItem = UIBarButtonItem()
            logOutItem.title = "Logout"
            // Set to the cutom font
            let customFont = UIFont(name: "Mali-SemiBold", size: 17.0)!
            // Logout button - setting the color to black
            logOutItem.setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            logOutItem.tintColor = UIColor.black
            
            // Setting the back button
            navigationItem.backBarButtonItem = logOutItem
            
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
    
    // Checks whether the segue should be performed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // If the the segue is the signup segue
        if identifier == "signUpSegue" {
            
            // Check whether the first name field is empty
            let firstName = userFirstNameTextField.text
            if (firstName?.isEmpty)! {
                // If empty then add an error message
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            // Check whether the last name field is empty
            let lastName = userLastNameTextField.text
            if (lastName?.isEmpty)! {
                // If empty then add an error message
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            // Check whether the email field is empty
            let email = userEmailTextField.text
            if (email?.isEmpty)! {
                // If empty then add an error message
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            // check whether the password field and reenter password field is empty
            let password = userPasswordTextField.text
            let reenterPassword = userReenterPasswordTextField.text
            
            if (password?.isEmpty)! {
                // If empty then add an error message
                errorLabel.text = "Password cannot be empty"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            if (reenterPassword?.isEmpty)! {
                // If empty then add an error message
                errorLabel.text = "Please reenter the password to confirm"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            if reenterPassword != password {
                // If the passwords do not match then send an error message
                errorLabel.text = "Passwords do not match"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            // Check if the user is in the database
            var isRegisteredUser: Bool = false
            
            for user in allUsers {
                if email == user.userEmail {
                    isRegisteredUser = true
                }
            }
            
            if isRegisteredUser {
                // if already registered then send an error message
                errorLabel.text = "You are already registered"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            // add the new user to the database
            self.loggedOnUser = databaseController?.addUser(userFirstName: firstName!, userLastName: lastName!, userEmail: email!, userPassword: password!)
            
            return true
        }
        return true
    }
}

