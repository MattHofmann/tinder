//
//  SignupViewController.swift
//  Tinder
//
//  Created by Matthias Hofmann on 06.10.16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate {

    // MARK: @IBOutlets
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginOrSignupButton: RoundButton!
    @IBOutlet weak var signupTextField: UILabel!
    @IBOutlet weak var changeSignupModeButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: Variables
    var signupMode = true
    var activityIndicator = UIActivityIndicatorView()
    
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // textField delegates
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        redirectUser()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func signupOrLoginTapped(_ sender: AnyObject) {
        
        // check if textfields are empty
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            errorLabel.text = "Please enter a email and password"
            
        } else {
        
            // add activity indicator
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            // reset errorlabel
            errorLabel.text = ""
            // close keyboard
            self.view.endEditing(true)
            
            // MARK: Signup
            if signupMode {
                
                // create a new user
                let user = PFUser()
                
                user.email = emailTextField.text
                //user.username = emailTextField.text
                user.password = passwordTextField.text
                
                // get rid of the part behind the '@'-Symbol
                let usernameArray = emailTextField.text?.components(separatedBy: "@")
                user.username = usernameArray?[0]
                
                
                /*
                // create ACL
                let acl = PFACL()
                // allow every user potentialy to change data (bad!)
                acl.getPublicWriteAccess = true
                acl.getPublicReadAccess = true
                user.acl = acl
                */
                // save to Parse server
                user.signUpInBackground { (success, error) in
                    
                    // stop activityIndicator and allow user interaction
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    // Check for error
                    if error != nil {
                        // display error as an alert to the user
                        // cast error as NSError
                        let error = error as NSError?
                        // generic error message
                        var errorMessage = "Signup failed - please try again"
                        // if detailed error message available, use details error message
                        if let parseError = error?.userInfo["error"] as? String {
                            errorMessage = parseError
                        }
                        self.errorLabel.text = errorMessage
                    } else {
                        print("Signed up")
                        // user signed up, segue to user view
                        self.performSegue(withIdentifier: "toUserDetailsVC", sender: self)
                    }
                }

            // MARK: Login
            } else {
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    // stop activityIndicator and allow user interaction
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    // Check for error
                    if error != nil {
                        // display error as an alert to the user
                        // cast error as NSError
                        let error = error as NSError?
                        // generic error message
                        var errorMessage = "Login failed - please try again"
                        // if detailed error message available, use details error message
                        if let parseError = error?.userInfo["error"] as? String {
                            errorMessage = parseError
                        }
                        
                        self.errorLabel.text = errorMessage
                    } else {
                        print("Logged in")
                        // user logged in, segue to next view
                        self.redirectUser()
                    }
                })
            }
        }
    }
    
    
    @IBAction func changeSignUpModeTapped(_ sender: AnyObject) {
        // signup mode
        if signupMode {
            // switch to login
            signupMode = false
            emailTextField.placeholder = "Username"
            loginOrSignupButton.setTitle("Log in", for: [])
            changeSignupModeButton.setTitle("Sign up", for: [])
        // login mode
        } else {
            // switch to signup
            signupMode = true
            emailTextField.placeholder = "Email"
            loginOrSignupButton.setTitle("Sign up", for: [])
            changeSignupModeButton.setTitle("Log in", for: [])
        }
        
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func redirectUser() {
        
        // Auto-Login with Parse
        
        if PFUser.current() != nil {
            
            if PFUser.current()?["isFemale"] != nil && PFUser.current()?["isInterestedInWomen"] != nil && PFUser.current()?.username != nil && PFUser.current()?["photo"] != nil {
                
                performSegue(withIdentifier: "toSwipeVC", sender: self)
                
            } else {
                
                performSegue(withIdentifier: "toUserDetailsVC", sender: self)
                
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
