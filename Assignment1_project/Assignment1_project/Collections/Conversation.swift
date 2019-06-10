//
//  Conversation.swift
//  Assignment1_project
//
//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase

class Conversation: NSObject {
    var conversationID: String?
    var conversationMessages: [String]?
    var conversationUsers: [String]?
    
    init(conversationID: String) {
        self.conversationID = conversationID
        conversationMessages = [String]()
        conversationUsers = [String]()
    }

}
