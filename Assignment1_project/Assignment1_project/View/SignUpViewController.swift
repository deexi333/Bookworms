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
    
    // DataListener Variables
    var allUsers: [User] = []
    
    // TextFields from the story board
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userReenterPasswordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
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
    
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) {
        
    }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) {
        
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
    
    // Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Button to sign Up --- can remove
    @IBAction func signUpButton(_ sender: Any) {
        
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
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSegue" {
            let tabbarController = segue.destination as! UITabBarController
            
            tabbarController.navigationItem.setHidesBackButton(true, animated:true)
            tabbarController.navigationItem.title = "PROFILE"
            
            let peopleViewController = tabBarController?.viewControllers?[0] as! PeopleViewController
            peopleViewController.loggedOnUser = self.loggedOnUser
            
            let chatViewController = tabBarController?.viewControllers?[1] as! ChatViewController
            chatViewController.loggedOnUser = self.loggedOnUser
            
            let profileViewController = tabBarController?.viewControllers?[2] as! ProfileViewController
            profileViewController.loggedOnUser = self.loggedOnUser
            
            tabbarController.selectedIndex = 2
        }
    }
}
