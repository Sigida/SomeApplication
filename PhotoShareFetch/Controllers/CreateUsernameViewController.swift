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
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else {
                // handle error
                return
            }            
            User.setCurrent(user, writeToUserDefaults: true)
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            
            //Get reference to the current window and set the rootViewController to the initial view controller
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            
        }
    }
}
