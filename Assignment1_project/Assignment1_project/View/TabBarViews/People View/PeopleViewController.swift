//
//  PeopleViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    // MARK: - Variables
    // variables from the storyboard
    @IBOutlet weak var detailsSegmentView: UIView!
    @IBOutlet weak var bookSegmentView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    
    // the user that is currently logged on
    var loggedOnUser: User?
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title of the people tab
        self.tabBarItem = UITabBarItem(title: "PEOPLE", image: nil, selectedImage: nil)
        
        // Set the profile picture and edit the photo
        self.profilePicture.image = UIImage(named: (loggedOnUser?.userProfilePicture)!)
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1;
    }
    
    // Change depending on what segment
    @IBAction func onSegmentChange(_ sender: Any) {
        switch  segmentController.selectedSegmentIndex {
        // If segment is the details view
        case 0:
            detailsSegmentView.isHidden = false
            bookSegmentView.isHidden = true
            break
        // If segment is books view
        case 1:
            detailsSegmentView.isHidden = true
            bookSegmentView.isHidden = false
            break
        default:
            break
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check the segue and go to the detailsSegmentViewController
        if segue.identifier == "peopleDetailsProfileSegue" {
            let uiView = segue.destination as! DetailsSegementViewController
            uiView.selectView = "People"
        }
        
        if segue.identifier == "peopleBookSegementSegue" {
            let uiView = segue.destination as! BookSegmentViewController
            uiView.selectView = "People"
        }
    }
}
