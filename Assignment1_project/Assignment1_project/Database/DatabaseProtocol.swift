//
//  DatabaseProtocol.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case user
    case book
    case genre
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onUserChange(change: DatabaseChange, user: [User])
    func onBookChange(change: DatabaseChange, book: [Book])
}

protocol DatabaseProtocol: AnyObject {
    // User
    func addUser(userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User
    func updateUserBio(userBio: String, userEmail: String)
    func updateUserProfilePicture(userProfilePicture: String, userEmail: String)
    func checkUser(email: String) -> Bool
    func getUsers() -> [User]
    
    // Book
    func deleteBook(book: Book, user: User)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}

