//
//  PostService.swift
//  PhotoShareFetch
//
//  Created by Admin on 19.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    
    static func create(for image: UIImage) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(forURLString: urlString, aspectHeight: aspectHeight)
        }
}
    // create a new Post JSON object in database
    //improved the photo upload mechanism    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        
        // Create a reference to the current user. We'll need the user's UID to construct the location of where we'll store our post data in our database.
        let currentUser = User.current
        // Initialize a new Post using the data passed in by the parameters.
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        // create references to the important locations that we're planning to write data.
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        // Use our class method to get an array of all of our follower UIDs
        UserService.followers(for: currentUser) { (followerUIDs) in
            // construct a timeline JSON object where we store our current user's uid. need to do this because when  fetch a timeline for a given user, will need the uid of the post in order to read the post from the Post subtree.
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            // create a mutable dictionary that will store all of the data we want to write to our database. initialize it by writing the current timeline dictionary to our own timeline because our own uid will be excluded from our follower UIDs.
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            // add our post to each of our follower's timelines.
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // make sure to write the post which are trying to create
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            //write multi-location update to the database.
            rootRef.updateChildValues(updatedData)
        }
    }
    //Read data from FireBase (construct an array of Post from timeline)
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
}
