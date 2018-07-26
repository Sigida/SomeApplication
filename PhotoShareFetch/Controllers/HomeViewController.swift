//
//  HomeViewController.swift
//  PhotoShareFetch
//
//  Created by Admin on 14.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var posts = [Post]()
    
    @IBOutlet var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetching our posts from Firebase
        UserService.posts(for: User.current) { (posts) in
            self.posts = posts
            print("\(posts.count)")
            self.tableView.reloadData()
            
        }
        
    }
}
// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath)
        cell.backgroundColor = .green
            
        return cell
    }
}
