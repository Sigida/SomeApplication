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
        // Convert the new post object into a dictionary so that it can be written as JSON in our database.
        let dict = post.dictValue
        
        // Construct the relative path to the location where we want to store the new post data
        let postRef = Database.database().reference().child("posts").child(currentUser.uid).childByAutoId()
        //Write the data to the specified location.
        postRef.updateChildValues(dict)
    }
}
