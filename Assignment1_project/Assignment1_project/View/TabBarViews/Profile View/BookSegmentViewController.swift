//
//  BookSegmentViewController.swift
//  Assignment1_project
//
//  Created by ME on 21/5/19.
//  Copyright © 2019 Monash University. All rights reserved.


import UIKit

class BookSegmentViewController: UIViewController, UISearchBarDelegate, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
   
    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?

    // Elements from the storyboard
    @IBOutlet weak var bookTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // The user that has logged on
    var loggedOnUser: User?
    var trackUser: User?
    
    // Selected view
    var selectView: String?
    
    // Listener
    var listenerType = ListenerType.all
    
    // All the books in the application
    var allBooks: [Book] = []
    // Filtered books
    var filteredBooks: [Book] = []

    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // App delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Search
        searchBar.delegate = self
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        // Initialise table view
        bookTableView.reloadData()
        bookTableView.delegate = self
        bookTableView.dataSource = self
        bookTableView.reloadData()
    }
    
    
    // MARK: - Fixing the keyboard
    // Return button makes the keyboard dissapear
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    // MARK: - Database Protocols
    func onUserChange(change: DatabaseChange, users: [User]) {
        // iterate through the user
        for user in users {
            if user.userEmail == loggedOnUser?.userEmail {
                // get the updated logged in user
                loggedOnUser = user
            }
            
            if selectView == "People" {
                // if the view is people then get the tracked user
                if user.userEmail == trackUser?.userEmail {
                    trackUser = user
                }
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        allBooks = []
        filteredBooks = []
        
        // if the view is people
        if selectView != "People" {
            // get all the books of the user
            for bookID in loggedOnUser!.userBooks {
                for book in books {
                    if bookID == book.bookID {
                        allBooks.append(book)
                        filteredBooks.append(book)
                    }
                }
            }
        }
            
        else {
            for bookID in trackUser!.userBooks {
                for book in books {
                    if bookID == book.bookID {
                        allBooks.append(book)
                        filteredBooks.append(book)
                    }
                }
            }
        }
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }
    
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) { }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) { }
    
    
    // View will appear and disappear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        databaseController?.addListener(listener: self)
        self.bookTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
        self.bookTableView.reloadData()
    }
    
    
    // MARK: - TableView
    // Variables
    var SECTION_ADDBOOK = 0
    var SECTION_BOOKS = 1
    let CELL_ADDBOOK = "addBook"
    let CELL_BOOK = "book"
    
    // Functions
    // This method updates filteredBooks based on the searchText
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the search textis not emptythen get allBooks
        filteredBooks = searchText.isEmpty ? allBooks : allBooks.filter({(dataString: Book) -> Bool in
            // return the entries that have the same name as the search text
            return dataString.bookName?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        // reload the data
        bookTableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // there are two sections therefore return 2
        // However when the view is for people there is only 1
        if selectView == "People" {
            SECTION_BOOKS = 0
            SECTION_ADDBOOK = 1
            return 1
            
        }
        else {
            SECTION_ADDBOOK = 0
            SECTION_BOOKS = 1
            return 2
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectView == "People" {
            if section == SECTION_BOOKS {
                return filteredBooks.count
            }
            else {
                return 0
            }
        }
        
        else {
            if section == SECTION_BOOKS
            {
                return filteredBooks.count
            }
            else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.section == SECTION_BOOKS {
            // gets the count for the tasks and puts it in a new cell
            // this will then be displayed in the countCell row
            let bookCell = tableView.dequeueReusableCell(withIdentifier: CELL_BOOK, for: indexPath) as! BookTableViewCell
            let book = filteredBooks[indexPath.row]
            
            bookCell.bookNameLabel.text = book.bookName
            
            return bookCell
        }
        
        else {
            let addBookCell = tableView.dequeueReusableCell(withIdentifier: CELL_ADDBOOK, for: indexPath)
            return addBookCell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if selectView != "People" {
            if editingStyle == .delete && indexPath.section == SECTION_BOOKS {
                databaseController!.deleteBook(book: filteredBooks[indexPath.row], user: loggedOnUser!)
                self.bookTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if selectView != "People" {
            // checks whether or not the row is a task
            if indexPath.section == SECTION_BOOKS {
                return true
            }
            return false
        }
        else {
            return false
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetailsSegue" {
            let destination = segue.destination as! BookDetailViewController
            destination.addBook = false
            destination.trackUser = self.trackUser
            destination.currentBook = self.filteredBooks[bookTableView.indexPathForSelectedRow!.row]
        }
        
        if segue.identifier == "addBookSegue" {
            let destination = segue.destination as! AddBookViewController
            destination.loggedOnUser = self.loggedOnUser
        }
    }
}
