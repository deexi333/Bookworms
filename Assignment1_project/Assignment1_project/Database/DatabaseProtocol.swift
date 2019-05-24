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
    func onUserChange(change: DatabaseChange, users: [User])
    func onBookChange(change: DatabaseChange, books: [Book])
    func onGenreChange(change: DatabaseChange, genres: [Genre])
}

protocol DatabaseProtocol: AnyObject {
    // User
    func addUser(userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User
    func updateUserBio(userBio: String, userEmail: String)
    func updateUserProfilePicture(userProfilePicture: String, userEmail: String)
    
//    // Remove
//    func checkUser(email: String) -> Bool
//    func getUsers() -> [User]
//
    // Book
    func deleteBook(book: Book, user: User)
    func addBookToUser(userEmail: String, bookID: String)
    
//    // Remove
//    func getBooks() -> [Book]
//    func getUserBooks(currentUser: User) -> [Book]
//    func getInverseUserBooks(currentUser: User) -> [Book]
    
    // Genres
//    func getBookGenres(currentBook: Book) -> [Genre]
    
    // Listeners
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}

