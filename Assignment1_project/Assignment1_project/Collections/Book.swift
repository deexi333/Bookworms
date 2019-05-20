//
//  Book.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase

class Book: NSObject {
    var bookAuthor: String;
    var bookDescription:String?
    var bookGenre: [DocumentReference]
    var bookID: String?
    var bookName: String?
    
    init(bookAuthor: String, bookDescription: String, bookGenre: [DocumentReference], bookName: String) {
        self.bookAuthor = bookAuthor
        self.bookDescription = bookDescription
        self.bookGenre = [DocumentReference]()
        self.bookName = bookName
    }
}
