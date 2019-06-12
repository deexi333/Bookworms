//
//  User.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
    var userFirstName: String
    var userLastName: String
    var userBio: String
    var userProfilePicture: String
    var userEmail: String
    var userBooks: [String]
    var userFriends: [String]
    var userPassword: String
    var userConversations: [String]
    
    
    init(userFirstName: String, userLastName: String, userEmail: String, userPassword: String, userBio: String, userProfilePicture: String) {
        self.userFirstName = userFirstName
        self.userLastName = userLastName
        self.userEmail = userEmail
        self.userPassword = userPassword
        self.userBooks = [String]()
        self.userFriends = [String]()
        self.userConversations = [String]()
        self.userBio = userBio
        self.userProfilePicture = userProfilePicture
    }
    
}
