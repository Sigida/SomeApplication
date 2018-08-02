//
//  FindFriendsViewController.swift
//  PhotoShareFetch
//
//  Created by Admin on 14.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

class FindFriendsViewController: UIViewController {
   
    // MARK: - Properties
    
    var users = [User]()
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 71

    }


}
