//
//  PostHeaderCell.swift
//  PhotoShareFetch
//
//  Created by Admin on 27.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {

  @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        print("options button tapped")
    }
    
}
