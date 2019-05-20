//
//  BookSegmentTableViewController.swift
//  Assignment1_project
//
//  Created by ME on 16/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class BookSegmentTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {

    let SECTION_BOOKS = 0
    let SECTION_ADD = 1
    let CELL_BOOK = "book"
    let CELL_ADDBOOK = "addBook"
    
    var user: User?
    
    var allBooks: [Book] = []
    var filteredBooks: [Book] = []
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        //Search
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Books"
        navigationItem.searchController = searchController
        
        // Do any additional setup after loading the view.
        definesPresentationContext = true
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
    
    var listenerType = ListenerType.book
    
    
    func updateSearchResults(for searchController: UISearchController) {
        // Get the text from the search bar and filter through the tasks
        // using the title as the key
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredBooks = allBooks.filter({(book: Book) -> Bool in
                return book.bookName!.lowercased().contains(searchText)
            })
        }
        else {
            filteredBooks = allBooks;
        }
        
        // reloads
        tableView.reloadData();
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // there are two sections therefore return 2
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If the section is the task then return the count else return 1
        if section == SECTION_BOOKS
        {
            return filteredBooks.count
        } else {
            return 1
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If the section is a task then set the various values in the list
        if indexPath.section == SECTION_BOOKS {
            let bookCell = tableView.dequeueReusableCell(withIdentifier: CELL_BOOK, for: indexPath) as! BookTableViewCell
            let book = filteredBooks[indexPath.row]
            
            bookCell.bookNameLabel.text = book.bookName
            
            // returns the taskCell that was created
            return bookCell
        }
        
        
        // gets the count for the tasks and puts it in a new cell
        // this will then be displayed in the countCell row
        let addBookCell  = tableView.dequeueReusableCell(withIdentifier: CELL_ADDBOOK, for: indexPath)
        
        return addBookCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // if the section task has the edit delete functionality then it can be deleted
        // from the database
        if editingStyle == .delete && indexPath.section == SECTION_BOOKS {
            databaseController!.deleteBook(book: filteredBooks[indexPath.row], user: user!)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // checks whether or not the row is a task
        if indexPath.section == SECTION_BOOKS {
            return true
        }
        return false
    }
    
    func onUserChange(change: DatabaseChange, user: [User]) {
        
    }
    
    func onBookChange(change: DatabaseChange, book: [Book]) {
        allBooks = book
        updateSearchResults(for: navigationItem.searchController!)
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
