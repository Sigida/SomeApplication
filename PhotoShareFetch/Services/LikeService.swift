//
//  LikeService.swift
//  PhotoShareFetch
//
//  Created by Admin on 27.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct LikeService {
  
    static func create(for post: Post, success: @escaping (Bool) -> Void) {
        // checking the post has a key
        guard let key = post.key else {
            return success(false)
        }
        
        // create a reference to the current user's UID
        let currentUID = User.current.uid
        
        //code to like a post
        //Define a location for where we're planning to write data
        let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
        //Write the data by setting the value for the location specified
        likesRef.setValue(true) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            //Handle a callback for the success of the write
            return success(true)
        }
    }
    
    static func delete(for post: Post, success: @escaping (Bool) -> Void) {
        guard let key = post.key else {
            return success(false)
        }
        let currentUID = User.current.uid
        let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
        likesRef.setValue(nil) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            return success(true)
        }
    }
}
