//
//  BookSegmentViewController.swift
//  Assignment1_project
//
//  Created by ME on 21/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class BookSegmentViewController: UIViewController, UISearchBarDelegate, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
   
    

    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?

    // Table view
    @IBOutlet weak var bookTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // The user that has logged on
    var loggedOnUser: User?
    var trackUser: User?
    
    // Selected view
    var selectView: String?

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
    
    // MARK: - TableView Content
    
    // Listener
    var listenerType = ListenerType.all
    
    // Variables
    let SECTION_ADDBOOK = 0
    let SECTION_BOOKS = 1
    let CELL_ADDBOOK = "addBook"
    let CELL_BOOK = "book"
    
    var allBooks: [Book] = []
    var filteredBooks: [Book] = []
    
    // When the user is changed
    func onUserChange(change: DatabaseChange, users: [User]) {
   
        for user in users {
            if user.userEmail == loggedOnUser?.userEmail {
                loggedOnUser = user
            }
            
            if selectView == "People" {
                if user.userEmail == trackUser?.userEmail {
                    trackUser = user
                }
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        allBooks = []
        filteredBooks = []
        
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
            for bookID in loggedOnUser!.userBooks {
                for book in books {
                    if bookID == book.bookID {
                        allBooks.append(book)
                        filteredBooks.append(book)
                    }
                }
            }
        }
    }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        
    }
    
    func onConversationChange(change: DatabaseChange, conversations genres: [Conversation]) {
        
    }
    
    func onMessageChange(change: DatabaseChange, messages genres: [Message]) {
        
    }
    
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
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // there are two sections therefore return 2
        
        if selectView == "People" {
            return 2
        }
            
        else {
            return 2
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == SECTION_BOOKS
        {
            return filteredBooks.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.section == SECTION_ADDBOOK {
            // gets the count for the tasks and puts it in a new cell
            // this will then be displayed in the countCell row
            let addBookCell = tableView.dequeueReusableCell(withIdentifier: CELL_ADDBOOK, for: indexPath)
            return addBookCell
        }
        
        let bookCell = tableView.dequeueReusableCell(withIdentifier: CELL_BOOK, for: indexPath) as! BookTableViewCell
        let book = filteredBooks[indexPath.row]
        
        bookCell.bookNameLabel.text = book.bookName
        
        return bookCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if selectView != "People" {
            if editingStyle == .delete && indexPath.section == SECTION_BOOKS {
                databaseController!.deleteBook(book: filteredBooks[indexPath.row], user: loggedOnUser!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // checks whether or not the row is a task
        if indexPath.section == SECTION_BOOKS {
            return true
        }
        return false
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
