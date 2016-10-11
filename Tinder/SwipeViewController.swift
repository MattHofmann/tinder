//
//  SwipeViewController.swift
//  Tinder
//
//  Created by Matthias Hofmann on 07.10.16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

/*
// TODO: Improvements
add waiting indicator while loading pictures
get userdetails in advance instead one by one
*/

class SwipeViewController: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var swipeImageView: RoundedEdgesImageView!
    
    var displayedUserID = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // GEODATA
        // get geopoint
        PFGeoPoint.geoPointForCurrentLocation { (geopoint, error) in
            
            print(geopoint)
            
            if let geopoint = geopoint {
                //create user and save
                PFUser.current()?["location"] = geopoint
                PFUser.current()?.saveInBackground()
                
            }
            
        }
        
        // load first image
        updateImage()
        
        
        // add Swipegesture
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:))) // add colon to indicate that data should be passed to the new VC
        // make Iamge interactive
        swipeImageView.isUserInteractionEnabled = true
        swipeImageView.addGestureRecognizer(gesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        updateImage()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func logoutButtonTapped(_ sender: AnyObject) {
        
        // MARK: LOGOUT
        
        PFUser.logOut()
        PFUser.logOutInBackground { (error) in
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    @IBAction func userDetailsButtonTapped(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "toUserDetailsVC", sender: nil)
        
    }
    
    @IBAction func matchesButtonTapped(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "toMatchesVC", sender: nil)
        
    }
    

    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //if seqgue.identifier == "logoutSe"
        
    }

    // method updates image
    func updateImage() {
        // create request
        let query = PFUser.query()
        // switch values
        query?.whereKey("isFemale", equalTo: (PFUser.current()?["isInterestedInWomen"])!)
        query?.whereKey("isInterestedInWomen", equalTo: (PFUser.current()?["isFemale"])!)
        
        // Ignored Users
        var ignoredUsers = [""]
        if let acceptedUsers = PFUser.current()?["accepted"] {
            ignoredUsers += acceptedUsers as! Array
            
        }
        if let rejectedUsers = PFUser.current()?["rejected"] {
            ignoredUsers += rejectedUsers as! Array
        }
        
        query?.whereKey("objectId", notContainedIn: ignoredUsers)
        
        
        
        // get users close by
        if let userGeoPoint = PFUser.current()?["location"] as? PFGeoPoint {
            
            let latitude = userGeoPoint.latitude
            let longitude = userGeoPoint.longitude
            
            query?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
        }
        /*
        // Error
        if let latitude = (PFUser.current()?["location"] as AnyObject).latitude {
            
            if let longitude = (PFUser.current()?["location"] as AnyObject).longitude {
                print("DEV: inside geo query")
                query?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
                
            }
         
        }
        */
 
        // limit to 1 user a time
        query?.limit = 1
        
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            //  Error
            if let error = error as NSError? {
                var errorMessage = "We could'n find users for you."
                
                if let imageError = error.userInfo["error"] as? String {
                    errorMessage = imageError
                }
                self.errorLabel.text = errorMessage
            } else {
                
                if let users = objects {
                    
                    if users.count == 0 {
                        print("DEV: No more valid users in array")
                        self.swipeImageView.image = UIImage(named: "noMatches")
                        self.errorLabel.text = "We can't find users close to you."
                        
                    }
                    
                    for object in users {
                        
                        if let user = object as? PFUser {
                            
                            self.displayedUserID = user.objectId!
                            
                            let imageFile = user["photo"] as? PFFile
                            imageFile?.getDataInBackground(block: { (data, error) in
                                
                                if let imageData = data {
                                    
                                    self.swipeImageView.image = UIImage(data: imageData)
                                    
                                }
                            })
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
            //
            
            
        })
    }
    
    
    
    
    // MARK: Animations
    // Swiping the image
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        //print("was dragged")
        // var to track the relative movement of the drag
        let translation = gestureRecognizer.translation(in: view)
        //print(translation)
        
        // get the view(eg. label) from the gestureRecognizer
        let swipeImageView = gestureRecognizer.view!
        //move the label where the user is draggin
        swipeImageView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        // MARK: TRANSFORMATION
        // distance from center
        let xFromCenter = swipeImageView.center.x - self.view.bounds.width / 2
        // ROTATION
        var rotation = CGAffineTransform(rotationAngle: xFromCenter/200)
        
        // STRETCH
        let scale = min(abs(100 / xFromCenter), 1)
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
        swipeImageView.transform = stretchAndRotation
        
        // check the dragged direction
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            // Accepted or rejected
            var acceptedOrRejected = ""
            
            // left screenside
            if swipeImageView.center.x < 100 {
                acceptedOrRejected = "rejected"
                print("Not chosen")
                
                // right screenside
            } else if swipeImageView.center.x > self.view.bounds.width - 100 {
                acceptedOrRejected = "accepted"
                print("Chosen")
                
                
            }
            
            if acceptedOrRejected != "" && displayedUserID != "" {
                
                PFUser.current()?.addUniqueObjects(from: [displayedUserID], forKey: acceptedOrRejected)
                PFUser.current()?.saveEventually({ (success, error) in
                    
                    // Handle Error
                    if error != nil {
                        print("Error: \(error)")
                    }
                    
                    self.updateImage()
                })
                
                updateImage()
                
                
            }
            
            
            // reset postion, stretch and location
            rotation = CGAffineTransform(rotationAngle: 0)
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
            swipeImageView.transform = stretchAndRotation
            swipeImageView.center = CGPoint.init(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
        }

    }

}
