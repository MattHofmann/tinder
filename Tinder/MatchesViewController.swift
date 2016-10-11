//
//  MatchesViewController.swift
//  Tinder
//
//  Created by Matthias Hofmann on 07.10.16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    var images = [UIImage]()
    var userIds = [String]()
    var messages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MatchesViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        
        
        //
        let query = PFUser.query()
        // user that have accepted current user
        query?.whereKey("accepted", contains: PFUser.current()?.objectId)
        // users that have been accepted by current user
        
        if PFUser.current()?["accepted"] != nil {
            query?.whereKey("objectId", containedIn: PFUser.current()?["accepted"] as! [String])
        }
        
        query?.findObjectsInBackground(block: { (objects, error) in
            //  Error
            if error != nil {
                print("Error: \(error)")
            }
                
            if let users = objects {
            
                for object in users {
                
                    if let user = object as? PFUser {
                        // user images
                        let imageFile = user["photo"] as! PFFile
                        imageFile.getDataInBackground(block: { (data, error) in
                            //  Error
                            if error != nil {
                                print("Error: \(error)")
                            }
                            
                            if let imageData = data {
                                
                                // Message
                                
                                let messageQuery = PFQuery(className: "Message")
                                messageQuery.whereKey("recipient", equalTo: (PFUser.current()?.objectId!)!)
                                messageQuery.whereKey("sender", equalTo: user.objectId!)
                                
                                messageQuery.findObjectsInBackground(block: { (objects, error) in
                                    
                                    var messageText = "No message from this user."
                                    
                                    if let objects = objects {
                                        
                                        for message in objects {
                                            
                                            if let messageContent = message["content"] as? String {
                                                
                                                messageText = messageContent
                                                
                                            }
                                        }
                                    }
                                    
                                    self.messages.append(messageText)
                                    self.images.append(UIImage(data: imageData)!)
                                    self.userIds.append(user.objectId!)
                                    self.tableView.reloadData()
                                    
                                })
                                
                            }
                            
                        })
                        
                    }
            
                }
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: IBActions
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MatchesTableViewCell
        
        cell.matchesImageView.image = images[indexPath.row]
        cell.messagesLabel.text = "You haven't recieved a message yet."
        cell.userIdLabel.text = userIds[indexPath.row]
        cell.messagesLabel.text = messages[indexPath.row]
        //cell.awakeFromNib()
        //cell.textLabel?.text = "Test Row \(indexPath.row)"
        return cell
    }

    
    // MARK: Keyboard Methods
    
    func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    
}
