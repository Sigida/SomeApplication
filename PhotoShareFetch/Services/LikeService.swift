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
            //Adding Transaction Block
            let likeCountRef = Database.database().reference().child("posts").child(post.poster.uid).child(key).child("like_count")
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    success(true)
                }
            })
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
          //Call the transaction API on the DatabaseReference location we want to update
            let likeCountRef = Database.database().reference().child("posts").child(post.poster.uid).child(key).child("like_count")
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                //Check that the value exists and increment it if it does
                let currentCount = mutableData.value as? Int ?? 0
                
                mutableData.value = currentCount - 1
                //Return the updated value
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                //Handle the completion block if there's an error
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                //Handle the completion block if the transaction was successfu
                    success(true)
                }
            })
}
}
    
    static func isPostLiked(_ post: Post, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        guard let postKey = post.key else {
            assertionFailure("Error: post must have key.")
            return completion(false)
        }
       //building a relative path to the location of where we store the current user's like data for a specific post, if a like were to exist.
        let likesRef = Database.database().reference().child("postLikes").child(postKey)
        //we use a special query that checks whether a value exists at the location that we're reading from. If there is, we know that the current user has liked the post. Otherwise, we know that the user hasn't.
        likesRef.queryEqual(toValue: nil, childKey: User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
