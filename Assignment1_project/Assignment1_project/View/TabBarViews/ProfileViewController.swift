//
//  ProfileViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var detailsSegmentView: UIView!
    @IBOutlet weak var bookSegmentView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var addProfilePictureButton: UIButton!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tabBarItem = UITabBarItem(title: "PROFILE", image: nil, selectedImage: nil)
        
        self.profilePicture.image = UIImage(named: user!.userProfilePicture)
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1;
        
        self.addProfilePictureButton.layer.cornerRadius = self.addProfilePictureButton.frame.size.width / 2;
        self.addProfilePictureButton.clipsToBounds = true;
        self.addProfilePictureButton.layer.borderWidth = 1;
        
        segmentedControl.selectedSegmentIndex = 0
        detailsSegmentView.isHidden = false
        bookSegmentView.isHidden = true
        
        
        
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    

    @IBAction func onSegmentChange(_ sender: Any) {
        switch  segmentedControl.selectedSegmentIndex {
        case 0:
            detailsSegmentView.isHidden = false
            bookSegmentView.isHidden = true
            break
        case 1:
            detailsSegmentView.isHidden = true
            bookSegmentView.isHidden = false
            break
        default:
            break
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "profileTabDetailsSegementSegue" {
            let destination = segue.destination as! DetailsSegementViewController
            destination.user = self.user
        }
        
        else if segue.identifier == "profileTabBookListSegue" {
            let destination = segue.destination as! BookSegmentTableViewController
            destination.user = self.user
        }
    }
    

}
