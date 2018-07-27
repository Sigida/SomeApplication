//
//  PostActionCell.swift
//  PhotoShareFetch
//
//  Created by Admin on 27.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

class PostActionCell: UITableViewCell {
    
    // MARK: - Subviews

    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
    
    // MARK: - IBActions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        print("like button tapped")
    }
}
