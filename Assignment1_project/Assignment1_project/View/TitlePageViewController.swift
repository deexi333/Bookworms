//
//  TitlePageViewController.swift
//  Assignment1_project
//
//  Created by ME on 5/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class TitlePageViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    var user: User?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    
 
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "signInSegue" {
            
            let email = emailTextField.text
            if (email?.isEmpty)! {
                errorLabel.text = "Please fill out all the fields"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            let password = passwordTextField.text
            if (password?.isEmpty)! {
                errorLabel.text = "Password cannot be empty"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            let registeredUser = databaseController?.checkUser(email: email!)
            let registeredUsers = databaseController?.getUsers()
            
            if !registeredUser! {
                errorLabel.text = "You are not a registered user"
                errorLabel.textColor = UIColor.red
                return false
            }
            
            else {
                for user in registeredUsers! {
                    if email == user.userEmail {
                        if password != user.userPassword {
                            errorLabel.text = "Your username or password is incorrect"
                            errorLabel.textColor = UIColor.red
                            return false
                        }
                        self.user = user
                        print("yay")
                        
                        
                    }
                }
            }
            
            return true
        }
        
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "signInSegue" {
            let tabbarController = segue.destination as! UITabBarController
            tabbarController.navigationItem.setHidesBackButton(true, animated:true)
            let profile = tabbarController.viewControllers![2] as! ProfileViewController
            profile.user = self.user
            let people = tabbarController.viewControllers![0] as! PeopleViewController
            people.user = self.user
            let chat = tabbarController.viewControllers![1] as! ChatViewController
            chat.user = self.user
            tabbarController.selectedIndex = 2
        }
    }
}
