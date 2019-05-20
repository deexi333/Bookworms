//
//  SignUpViewController.swift
//  Assignment1_project
//
//  Created by ME on 5/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate{
    
    weak var databaseController: DatabaseProtocol?
    var user: User?
    
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userReenterPasswordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        userFirstNameTextField.delegate = self
        userLastNameTextField.delegate = self
        userPasswordTextField.delegate = self
        userEmailTextField.delegate = self
        userReenterPasswordTextField.delegate = self
    }
    
    // keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUpButton(_ sender: Any) {
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSegue" {
            let tabbarController = segue.destination as! UITabBarController
            
            tabbarController.navigationItem.setHidesBackButton(true, animated:true)
            tabbarController.navigationItem.title = "PROFILE"
            
            let destinationViewController = tabBarController?.viewControllers?[2] as! ProfileViewController
            destinationViewController.user = self.user
            
            tabbarController.selectedIndex = 2
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "signUpSegue" {
            let firstName = userFirstNameTextField.text
            if (firstName?.isEmpty)! {
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
                
            let lastName = userLastNameTextField.text
            if (lastName?.isEmpty)! {
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
                
            let email = userEmailTextField.text
            if (email?.isEmpty)! {
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
                
            let password = userPasswordTextField.text
            let reenterPassword = userReenterPasswordTextField.text
            if (password?.isEmpty)! {
                errorLabel.text = "Password cannot be empty"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            if (reenterPassword?.isEmpty)! {
                errorLabel.text = "Please reenter the password to confirm"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            if reenterPassword != password {
                errorLabel.text = "Passwords do not match"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            let registeredUser = databaseController?.checkUser(email: email!)
            
            if registeredUser! {
                errorLabel.text = "You are already registered"
                errorLabel.textColor = UIColor.red
                return false
            }
        
            
            self.user = databaseController?.addUser(userFirstName: firstName!, userLastName: lastName!, userEmail: email!, userPassword: password!)
            
            return true
            
        }
        return true
    }
    
    
}
