//
//  AddBookViewController.swift
//  Assignment1_project
//
//  Created by ME on 23/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController, UISearchBarDelegate, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // links to storyboard
    @IBOutlet weak var allBooksTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Firebase variables
    var loggedOnUser: User?
    
    // Listener
    var listenerType = ListenerType.all
    
    // All the users in the application
    var allUsers: [User] = []
    // All the books in the application
    var allBooks: [Book] = []
    // Filtered books
    var filteredBooks: [Book] = []
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad was called")
        
        // App delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Search set up
        searchBar.delegate = self
        definesPresentationContext = true
        
        // Initialise table view
        allBooksTableView.reloadData()
        allBooksTableView.delegate  = self
        allBooksTableView.dataSource = self
        self.loadData()
    }
    
    // reloading the table view function
    func loadData() {
        // code to load data from network, and refresh the interface
        allBooksTableView.reloadData()
    }
    
    
    // MARK: - Database Protocol
    func onUserChange(change: DatabaseChange, users: [User]) {
        // Get the current details of the logged on user
        for user in users {
            if loggedOnUser?.userEmail == user.userEmail {
                loggedOnUser = user
            }
        }
        
        // get all the users
        allUsers = users
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        allBooks = []
        filteredBooks = []
        
        // get all the books of the user
        for user in allUsers {
            if user.userEmail == loggedOnUser?.userEmail {
                for book in books {
                    var isInUserBooks: Bool = false
                    
                    for bookID in user.userBooks {
                        if book.bookID == bookID {
                            isInUserBooks = true
                        }
                    }
                    
                    if !isInUserBooks {
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
    
    
    // MARK: - View will appear and disapper functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds listener
        print("viewWillAppear was called")
        databaseController?.addListener(listener: self)
        self.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removes listener
        databaseController?.removeListener(listener: self)
        self.loadData()
    }
    
    
    // MARK: - Table View
    // Variables
    let SECTION_BOOKS = 0
    let CELL_BOOK = "book"
    
    // Search functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the search textis not emptythen get allBooks
        filteredBooks = searchText.isEmpty ? allBooks : allBooks.filter({(dataString: Book) -> Bool in
            // return the entries that have the same name as the search text
            return dataString.bookName?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        // reload the data
        self.loadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // there is one sections therefore return 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_BOOKS {
            return filteredBooks.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bookCell = tableView.dequeueReusableCell(withIdentifier: CELL_BOOK, for: indexPath) as! BookTableViewCell
        let book = filteredBooks[indexPath.row]
        
        bookCell.bookNameLabel.text = book.bookName
        
        return bookCell
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
        if segue.identifier == "addBookDetailsSegue" {
            let destination = segue.destination as! BookDetailViewController
            destination.addBook = true
            destination.currentBook = self.filteredBooks[allBooksTableView.indexPathForSelectedRow!.row]
            destination.loggedOnUser = self.loggedOnUser
        }
    }
    

}
