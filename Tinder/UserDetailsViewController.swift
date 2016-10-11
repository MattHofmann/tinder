//
//  UserDetailsViewController.swift
//  Tinder
//
//  Created by Matthias Hofmann on 06.10.16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UserDetailsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    // MARK: IBOutlets
    
    @IBOutlet weak var userImage: RoundImageView!
    @IBOutlet weak var usernameTextField: BorderTextField!
    @IBOutlet weak var genderSwitch: CustomSwitch!
    @IBOutlet weak var interestedInButton: CustomSwitch!
    @IBOutlet weak var errorLabel: UILabel!
    
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TextFieldDelegate
        self.usernameTextField.delegate = self
        
        // Set the user settings from Parse-server
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            genderSwitch.setOn(isFemale, animated: false)
        }
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestedInButton.setOn(isInterestedInWomen, animated: false)
        }
        
        if let username = PFUser.current()?.username {
            usernameTextField.text = username
        }
        
        
        if let photo = PFUser.current()?["photo"] as? PFFile {
            photo.getDataInBackground(block: { (data, error) in
                
                //  Error
                if let error = error as NSError? {
                    var errorMessage = "ImageUpdate Failed"
                    
                    if let imageError = error.userInfo["error"] as? String {
                        errorMessage = imageError
                    }
                    self.errorLabel.text = errorMessage
                } else {
                    if let imageData = data {
                        if let downloadedImage = UIImage(data: imageData) {
                            self.userImage.image = downloadedImage
                            self.imageSelected = true
                        }
                    }
                }
                
            })
        }
        
        // create testUser
        //createTestUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func updateDetailsButtonTapped(_ sender: AnyObject) {
        
        // check if there is any caption and image before posting

        guard let _ = userImage.image, imageSelected == true else {
            print("An photo must be selected")
            errorLabel.text = "Please add a photo of you."
            return
        }
        
        // check is textfield not empty
        if usernameTextField.text != "" {
            // set uservalues
            if PFUser.current()?.username != usernameTextField.text {
                PFUser.current()?.username = usernameTextField.text
            }
            PFUser.current()?["isFemale"] = genderSwitch.isOn
            PFUser.current()?["isInterestedInWomen"] = interestedInButton.isOn
            let imageData = UIImageJPEGRepresentation(userImage.image!, 0.2)
            PFUser.current()?["photo"] = PFFile(name: "profile.jpg", data: imageData!)
            
            if PFUser.current() != nil {
                // Update Userdata
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    
                    if let error = error as NSError? {
                        var errorMessage = "Update failed - please try again"
                        
                        if let parseError = error.userInfo["error"] as? String {
                            errorMessage = parseError
                        }
                        self.errorLabel.text = errorMessage
                    } else {
                        print("Userdata updated")
                        self.dismiss(animated: false, completion: nil)
                        self.imageSelected = true
                    }
                })
         
        // seque
                
                
            } else {
                PFUser.logOut()
                print("User logged out")
                // dismiss vc
                dismiss(animated: true, completion: nil)
            }
            
        } else {
            errorLabel.text = "Please enter a valid username"
        }
        
        
    }
    
    // Update user image
    
    @IBAction func updateImage(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        imageSelected = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // set image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            userImage.image = image
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    /*
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Create Test users
    
    func createTestUser() {
        /*
        // women
        var counter = 0
        let urlArray = [
            "https://static.pexels.com/photos/27411/pexels-photo-27411-large.jpg",
            "https://static.pexels.com/photos/108036/pexels-photo-108036-large.jpeg",
            "https://static.pexels.com/photos/26183/pexels-photo-26183-large.jpg",
            "https://static.pexels.com/photos/51969/model-female-girl-beautiful-51969-large.jpeg",
            "https://static.pexels.com/photos/7529/pexels-photo-large.jpeg",
            "https://static.pexels.com/photos/90754/woman-portrait-girl-color-90754-medium.jpeg",
            "https://static.pexels.com/photos/47401/pexels-photo-47401-medium.jpeg",
            "https://static.pexels.com/photos/5076/light-person-woman-fire-medium.jpeg",
            "https://static.pexels.com/photos/61100/pexels-photo-61100-medium.jpeg",
            "https://static.pexels.com/photos/30252/pexels-photo-30252-medium.jpg",
            "https://static.pexels.com/photos/114411/pexels-photo-114411-medium.jpeg"
        ]
 */
        
        // men
        let urlArray = [
            "https://static.pexels.com/photos/91227/pexels-photo-91227-medium.jpeg",
            "https://static.pexels.com/photos/26939/pexels-photo-26939-medium.jpg",
            "https://static.pexels.com/photos/24257/pexels-photo-24257-medium.jpg",
            "https://static.pexels.com/photos/185847/pexels-photo-185847-medium.jpeg",
            "https://static.pexels.com/photos/11392/pexels-photo-11392-medium.jpeg",
            "https://static.pexels.com/photos/25733/pexels-photo-medium.jpg",
            "https://static.pexels.com/photos/119706/pexels-photo-119706-medium.jpeg",
            "https://static.pexels.com/photos/26731/pexels-photo-26731-medium.jpg",
            "https://static.pexels.com/photos/7077/man-people-office-writing-medium.jpg"
        ]
        var counter = 50
        
        for urlString in urlArray {
            counter += 1
            let url = URL(string: urlString)!
            do {
                let data = try Data(contentsOf: url)
                let imageFile = PFFile(name: "profile.jpg", data: data)
                let user = PFUser()
                user["photo"] = imageFile
                user.username = "User \(counter)"
                user.password = "password"
                user["isInterestedInWomen"] = false
                user["isFemale"] = true
                /*
                // set ACL
                let acl = PFACL()
                // allow every user potentialy to change data (bad!)
                acl.getPublicWriteAccess = true
                acl.getPublicReadAccess = true
                user.acl = acl
                */
                // signup user
                user.signUpInBackground(block: { (success, error) in
                    
                    if success {
                      print("\(user.username) signed up successfully")
                    }
                    
                })
                
            } catch {
                print("Could not get data.")
            }
            
            
        }
        
    }
    
    
    // MARK: Keyboard Methods
    
    // close keyboard when user tap outside textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // close keyboard when user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //self.view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
}
