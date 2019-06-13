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
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    
    var usersRef: CollectionReference?
    var booksRef: CollectionReference?
    var genresRef: CollectionReference?
    var conversationsRef: CollectionReference?
    var messagesRef: CollectionReference?
    
    var userList: [User]
    var bookList: [Book]
    var genreList: [Genre]
    var conversationList: [Conversation]
    var messageList: [Message]
    
    var conversationIDTrack = 0
    var messageIDTrack = 0
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        userList = [User]()
        bookList = [Book]()
        genreList = [Genre]()
        conversationList = [Conversation]()
        messageList = [Message]()
        
        super.init()
        
        authController.signInAnonymously() {(authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            
            self.setUpListeners()
        }
    }
    
    func setUpListeners() {
        usersRef = database.collection("user")
        usersRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseUserSnapshot(snapshot: querySnapshot!)
        }
        
        booksRef = database.collection("book")
        booksRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseBookSnapshot(snapshot: querySnapshot!)
        }
        
        genresRef = database.collection("genre")
        genresRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseGenreSnapshot(snapshot: querySnapshot!)
        }
        
        conversationsRef = database.collection("conversation")
        conversationsRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseConversationSnapshot(snapshot: querySnapshot!)
        }
        
        messagesRef = database.collection("message")
        messagesRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseMessageSnapshot(snapshot: querySnapshot!)
        }
    }
    
    func parseMessageSnapshot(snapshot: QuerySnapshot!) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            
            var messageReceiver: [String] = []
            
            for userID in change.document.data()["messageReceiver"] as! [String] {
                messageReceiver.append(userID)
            }
            
            let messageSender = change.document.data()["messageSender"] as! String
            let messageSent = change.document.data()["messageSent"] as! String
            let messageTime = change.document.data()["messageTime"] as! Timestamp
            
            if change.type == .added {
                print("New Message: \(change.document.data())")
                let newMessage = Message(messageID: documentRef, messageReceiver: messageReceiver, messageSender: messageSender, messageTime: messageTime, messageSent: messageSent)
                messageList.append(newMessage)
            }
            
            if change.type == .modified {
                print("Updated Message: \(change.document.data())")
                
                let index = getMessageIndexByID(reference: documentRef)!
                messageList[index].messageReceiver = messageReceiver
                messageList[index].messageSender = messageSender
                messageList[index].messageSent = messageSent
                messageList[index].messageTime = messageTime
            }
            
            if change.type == .removed {
                print("Updated Message: \(change.document.data())")
                if let index = getMessageIndexByID(reference: documentRef) {
                    messageList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.message || listener.listenerType == ListenerType.all {
                listener.onMessageChange(change: .update, messages: messageList)
            }
        }
    }
    
    func parseConversationSnapshot(snapshot: QuerySnapshot!) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            
            var conversationMessages: [String] = []
            
            for messageID in change.document.data()["conversationMessages"] as! [String] {
                conversationMessages.append(messageID)
            }
            
            var conversationUsers: [String] = []
            
            for userID in change.document.data()["conversationUsers"] as! [String] {
                conversationUsers.append(userID)
            }
            
            if change.type == .added {
                print("New Conversation: \(change.document.data())")
                let newConversation = Conversation(conversationID: documentRef)
                newConversation.conversationMessages = conversationMessages
                newConversation.conversationUsers = conversationUsers
                conversationList.append(newConversation)
            }
            
            if change.type == .modified {
                print("Updated Conversation: \(change.document.data())")
                
                let index = getConversationIndexByID(reference: documentRef)!
                conversationList[index].conversationMessages = conversationMessages
                conversationList[index].conversationUsers = conversationUsers
            }
            
            if change.type == .removed {
                print("Updated Conversation: \(change.document.data())")
                if let index = getConversationIndexByID(reference: documentRef) {
                    conversationList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.conversation || listener.listenerType == ListenerType.all {
                listener.onConversationChange(change: .update, conversations: conversationList)
            }
        }
    }
    
    func parseBookSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            let bookAuthor = change.document.data()["bookAuthor"] as! String
            let bookDescription = change.document.data()["bookDescription"] as! String
            let bookName = change.document.data()["bookName"] as! String
            
            var bookGenres: [String] = []
            
            for genreID in change.document.data()["bookGenres"] as! [String] {
                bookGenres.append(genreID)
            }
            
            if change.type == .added {
                print("New Book: \(change.document.data())")
                let newBook = Book(bookID: documentRef, bookAuthor: bookAuthor, bookDescription: bookDescription, bookGenres: bookGenres, bookName: bookName)
                bookList.append(newBook)
            }
            
            if change.type == .modified {
                print("Updated Book: \(change.document.data())")
                let index = getBookIndexByID(reference: documentRef)!
                bookList[index].bookID = documentRef
                bookList[index].bookAuthor = bookAuthor
                bookList[index].bookDescription = bookDescription
                bookList[index].bookGenres = bookGenres
                bookList[index].bookName = bookName
            }
            
            if change.type == .removed {
                print("Updated Book: \(change.document.data())")
                if let index = getBookIndexByID(reference: documentRef) {
                    bookList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.book || listener.listenerType == ListenerType.all {
                listener.onBookChange(change: .update, books: bookList)
            }
        }
        
    }
    
    func parseUserSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            let userFirstName = change.document.data()["userFirstName"] as! String
            //let userFirstName = "test"
            let userLastName = change.document.data()["userLastName"] as! String
            //let userLastName = "test"
            let userEmail = change.document.data()["userEmail"] as! String
            //let userEmail = "test"
            let userBio = change.document.data()["userBio"] as! String
            //let userBio = "Enter a bio"
            let userPassword = change.document.data()["userPassword"] as! String
            //let userPassword = "test"
            let userProfilePicture = change.document.data()["userProfilePicture"] as! String
            //let userProfilePicture = "defaultProfilePicture"
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
            
            if change.type == .added {
                print("New user: \(change.document.data())")
                let newUser = User(userFirstName: userFirstName, userLastName: userLastName, userEmail: userEmail, userPassword: userPassword, userBio: userBio, userProfilePicture: userProfilePicture)
                newUser.userFriends = userFriends
                newUser.userBooks = userBooks
                newUser.userConversations = userConversations
                userList.append(newUser)
            }
        
            if change.type == .modified {
                print("Updated User: \(change.document.data())")
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
            }
            
            if change.type == .removed {
                print("Removed User: \(change.document.data())")
                if let index = getUserIndexByID(reference: documentRef) {
                    userList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
                listener.onUserChange(change: .update, users: userList)
            }
        }
    }
    
    func parseGenreSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            let genreType = change.document.data()["genreType"] as! String
            
            if change.type == .added {
                print("New Genre: \(change.document.data())")
                let newGenre = Genre(genreID: documentRef, genreType: genreType)
                genreList.append(newGenre)
            }
            
            if change.type == .modified {
                print("Updated Genre: \(change.document.data())")
                let index = getGenreIndexByID(reference: documentRef)!
                genreList[index].genreID = documentRef
                genreList[index].genreType = genreType
            }
            
            if change.type == .removed {
                print("Removed User: \(change.document.data())")
                if let index = getGenreIndexByID(reference: documentRef) {
                    userList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.genre || listener.listenerType == ListenerType.all {
                listener.onGenreChange(change: .update, genres: genreList)
            }
        }
    }
    
    func getUserIndexByID(reference: String) -> Int? {
        for user in userList {
            if (user.userEmail == reference) {
                return userList.firstIndex(of: user)
            }
        }
        return nil
    }
        
    func getBookIndexByID(reference: String) -> Int? {
        for book in bookList {
            if (book.bookID == reference) {
                return bookList.firstIndex(of: book)
            }
        }
        return nil
    }
    
    func getGenreIndexByID(reference: String) -> Int? {
        for genre in genreList {
            if (genre.genreID == reference) {
                return genreList.firstIndex(of: genre)
            }
        }
        return nil
    }
    
    func getConversationIndexByID(reference: String) -> Int? {
        for conversation in conversationList {
            if conversation.conversationID == reference {
                return conversationList.firstIndex(of: conversation)
            }
        }
        
        return nil
    }
    
    func getMessageIndexByID(reference: String) -> Int? {
        for message in messageList {
            if message.messageID == reference {
                return messageList.firstIndex(of: message)
            }
        }
        return nil
    }
    
    
    func addUser(userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User {
        let userFriends = [String]()
        let userBooks = [String]()
        let userConversations = [String]()
        let userBio = "Enter a bio..."
        let userProfilePicture = "defaultProfilePicture" 
        
        let _ = usersRef?.document(String(userEmail)).setData(["userFirstName": userFirstName, "userLastName": userLastName, "userEmail": userEmail, "userPassword": userPassword, "userBooks": userBooks, "userFriends": userFriends, "userBio": userBio, "userProfilePicture": userProfilePicture, "userConversations": userConversations])
        
        let user = User(userFirstName: userFirstName, userLastName: userLastName, userEmail: userEmail, userPassword: userPassword, userBio: userBio, userProfilePicture: userProfilePicture)
        
        return user
    }
    
    func addBookToUser(userEmail: String, bookID: String) {
        var books: [String] = []
        
        for user in userList {
            if user.userEmail == userEmail {
                for bookID in user.userBooks {
                    books.append(bookID)
                }
            }
        }
        
        books.append(bookID)
        
        let _ = usersRef?.document(String(userEmail)).updateData(["userBooks": books])
    }
    
    func addFriendToUser(userEmail: String, friendEmail: String) {
        var userFriends: [String] = []
        var friendFriends: [String] = []
        
        for user in userList {
            if user.userEmail == userEmail {
                for friendID in user.userFriends {
                    userFriends.append(friendID)
                }
            }
        }
        
        for user in userList {
            if user.userEmail == friendEmail {
                for friendID in user.userFriends {
                    friendFriends.append(friendID)
                }
            }
        }
        
        userFriends.append(friendEmail)
        friendFriends.append(userEmail)
        
        let _ = usersRef?.document(String(friendEmail)).updateData(["userFriends": friendFriends])
        let _ = usersRef?.document(String(userEmail)).updateData(["userFriends": userFriends])
    }
    
    func updateUserBio(userBio: String, userEmail: String) {
        let _ = usersRef?.document(String(userEmail)).updateData(["userBio": userBio])
        
        for user in userList {
            if user.userEmail == userEmail {
                user.userBio = userBio
            }
        }
    }
    
    func updateUserProfilePicture(userProfilePicture: String, userEmail: String) {
        let _ = usersRef?.document(String(userEmail)).updateData(["userProfilePicture": userProfilePicture])
        
        for user in userList {
            if user.userEmail == userEmail {
                user.userProfilePicture = userProfilePicture
            }
        }
    }

    func deleteBook(book: Book, user: User) {
        var userBooks: [String] = []
        var removedBooks: [String] = []
        
        for u in userList {
            if u.userEmail == user.userEmail {
                userBooks = u.userBooks
            }
        }
        
        for bookID in userBooks {
            if bookID != book.bookID {
                removedBooks.append(bookID)
            }
        }
        
        let _ = usersRef?.document(String(user.userEmail)).updateData(["userBooks": removedBooks])
    }
    
    func addConversation(userEmail: String, friendEmail: String) {
        let conversationMessages = [String]()
        var conversationUsers:[String] = []
        let conversationID = self.conversationIDTrack + 1
        
        conversationUsers.append(userEmail)
        conversationUsers.append(friendEmail)
    
        let _ = conversationsRef?.document(String(conversationID)).setData(["conversationMessages": conversationMessages, "conversationUsers": conversationUsers])
        //let newConversation = Conversation(conversationID: String(conversationID))
        
        var uConversations:[String] = []
        
        for user in userList {
            if user.userEmail == userEmail {
                for conversation in user.userConversations {
                    uConversations.append(conversation)
                }
            }
        }
        
        uConversations.append(String(conversationID))
        
        var fConversations:[String] = []
        
        for user in userList {
            if user.userEmail == friendEmail {
                for conversation in user.userConversations {
                    fConversations.append(conversation)
                }
            }
        }
        
        fConversations.append(String(conversationID))
        
        let _ = usersRef?.document(String(userEmail)).updateData(["userConversations": uConversations])
        let _ = usersRef?.document(String(friendEmail)).updateData(["userConversations": fConversations])
        
        self.conversationIDTrack += 1
    }
    
    func addMessage(messageTime: Timestamp, messageReceiver: [String], messageSender: String, messageSent: String, conversationID: String) {
        let messageTime = messageTime
        let messageReceiver = messageReceiver
        let messageSender = messageSender
        let messageSent = messageSent
        let messageID = self.messageIDTrack + 1
        
        var messagesList:[String] = []
        
        for conversation in conversationList {
            if conversation.conversationID == conversationID {
                for message in conversation.conversationMessages! {
                    messagesList.append(message)
                }
            }
        }
        
        messagesList.append(String(messageID))
        
        let _ = conversationsRef?.document(conversationID).updateData(["conversationMessages": messagesList])
        
        let _ = messagesRef?.document(String(messageID)).setData(["messageReceiver": messageReceiver, "messageSender": messageSender, "messageSent": messageSent, "messageTime": messageTime])
        
        self.messageIDTrack += 1
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
            listener.onUserChange(change: .update, users: userList)
        }
        
        if listener.listenerType == ListenerType.book || listener.listenerType == ListenerType.all {
            listener.onBookChange(change: .update, books: bookList)
        }
        
        if listener.listenerType == ListenerType.genre || listener.listenerType == ListenerType.all {
            listener.onGenreChange(change: .update, genres: genreList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
