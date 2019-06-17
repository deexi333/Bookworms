//
//  FirebaseController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    
    // MARK: - Variables
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    
    // references
    var usersRef: CollectionReference?
    var booksRef: CollectionReference?
    var genresRef: CollectionReference?
    var conversationsRef: CollectionReference?
    var messagesRef: CollectionReference?
    
    // Lists
    var userList: [User]
    var bookList: [Book]
    var genreList: [Genre]
    var conversationList: [Conversation]
    var messageList: [Message]
    
    // Tracking the IDs
    var conversationIDTrack = 0
    var messageIDTrack = 0
    
    override init() {
        
        
        // Configure firebase
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        // Initialise the lists
        userList = [User]()
        bookList = [Book]()
        genreList = [Genre]()
        conversationList = [Conversation]()
        messageList = [Message]()

        super.init()
        
        // Authentication
        authController.signInAnonymously() {(authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            
            self.setUpListeners()
        }
    }
    
    // Setting up the listeners
    func setUpListeners() {
        // User ref
        usersRef = database.collection("user")
        usersRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseUserSnapshot(snapshot: querySnapshot!)
        }
        
        // Book ref
        booksRef = database.collection("book")
        booksRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseBookSnapshot(snapshot: querySnapshot!)
        }
        
        // Genre ref
        genresRef = database.collection("genre")
        genresRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseGenreSnapshot(snapshot: querySnapshot!)
        }
        
        // Conversation ref
        conversationsRef = database.collection("conversation")
        conversationsRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseConversationSnapshot(snapshot: querySnapshot!)
        }
        
        
        // Message ref
        messagesRef = database.collection("message")
        messagesRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseMessageSnapshot(snapshot: querySnapshot!)
        }
    }
    
    // parse the message snapshot
    func parseMessageSnapshot(snapshot: QuerySnapshot!) {
        // Go through each document
        snapshot.documentChanges.forEach { change in
            // Variables for the message
            let documentRef = change.document.documentID
            let messageSender = change.document.data()["messageSender"] as! String
            let messageSent = change.document.data()["messageSent"] as! String
            let messageTime = change.document.data()["messageTime"] as! String
            var messageReceiver: [String] = []
            
            // Getting each user
            for userID in change.document.data()["messageReceiver"] as! [String] {
                messageReceiver.append(userID)
            }
            
            // ADD
            if change.type == .added {
                print("New Message: \(change.document.data())")
                let newMessage = Message(messageID: documentRef, messageReceiver: messageReceiver, messageSender: messageSender, messageTime: messageTime, messageSent: messageSent)
                // Adding the new messages
                messageList.append(newMessage)
            }
            
            // UPDATE
            if change.type == .modified {
                print("Updated Message: \(change.document.data())")
                
                // The variables for the update
                let index = getMessageIndexByID(reference: documentRef)!
                messageList[index].messageReceiver = messageReceiver
                messageList[index].messageSender = messageSender
                messageList[index].messageSent = messageSent
                messageList[index].messageTime = messageTime
            }
            
            // REMOVE
            if change.type == .removed {
                print("Removed Message: \(change.document.data())")
                // Get the index
                if let index = getMessageIndexByID(reference: documentRef) {
                    messageList.remove(at: index)
                }
            }
        }
        
        // Invoke listeners
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.message || listener.listenerType == ListenerType.all {
                listener.onMessageChange(change: .update, messages: messageList)
            }
        }
    }
    
    // parse the conversation snapshot
    func parseConversationSnapshot(snapshot: QuerySnapshot!) {
        // go through each document
        snapshot.documentChanges.forEach { change in
            // variables for conversations
            let documentRef = change.document.documentID
            var conversationMessages: [String] = []
            
            for messageID in change.document.data()["conversationMessages"] as! [String] {
                conversationMessages.append(messageID)
            }
            
            var conversationUsers: [String] = []
            
            for userID in change.document.data()["conversationUsers"] as! [String] {
                conversationUsers.append(userID)
            }
            
            // ADD
            if change.type == .added {
                print("New Conversation: \(change.document.data())")
                let newConversation = Conversation(conversationID: documentRef)
                newConversation.conversationMessages = conversationMessages
                newConversation.conversationUsers = conversationUsers
                // Add the conversation
                conversationList.append(newConversation)
            }
            
            // UPDATE
            if change.type == .modified {
                print("Updated Conversation: \(change.document.data())")
                
                // The variables needed for conversation
                let index = getConversationIndexByID(reference: documentRef)!
                conversationList[index].conversationMessages = conversationMessages
                conversationList[index].conversationUsers = conversationUsers
            }
            
            // REMOVE
            if change.type == .removed {
                print("Removed Conversation: \(change.document.data())")
                // get the index
                if let index = getConversationIndexByID(reference: documentRef) {
                    conversationList.remove(at: index)
                }
            }
        }
        
        // Invoke the listeners
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.conversation || listener.listenerType == ListenerType.all {
                listener.onConversationChange(change: .update, conversations: conversationList)
            }
        }
    }
    
    // parse book snapshot
    func parseBookSnapshot(snapshot: QuerySnapshot) {
        // for each document
        snapshot.documentChanges.forEach { change in
            // variables for book
            let documentRef = change.document.documentID
            let bookAuthor = change.document.data()["bookAuthor"] as! String
            let bookDescription = change.document.data()["bookDescription"] as! String
            let bookName = change.document.data()["bookName"] as! String
            
            var bookGenres: [String] = []
            
            for genreID in change.document.data()["bookGenres"] as! [String] {
                bookGenres.append(genreID)
            }
            
            // ADD
            if change.type == .added {
                print("New Book: \(change.document.data())")
                let newBook = Book(bookID: documentRef, bookAuthor: bookAuthor, bookDescription: bookDescription, bookGenres: bookGenres, bookName: bookName)
                // append the new book
                bookList.append(newBook)
            }
            
            // UPDATE
            if change.type == .modified {
                print("Updated Book: \(change.document.data())")
                // the variables needed for book
                let index = getBookIndexByID(reference: documentRef)!
                bookList[index].bookID = documentRef
                bookList[index].bookAuthor = bookAuthor
                bookList[index].bookDescription = bookDescription
                bookList[index].bookGenres = bookGenres
                bookList[index].bookName = bookName
            }
            
            if change.type == .removed {
                print("Removed Book: \(change.document.data())")
                if let index = getBookIndexByID(reference: documentRef) {
                    bookList.remove(at: index)
                }
            }
        }
        
        // Invoke listeners
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.book || listener.listenerType == ListenerType.all {
                listener.onBookChange(change: .update, books: bookList)
            }
        }
        
    }
    
    // parse user snapshot
    func parseUserSnapshot(snapshot: QuerySnapshot) {
        // for each document
        snapshot.documentChanges.forEach { change in
            // Variables for User
            let documentRef = change.document.documentID
            let userFirstName = change.document.data()["userFirstName"] as! String
            let userLastName = change.document.data()["userLastName"] as! String
            let userEmail = change.document.data()["userEmail"] as! String
            let userBio = change.document.data()["userBio"] as! String
            let userPassword = change.document.data()["userPassword"] as! String
            let userProfilePicture = change.document.data()["userProfilePicture"] as! String
            let userCameraAcceptance = change.document.data()["userCameraAcceptance"] as! String
          
            var userBooks: [String] = []
            
            for bookID in change.document.data()["userBooks"] as! [String] {
                userBooks.append(bookID)
            }
            
            var userFriends: [String] = []
            
            for friendID in change.document.data()["userFriends"] as! [String] {
                userFriends.append(friendID)
            }
            
            var userConversations: [String] = []
            
            for conversationID in change.document.data()["userConversations"] as! [String] {
                userConversations.append(conversationID)
            }
            
            // ADD
            if change.type == .added {
                print("New user: \(change.document.data())")
                let newUser = User(userFirstName: userFirstName, userLastName: userLastName, userEmail: userEmail, userPassword: userPassword, userBio: userBio, userProfilePicture: userProfilePicture)
                newUser.userFriends = userFriends
                newUser.userBooks = userBooks
                newUser.userConversations = userConversations
                newUser.userCameraAcceptance = userCameraAcceptance
                // Append the new user
                userList.append(newUser)
            }
            
            // UPDATE
            if change.type == .modified {
                print("Updated User: \(change.document.data())")
                // The needed variables for user
                let index = getUserIndexByID(reference: documentRef)!
                userList[index].userFirstName = userFirstName
                userList[index].userLastName = userLastName
                userList[index].userEmail = userEmail
                userList[index].userBio = userBio
                userList[index].userPassword = userPassword
                userList[index].userBooks = userBooks
                userList[index].userFriends = userFriends
                userList[index].userProfilePicture = userProfilePicture
                userList[index].userConversations = userConversations
                userList[index].userCameraAcceptance = userCameraAcceptance
            }
            
            // REMOVE
            if change.type == .removed {
                print("Removed User: \(change.document.data())")
                if let index = getUserIndexByID(reference: documentRef) {
                    userList.remove(at: index)
                }
            }
        }
        
        // Invoke listeners
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
                listener.onUserChange(change: .update, users: userList)
            }
        }
    }
    
    // parse genre snapshot
    func parseGenreSnapshot(snapshot: QuerySnapshot) {
        // for each document
        snapshot.documentChanges.forEach { change in
            // Variables for genre
            let documentRef = change.document.documentID
            let genreType = change.document.data()["genreType"] as! String
            
            // ADD
            if change.type == .added {
                print("New Genre: \(change.document.data())")
                let newGenre = Genre(genreID: documentRef, genreType: genreType)
                // Append the new genre
                genreList.append(newGenre)
            }
            
            // UPDATE
            if change.type == .modified {
                print("Updated Genre: \(change.document.data())")
                // The needed variables for genre
                let index = getGenreIndexByID(reference: documentRef)!
                genreList[index].genreID = documentRef
                genreList[index].genreType = genreType
            }
            
            // REMOVE
            if change.type == .removed {
                print("Removed User: \(change.document.data())")
                if let index = getGenreIndexByID(reference: documentRef) {
                    userList.remove(at: index)
                }
            }
        }
        
        // invoke listeners
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.genre || listener.listenerType == ListenerType.all {
                listener.onGenreChange(change: .update, genres: genreList)
            }
        }
    }
    
    // get the index of the user
    func getUserIndexByID(reference: String) -> Int? {
        for user in userList {
            if (user.userEmail == reference) {
                return userList.firstIndex(of: user)
            }
        }
        return nil
    }
    
    // get the index of the book
    func getBookIndexByID(reference: String) -> Int? {
        for book in bookList {
            if (book.bookID == reference) {
                return bookList.firstIndex(of: book)
            }
        }
        return nil
    }
    
    // get the index of the genre
    func getGenreIndexByID(reference: String) -> Int? {
        for genre in genreList {
            if (genre.genreID == reference) {
                return genreList.firstIndex(of: genre)
            }
        }
        return nil
    }
    
    // get the index of the conversation
    func getConversationIndexByID(reference: String) -> Int? {
        for conversation in conversationList {
            if conversation.conversationID == reference {
                return conversationList.firstIndex(of: conversation)
            }
        }
        
        return nil
    }
    
    // get the index of the message
    func getMessageIndexByID(reference: String) -> Int? {
        for message in messageList {
            if message.messageID == reference {
                return messageList.firstIndex(of: message)
            }
        }
        return nil
    }
    
    // MARK: - Database Protocols
    // add a user
    func addUser(userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User {
        let userFriends = [String]()
        let userBooks = [String]()
        let userConversations = [String]()
        let userBio = "Enter a bio..."
        let userProfilePicture = "defaultProfilePicture"
        let userCameraAcceptance = "false"
        
        // add the new user
        let _ = usersRef?.document(String(userEmail)).setData(["userFirstName": userFirstName, "userLastName": userLastName, "userEmail": userEmail, "userPassword": userPassword, "userBooks": userBooks, "userFriends": userFriends, "userBio": userBio, "userProfilePicture": userProfilePicture, "userConversations": userConversations, "userCameraAcceptance": userCameraAcceptance])
        
        let user = User(userFirstName: userFirstName, userLastName: userLastName, userEmail: userEmail, userPassword: userPassword, userBio: userBio, userProfilePicture: userProfilePicture)
        
        // return the user
        return user
    }
    
    // add a book to the user
    func addBookToUser(userEmail: String, bookID: String) {
        var books: [String] = []
        
        // iterate through the userList
        for user in userList {
            // if the useremail is the same as the logged on user
            if user.userEmail == userEmail {
                // append the users current books
                for bookID in user.userBooks {
                    books.append(bookID)
                }
            }
        }
        
        // Add the new bookID
        books.append(bookID)
        
        // Update the user
        let _ = usersRef?.document(String(userEmail)).updateData(["userBooks": books])
    }
    
    // update the user camera acceptance
    func updateUserCameraAcceptance(userEmail: String, userCameraAcceptance: String) {
        // Change the user camera acceptance
        for user in userList {
            if user.userEmail == userEmail {
                user.userCameraAcceptance = userCameraAcceptance
            }
        }
        
        // Update the users cameraAcceptance
        let _ = usersRef?.document(String(userEmail)).updateData(["userCameraAcceptance": userCameraAcceptance])
    }
    
    
    // add a friend to the user
    func addFriendToUser(userEmail: String, friendEmail: String) {
        var userFriends: [String] = []
        var friendFriends: [String] = []
        
        // iterate through the userList of the logged on user
        for user in userList {
            if user.userEmail == userEmail {
                for friendID in user.userFriends {
                    // add all the current friends
                    userFriends.append(friendID)
                }
            }
        }
        
        // iterate through the userList of the friend
        for user in userList {
            if user.userEmail == friendEmail {
                for friendID in user.userFriends {
                    // add all their current friends
                    friendFriends.append(friendID)
                }
            }
        }
        
        // Append the new users
        userFriends.append(friendEmail)
        friendFriends.append(userEmail)
        
        // Update the userRef
        let _ = usersRef?.document(String(friendEmail)).updateData(["userFriends": friendFriends])
        let _ = usersRef?.document(String(userEmail)).updateData(["userFriends": userFriends])
    }
    
    // Update the user bio
    func updateUserBio(userBio: String, userEmail: String) {
        // update the user bio
        let _ = usersRef?.document(String(userEmail)).updateData(["userBio": userBio])
        
        // change the user bio in the userList for the user
        for user in userList {
            if user.userEmail == userEmail {
                user.userBio = userBio
            }
        }
    }
    
    // Update the profile picture
    func updateUserProfilePicture(userProfilePicture: String, userEmail: String) {
        // update the profile picture
        let _ = usersRef?.document(String(userEmail)).updateData(["userProfilePicture": userProfilePicture])
        
        // change the profile picture in the userList for the user
        for user in userList {
            if user.userEmail == userEmail {
                user.userProfilePicture = userProfilePicture
            }
        }
    }
    
    // Delete a given book
    func deleteBook(book: Book, user: User) {
        var userBooks: [String] = []
        var removedBooks: [String] = []
        
        // get all the books from the userList of the user
        for u in userList {
            if u.userEmail == user.userEmail {
                userBooks = u.userBooks
            }
        }
        
        // The books without the removed book
        for bookID in userBooks {
            if bookID != book.bookID {
                removedBooks.append(bookID)
            }
        }
        
        // update the user
        let _ = usersRef?.document(String(user.userEmail)).updateData(["userBooks": removedBooks])
    }
    
    // Add a conversation
    func addConversation(userEmail: String, friendEmail: String) {
        let conversationMessages = [String]()
        var conversationUsers:[String] = []
        let conversationID = self.conversationIDTrack + 1
        
        conversationUsers.append(userEmail)
        conversationUsers.append(friendEmail)
    
        // add the new conversation
        let _ = conversationsRef?.document(String(conversationID)).setData(["conversationMessages": conversationMessages, "conversationUsers": conversationUsers])
        //let newConversation = Conversation(conversationID: String(conversationID))
        
         self.conversationIDTrack += 1
        
        // the user conversations
        var uConversations:[String] = []
        
        // append the current conversations that the usre has
        for user in userList {
            if user.userEmail == userEmail {
                for conversation in user.userConversations {
                    uConversations.append(conversation)
                }
            }
        }
        
        // append the new conversation
        uConversations.append(String(conversationID))
        
        // the friend conversations
        var fConversations:[String] = []
        
        // append the current conversations that he friend has
        for user in userList {
            if user.userEmail == friendEmail {
                for conversation in user.userConversations {
                    fConversations.append(conversation)
                }
            }
        }
        
        // append the new conversation
        fConversations.append(String(conversationID))
        
        // update the user
        let _ = usersRef?.document(String(userEmail)).updateData(["userConversations": uConversations])
        let _ = usersRef?.document(String(friendEmail)).updateData(["userConversations": fConversations])
    }
    
    
    // adding a message
    func addMessage(messageTime: String, messageReceiver: [String], messageSender: String, messageSent: String, conversationID: String) {
        let messageTime = messageTime
        let messageReceiver = messageReceiver
        let messageSender = messageSender
        let messageSent = messageSent
        let messageID = self.messageIDTrack + 1
        
        var messagesList:[String] = []
        
        // get all the messages in a conversation
        for conversation in conversationList {
            if conversation.conversationID == conversationID {
                for message in conversation.conversationMessages! {
                    messagesList.append(message)
                }
            }
        }
        
        // append the new message
        messagesList.append(String(messageID))
        
        // update the conversation
        let _ = conversationsRef?.document(conversationID).updateData(["conversationMessages": messagesList])
    
        // add the new message
        let _ = messagesRef?.document(String(messageID)).setData(["messageReceiver": messageReceiver, "messageSender": messageSender, "messageSent": messageSent, "messageTime": messageTime])
        
        // incrementing the user track
        self.messageIDTrack += 1
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        // USER
        if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
            listener.onUserChange(change: .update, users: userList)
        }
        
        // BOOK
        if listener.listenerType == ListenerType.book || listener.listenerType == ListenerType.all {
            listener.onBookChange(change: .update, books: bookList)
        }
        
        // GENRE
        if listener.listenerType == ListenerType.genre || listener.listenerType == ListenerType.all {
            listener.onGenreChange(change: .update, genres: genreList)
        }
        
        // CONVERSATION
        if listener.listenerType == ListenerType.conversation || listener.listenerType == ListenerType.all {
            listener.onConversationChange(change: .update, conversations: conversationList)
        }
        
        // MESSAGE
        if listener.listenerType == ListenerType.message || listener.listenerType == ListenerType.all {
            listener.onMessageChange(change: .update, messages: messageList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
