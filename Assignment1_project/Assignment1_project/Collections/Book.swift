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
    var bookGenre: [String]
    var bookID: String?
    var bookName: String?
    
    init(bookID: String, bookAuthor: String, bookDescription: String, bookGenre: [String], bookName: String) {
        self.bookID = bookID
        self.bookAuthor = bookAuthor
        self.bookDescription = bookDescription
        self.bookGenre = [String]()
        self.bookName = bookName
    }
}
