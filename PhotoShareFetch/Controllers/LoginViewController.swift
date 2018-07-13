//
//  LoginViewController.swift
//  PhotoShareFetch
//
//  Created by Admin on 12.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase

class LoginViewController: UIViewController {
    //handling future namespace conflicts
    //(use FIRUser instead of User )
    typealias FIRUser = FirebaseAuth.User
 
    // MARK: - Properties
    
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
  
    // MARK: - IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
       
        // access the FUIAuth default auth UI singleton
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        // set the FUIAuth's singleton's delegate
        authUI.delegate = self
        
        // present the auth view controller
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
    }

}

//conform to the FUIAuthDelegate protocol and catching errors

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        // check
        guard let user = authDataResult?.user
            else { return }
        
        // construct a relative path to the reference of the user's information in the database.
let userRef = Database.database().reference().child("users").child(user.uid)
        
        // read from the path
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // retrieve user data from snapshot
            if let user = User(snapshot: snapshot) {
                print("Welcome back, \(user.username).")
            } else {
                self.performSegue(withIdentifier: "toCreateUsername", sender: self)
            }
            
        })
    }
    }

