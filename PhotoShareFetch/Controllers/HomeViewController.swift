//
//  HomeViewController.swift
//  PhotoShareFetch
//
//  Created by Admin on 14.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
    
    // MARK: - Properties
   
    let paginationHelper = PSFPaginationHelper<Post>(serviceMethod: UserService.timeline)
    
    var posts = [Post]()
    let refreshControl = UIRefreshControl()
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    @IBOutlet var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
          configureTableView()
        
       configureTableView()
        reloadTimeline()
       
    }
    
    @objc func reloadTimeline() {
        self.paginationHelper.reloadData(completion: { [unowned self] (posts) in
            self.posts = posts
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.tableView.reloadData()
        })
    }
    
    func configureTableView() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        // remove separators from cells
        tableView.separatorStyle = .none
        // add pull to refresh
        refreshControl.addTarget(self, action: #selector(reloadTimeline), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        switch indexPath.row {
        case 0:
            let cell: PostHeaderCell = tableView.dequeueReusableCell()
            cell.usernameLabel.text = post.poster.username
            
            return cell
            
        case 1:
            let cell: PostImageCell = tableView.dequeueReusableCell()
            let imageURL = URL(string: post.imageURL)
            cell.postImageView.kf.setImage(with: imageURL)
            
            return cell
            
        case 2:
            let cell: PostActionCell = tableView.dequeueReusableCell()

            cell.delegate = self
            configureCell(cell, with: post)
            
            return cell
            
        default:
            fatalError("Error: unexpected indexPath.")
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if indexPath.section >= posts.count - 1 {
                paginationHelper.paginate(completion: { [unowned self] (posts) in
                    self.posts.append(contentsOf: posts)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
        cell.likeButton.isSelected = post.isLiked
        cell.likeCountLabel.text = "\(post.likeCount) likes"
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
            
        case 1:
            let post = posts[indexPath.section]
            return post.imageHeight
            
        case 2:
            return PostActionCell.height
            
        default:
            fatalError()
        }
    }
    
}
extension HomeViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        //checking index path exists for the the given cell
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        // Set the isUserInteractionEnabled property of the UIButton to false so the user doesn't accidentally send multiple requests by tapping too quickly
        likeButton.isUserInteractionEnabled = false
        // Reference the correct post corresponding with the PostActionCell that the user tapped
        let post = posts[indexPath.section]
        
        // Use our LikeService to like or unlike the post based on the isLiked property
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            // Use defer to set isUserInteractionEnabled to true whenever the closure returns
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            guard success else { return }
            
            //Change the likeCount and isLiked properties of our post if our network request was successful
            post.likeCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            //Get a reference to the current cell
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            // Update the UI of the cell on the main thread
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
    }
}
