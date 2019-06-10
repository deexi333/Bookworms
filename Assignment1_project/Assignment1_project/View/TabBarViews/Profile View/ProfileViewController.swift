//
//  ProfileViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // Fields from the storyboard
    @IBOutlet weak var detailsSegmentView: UIView!
    @IBOutlet weak var bookSegmentView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // Profile picture
    @IBOutlet weak var profilePicture: UIImageView!
    
    // Logged on user
    var loggedOnUser: User?
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Set the tab bar title to profile
        self.tabBarItem = UITabBarItem(title: "PROFILE", image: nil, selectedImage: nil)
        
        // get the profile picture from the user database entry
        self.profilePicture.image = UIImage(named: loggedOnUser!.userProfilePicture)
        
        
        // Format the profile picture
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1;
        
        // Fixing the keyboard
        segmentedControl.selectedSegmentIndex = 0
        detailsSegmentView.isHidden = false
        bookSegmentView.isHidden = true
        
        // use the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        profilePicture.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(gesture:)))
        tapGesture.numberOfTapsRequired = 2
        profilePicture.addGestureRecognizer(tapGesture)
    }
    
    @objc func doubleTap(gesture: UITapGestureRecognizer) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
        }
        else{
            imagePicker.sourceType = .savedPhotosAlbum
        }
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profilePicture.image = pickedImage
    }
    
    // When the segment is clicked
    @IBAction func onSegmentChange(_ sender: Any) {
        // When the case is profile then hide the bookSegmentView
        switch  segmentedControl.selectedSegmentIndex {
        case 0:
            detailsSegmentView.isHidden = false
            bookSegmentView.isHidden = true
            break
        // When the case is books then hide the detailsSegmentView
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
        // Pass through the user to the various views
        if segue.identifier == "profileTabDetailsSegementSegue" {
            let destination = segue.destination as! DetailsSegementViewController
            destination.loggedOnUser = self.loggedOnUser
        }
        
        else if segue.identifier == "profileTabBookListSegue" {
            let destination = segue.destination as! BookSegmentViewController
            destination.loggedOnUser = self.loggedOnUser
        }
    }
    

}
