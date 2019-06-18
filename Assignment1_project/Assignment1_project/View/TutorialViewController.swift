//
//  TutorialViewController.swift
//  Assignment1_project
//
//  Created by ME on 18/6/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    // MARK: - Variables
    var loggedOnUser: User?
    
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check the segue
        if segue.identifier == "signInSegue" {
            
            let tabbarController = segue.destination as! UITabBarController
            
            // REF: https://medium.com/@tjcarney89/implementing-a-custom-back-button-in-swift-39e4ab55c71
            // Set the log out button
            let logOutItem = UIBarButtonItem()
            logOutItem.title = "Logout"
            // Set to the cutom font
            let customFont = UIFont(name: "Mali-SemiBold", size: 17.0)!
            logOutItem.setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            
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
    

}
