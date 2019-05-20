//
//  DetailsSegementViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class DetailsSegementViewController: UIViewController, UITextViewDelegate{

    weak var databaseController: DatabaseProtocol?
    
    var selectView: String?
    var user: User?
    var allUsers: [User] = []
    var userTrack = 0
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        super.viewDidLoad()
        if selectView == "People" {
            bioTextView.isEditable = false
            allUsers = databaseController!.getUsers()
            
            if allUsers[userTrack].userEmail != user?.userEmail {
                userNameLabel.text = "\(allUsers[userTrack].userFirstName) \(allUsers[userTrack].userLastName)"
                bioTextView.text = "\(allUsers[userTrack].userBio)"
            }
                
            else {
                userTrack += 1
            }
        }
        
        else {
            userNameLabel.text = "\(user!.userFirstName) \(user!.userLastName)"
            bioTextView.text = "\(user!.userBio)"
           
            bioTextView.delegate = self
        }
        // Do any additional setup after loading the view.
    }
    
    // keyboard
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if selectView != "People" {
            databaseController!.updateUserBio(userBio: bioTextView.text, userEmail: (user?.userEmail)!)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
