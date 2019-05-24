//
//  ChatViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    // MARK: - Variables
    var loggedOnUser: User?

    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title of the chat tab
        self.tabBarItem = UITabBarItem(title: "CHAT", image: nil, selectedImage: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
