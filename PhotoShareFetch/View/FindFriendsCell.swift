//
//  FindFriendsCell.swift
//  PhotoShareFetch
//
//  Created by Admin on 02.08.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

class FindFriendsCell: UITableViewCell {
   
    // MARK: - Properties
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
    }

    // MARK: - IBActions
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        print("follow button tapped")
    }

}
