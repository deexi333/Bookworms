//
//  PeopleViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var detailsSegmentView: UIView!
    @IBOutlet weak var bookSegmentView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var tabBarIndex: Int?
    
    var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tabBarItem = UITabBarItem(title: "PEOPLE", image: nil, selectedImage: nil)
        self.profilePicture.image = UIImage(named: user!.userProfilePicture)
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1;
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onSegmentChange(_ sender: Any) {
        switch  segmentController.selectedSegmentIndex {
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
        if segue.identifier == "peopleDetailsProfileSegue" {
            let uiView = segue.destination as! DetailsSegementViewController
            uiView.selectView = "People"
        }
    }
    

}
