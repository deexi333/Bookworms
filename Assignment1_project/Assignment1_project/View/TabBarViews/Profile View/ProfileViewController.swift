//
//  ProfileViewController.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DatabaseListener {
    
    // MARK: - Variables
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // Fields from the storyboard
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailsSegmentView: UIView!
    @IBOutlet weak var bookSegmentView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // Profile picture
    @IBOutlet weak var profilePicture: UIImageView!
    
    // Logged on user
    var loggedOnUser: User?
    
    // Listener
    var listenerType = ListenerType.all
    
    // References in firebase
    var collectionReference = Firestore.firestore().collection("user")
    var storageReference = Storage.storage()
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // get the profile picture from the user database entry
        if loggedOnUser?.userProfilePicture == "defaultProfilePicture" {
            self.profilePicture.image = UIImage(named: loggedOnUser!.userProfilePicture)
        }
        
        // If the image is not the default one then assisng the URL from the user
        else {
            self.storageReference.reference(forURL: loggedOnUser!.userProfilePicture).getData(maxSize: 5 * 1024 * 1024,
            completion: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    let image = UIImage(data: data!)
                    self.profilePicture.image = image
                }
            }
            )
        }

        // Format the profile picture
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1;
        
        // Segmented control - setting it to index 0
        segmentedControl.selectedSegmentIndex = 0
        detailsSegmentView.isHidden = false
        bookSegmentView.isHidden = true
        
        // use the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Making the keyboard move up so that the bio text view is not blocked
        // REF: https://stackoverflow.com/questions/50325019/moving-view-up-with-textfield-and-button-when-keyboard-appear-swift
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // Making sure the profile picture can be tapped
        profilePicture.isUserInteractionEnabled = true
        
        // adding the tap gesture to the profile picture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(gesture:)))
        tapGesture.numberOfTapsRequired = 2
        profilePicture.addGestureRecognizer(tapGesture)
    }
    
    // the double tap gesture
    @objc func doubleTap(gesture: UITapGestureRecognizer) {
        // An alert message is shown if the user has not accepted the camera acceptance
        if loggedOnUser?.userCameraAcceptance == "false" {
            // Create a message box to accept the use of the photo gallery
            createCheckMessage(title: "'Bookworms' Would Like to Access Your Camera Roll", message: "Bookworms needs to access your camera roll to choose your profile picture")
        }
        
        else {
            // If the user has given permission then pick an image
            self.pickImage()
        }
       
    }
    
    
    // MARK: - Fixing the keyboard
    @objc func keyboard(notification:Notification) {
        guard let keyboardReact = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||  notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.view.frame.origin.y = -keyboardReact.height
        } else{
            self.view.frame.origin.y = 0
        }
    }
    
    
    // MARK: - Image picking
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
        // Assign the picked image
        profilePicture.image = pickedImage
        
        let image = profilePicture.image
        
        var data = Data()
        data = image!.jpegData(compressionQuality: 0.8)!
        
        // place it in firebase storage under the users email
        let imageRef = storageReference.reference().child("\(loggedOnUser!.userEmail)")
        let metadata = StorageMetadata()
        // type of content
        metadata.contentType = "image/jpg"
        
        // Putting the url in the user imformation
        imageRef.putData(data, metadata: metadata){ (meta, error) in
            if error != nil {
                self.displayMessage(title: "Could not upload image to firebase", message: "Error")
            }
            else {
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Download URL not found")
                        return
                    }
                    
                    self.collectionReference.document(self.loggedOnUser!.userEmail).updateData(["userProfilePicture": "\(downloadURL)"])
                }
            }
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
            self.databaseController?.updateUserCameraAcceptance(userEmail: self.loggedOnUser!.userEmail, userCameraAcceptance: "true")
            self.pickImage()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // Create the cancel button
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
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
    
    
    // MARK: - Segment controller
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
    
    
    // MARK: - Database Protocol
    func onUserChange(change: DatabaseChange, users: [User]) {
        // get the updated user
        for user in users {
            if user.userEmail == loggedOnUser?.userEmail {
                loggedOnUser = user
            }
        }
    }
    
    func onBookChange(change: DatabaseChange, books: [Book]) { }
    
    func onGenreChange(change: DatabaseChange, genres: [Genre]) { }
    
    func onConversationChange(change: DatabaseChange, conversations: [Conversation]) { }
    
    func onMessageChange(change: DatabaseChange, messages: [Message]) { }
    
    
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

