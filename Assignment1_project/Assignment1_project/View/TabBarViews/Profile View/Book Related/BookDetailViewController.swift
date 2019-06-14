//
//  BookDetailViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController, DatabaseListener {

    // MARK: - Variables
    var currentBook: Book?
    var loggedOnUser: User?
    // tracked user
    var trackUser: User?
    var addBook: Bool?
    
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // Linked to storyboard variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var addBookButton: UIButton!
    
    // Listener variables
    var listenerType = ListenerType.all
    
    // all the genres in the application
    var allGenres: [Genre] = []
    // all the books in the application
    var allBooks: [Book] = []
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // use the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        databaseController = appDelegate.databaseController
        
        navigationItem.title = "Chosen Book"
        
        titleLabel.text = currentBook!.bookName
        
        descriptionLabel.text = currentBook!.bookDescription
        
        authorLabel.text = currentBook!.bookAuthor
        
        if !addBook! {
            addBookButton.isHidden = true
        }
    }
    
    
    // MARK: - Database Protocol
    func onUserChange(change: DatabaseChange, users: [User]) {
        // iterate through all the users
        for user in users {
            // get the logged on user
            if loggedOnUser?.userEmail == user.userEmail {
                loggedOnUser = user
            }
            
            // get the track user
            if trackUser?.userEmail == user.userEmail {
                trackUser = user
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        allBooks = books
        
        // Get the details of the current book
        for book in books {
            if book.bookID == currentBook?.bookID {
                currentBook = book
            }
        }
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        allGenres = genres
        
        var genresDescription = ""
        
        // set the description of the genre
        for genreID in currentBook!.bookGenres {
            for genre in allGenres {
                if genre.genreID == genreID {
                    genresDescription += "\(String(genre.genreType!))\n"
                }
            }
        }
        
        // set the test of the genre
        genresLabel.text = genresDescription
    }
    
    func onConversationChange(change: DatabaseChange, conversations: [Conversation]) { }
    
    func onMessageChange(change: DatabaseChange, messages: [Message]) { }
    
    
    // MARK: - Functions from the Storyboard
    @IBAction func addBookAction(_ sender: Any) {
        databaseController!.addBookToUser(userEmail: loggedOnUser!.userEmail, bookID: currentBook!.bookID!)
    }
    
    
    // MARK: - View will appear and disappear functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
    }
    
   
    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
    */

}
