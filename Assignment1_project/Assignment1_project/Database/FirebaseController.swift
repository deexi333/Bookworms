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
    
    var userList: [User]
    var bookList: [Book]
    var genreList: [Genre]
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        userList = [User]()
        bookList = [Book]()
        genreList = [Genre]()
        
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
    }
    
    func parseBookSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            let bookAuthor = change.document.data()["bookAuthor"] as! String
            let bookDescription = change.document.data()["bookDescription"] as! String
            let bookName = change.document.data()["bookName"] as! String
            
            var bookGenre: [String] = []
            
            for genre in change.document.data()["bookGenres"] as! [String] {
                print(genre)
                bookGenre.append(genre)
            }
            
            if change.type == .added {
                print("New Book: \(change.document.data())")
                let newBook = Book(bookID: documentRef, bookAuthor: bookAuthor, bookDescription: bookDescription, bookGenre: bookGenre, bookName: bookName)
                bookList.append(newBook)
            }
            
            if change.type == .modified {
                print("Updated Book: \(change.document.data())")
                let index = getBookIndexByID(reference: documentRef)!
                bookList[index].bookID = documentRef
                bookList[index].bookAuthor = bookAuthor
                bookList[index].bookDescription = bookDescription
                bookList[index].bookGenre = bookGenre
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
            let userLastName = change.document.data()["userLastName"] as! String
            let userEmail = change.document.data()["userEmail"] as! String
            let userBio = change.document.data()["userBio"] as! String
            let userPassword = change.document.data()["userPassword"] as! String
            let userProfilePicture = change.document.data()["userProfilePicture"] as! String
            //let userProfilePicture = "defaultProfilePicture"
            var userBooks: [String] = []
            
            for book in change.document.data()["userBooks"] as! [String] {
                userBooks.append(book)
            }
            
            var userFriends: [String] = []
            
            for friend in change.document.data()["userFriends"] as! [String] {
                userFriends.append(friend)
            }
            
            if change.type == .added {
                print("New user: \(change.document.data())")
                let newUser = User(userFirstName: userFirstName, userLastName: userLastName, userEmail: userEmail, userPassword: userPassword, userBio: userBio, userProfilePicture: userProfilePicture)
                newUser.userBooks = userBooks
                newUser.userFriends = userFriends
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
                let newGenre = Genre(genreId: documentRef, genreType: genreType)
                genreList.append(newGenre)
            }
            
            if change.type == .modified {
                print("Updated Genre: \(change.document.data())")
                let index = getGenreIndexByID(reference: documentRef)!
                genreList[index].genreId = documentRef
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
            if listener.listenerType == ListenerType.book || listener.listenerType == ListenerType.all {
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
            if (genre.genreId == reference) {
                return genreList.firstIndex(of: genre)
            }
        }
        return nil
    }
    
    func addUser(userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User {
        let userFriends = [String]()
        let userBooks = [String]()
        let userBio = "Enter a bio..."
        let userProfilePicture = "defaultProfilePicture"
        
        let _ = usersRef?.document(String(userEmail)).setData(["userFirstName": userFirstName, "userLastName": userLastName, "userEmail": userEmail, "userPassword": userPassword, "userBooks": userBooks, "userFriends": userFriends, "userBio": userBio, "userProfilePicture": userProfilePicture])
        
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
        
        for u in userList {
            if u.userEmail == user.userEmail {
                for i in 0...user.userBooks.count {
                    if user.userBooks[i] == book.bookID {
                        u.userBooks.remove(at: i)
                         let _ = usersRef?.document(String(user.userEmail)).updateData(["userBooks": u.userBooks])
                    }
                }
            }
        }
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
