//
//  Message.swift
//  Assignment1_project
//
//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class Message: NSObject {
    var messageID: String?
    var messageReceiver: [String]?
    var messageSender: String?
    var messageSent: String?
    var messageTime: String?
    
    init(messageID: String, messageReceiver: [String], messageSender: String, messageTime: String, messageSent: String) {
        self.messageID = messageID
        self.messageReceiver = messageReceiver
        self.messageSender = messageSender
        self.messageSent = messageSent
        self.messageTime = messageTime
    }
}
