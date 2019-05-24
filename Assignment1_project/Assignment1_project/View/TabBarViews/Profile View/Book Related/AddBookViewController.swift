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
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        allBooksTableView.reloadData()
    }
    
    // MARK: - Table View Content
    
    // Listener
    var listenerType = ListenerType.all
    
    // Variables
    let SECTION_BOOKS = 0
    let CELL_BOOK = "book"
    
    var allUsers: [User] = []
    var allBooks: [Book] = []
    var filteredBooks: [Book] = []
    
    func onUserChange(change: DatabaseChange, users: [User]) {
        for user in users {
            if loggedOnUser?.userEmail == user.userEmail {
                loggedOnUser = user
            }
        }
        
        allUsers = users
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) {
        allBooks = []
        filteredBooks = []
        
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
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) {
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the search textis not emptythen get allBooks
        filteredBooks = searchText.isEmpty ? allBooks : allBooks.filter({(dataString: Book) -> Bool in
            // return the entries that have the same name as the search text
            return dataString.bookName?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        // reload the data
        allBooksTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_BOOKS {
            databaseController!.deleteBook(book: filteredBooks[indexPath.row], user: loggedOnUser!)
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addBookDetailsSegue" {
            let destination = segue.destination as! BookDetailViewController
            destination.addBook = true
            destination.currentBook = self.filteredBooks[allBooksTableView.indexPathForSelectedRow!.row]
            destination.loggedOnUser = self.loggedOnUser
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
