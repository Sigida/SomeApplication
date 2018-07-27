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
}
