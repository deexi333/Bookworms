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
    var addBook: Bool?
    weak var databaseController: DatabaseProtocol?
    
    // Linked to storyboard variables
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var addBookButton: UIButton!
    
    // Listener variables
    var listenerType = ListenerType.all
    var allGenres: [Genre] = []
    var allBooks: [Book] = []
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        for user in users {
            if loggedOnUser?.userEmail == user.userEmail {
                loggedOnUser = user
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        allBooks = books
        
        for book in books {
            if book.bookID == currentBook?.bookID {
                currentBook = book
            }
        }
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        allGenres = genres
    }
    
    @IBAction func addBookAction(_ sender: Any) {
        databaseController!.addBookToUser(userEmail: loggedOnUser!.userEmail, bookID: currentBook!.bookID!)
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // use the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        navigationItem.title = currentBook!.bookName
        descriptionLabel.text = currentBook!.bookDescription
        
        authorLabel.text = currentBook!.bookAuthor
        
        if !addBook! {
            addBookButton.isHidden = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
