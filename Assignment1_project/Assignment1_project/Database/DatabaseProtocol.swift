//
//  DatabaseProtocol.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case user
    case book
    case genre
    case conversation
    case message
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onUserChange(change: DatabaseChange, users: [User])
    func onBookChange(change: DatabaseChange, books: [Book])
    func onGenreChange(change: DatabaseChange, genres: [Genre])
    func onConversationChange(change: DatabaseChange, conversations: [Conversation])
    func onMessageChange(change: DatabaseChange, messages: [Message])
}

protocol DatabaseProtocol: AnyObject {
    // User
    func addUser(userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User
    func updateUserBio(userBio: String, userEmail: String)
    func updateUserProfilePicture(userProfilePicture: String, userEmail: String)
    func updateUserCameraAcceptance(userEmail: String, userCameraAcceptance: String)
    
    // Book
    func deleteBook(book: Book, user: User)
    func addBookToUser(userEmail: String, bookID: String)
    
    // Friends
    func addFriendToUser(userEmail: String, friendEmail: String)
    
    // Chat functionality
    func addConversation(userEmail: String, friendEmail: String)
    func addMessage(messageTime: String, messageReceiver: [String], messageSender: String, messageSent: String, conversationID: String)

    // Listeners
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}

