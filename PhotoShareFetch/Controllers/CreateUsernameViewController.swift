//
//  CreateUsernameViewController.swift
//  PhotoShareFetch
//
//  Created by Admin on 13.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit
import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        print("tap")
        // check
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        // create a dictionary to store the username the user has provided inside the database
        let userAttrs = ["username": username]
        
        // specify a relative path for the location of where we want to store our data
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        // write the data we want to store
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            //read the user we just wrote to the database and create a user from the snapshot
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                
                // handle newly created user here
            })
        }
    }
}