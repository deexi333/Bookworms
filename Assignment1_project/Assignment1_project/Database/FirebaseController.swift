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
    }
    
    func parseUserSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            let userFirstName = change.document.data()["userFirstName"] as! String
            let userLastName = change.document.data()["userLastName"] as! String
            let userEmail = change.document.data()["userEmail"] as! String
            let userBio = change.document.data()["userBio"] as! String
            let userPassword = change.document.data()["userPassword"] as! String
            let userBooks = change.document.data()["userBooks"] as! [String]
            let userFriends = change.document.data()["userFriends"] as! [String]
            //let userProfilePicture = change.document.data()["userProfilePicture"] as! String
            let userProfilePicture = "defaultProfilePicture"
            
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
                userList[index].userBooks = [String]()
                userList[index].userFriends = [String]()
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
                listener.onUserChange(change: .update, user: userList)
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
    
    func addUser(userFirstName: String, userLastName: String, userEmail: String, userPassword: String) -> User {
        let userFriends = [String]()
        let userBooks = [String]()
        let userBio = "Enter a bio..."
        let userProfilePicture = "defaultProfilePicture"
        
        let _ = usersRef?.document(String(userEmail)).setData(["userFirstName": userFirstName, "userLastName": userLastName, "userEmail": userEmail, "userPassword": userPassword, "userBooks": userBooks, "userFriends": userFriends, "userBio": userBio, "userProfilePciture": userProfilePicture])
        
        let user = User(userFirstName: userFirstName, userLastName: userLastName, userEmail: userEmail, userPassword: userPassword, userBio: userBio, userProfilePicture: userProfilePicture)
        
        return user
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
    
    func checkUser(email: String) -> Bool {
        for user in userList {
            if user.userEmail == email {
                return true
            }
        }
        
        return false
    }
    
    func getUsers() -> [User] {
        return userList
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
            listener.onUserChange(change: .update, user: userList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
