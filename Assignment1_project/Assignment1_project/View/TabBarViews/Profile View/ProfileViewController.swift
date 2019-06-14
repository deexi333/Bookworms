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
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
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
        
        createCheckMessage(title: "'Bookworms' Would Like to Access Your Camera Roll", message: "Bookworms needs to access your camera roll to choose your profile picture")
       
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
    
    
    // REF: https://www.youtube.com/watch?v=4EAGIiu7SFU
    func createCheckMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // Creating the yes button
        alert.addAction(UIAlertAction(title: "Don't Allow", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Allow", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
            self.pickImage()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func pickImage() {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
        }
        else{
            imagePicker.sourceType = .savedPhotosAlbum
        }
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func keyboard(notification:Notification) {
        guard let keyboardReact = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }

        if notification.name == UIResponder.keyboardWillShowNotification ||  notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.view.frame.origin.y = -keyboardReact.height
        }else{
            self.view.frame.origin.y = 0
        }

    }

}

