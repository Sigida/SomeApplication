//
//  FollowService.swift
//  PhotoShareFetch
//
//  Created by Admin on 02.08.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
    
    
   private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
    // create a dictionary to update multiple locations at the same time.
    //set the appropriate key-value for our followers and following.
    let currentUID = User.current.uid
    let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                      "following/\(currentUID)/\(user.uid)" : true]
    
    // write our new relationship to Firebase.
    let ref = DatabaseReference.toLocation(.root)
    ref.updateChildValues(followData) { (error, _) in
    if let error = error {
    assertionFailure(error.localizedDescription)
        success(false)
    }
        // get all posts for the user
        UserService.posts(for: user) { (posts) in
            // get all of the post keys for that user's posts. This will allow to write each post to the own timeline.
            let postKeys = posts.compactMap { $0.key }
            
            //build a multiple location update using a dictionary that adds each of the followee's post to our timeline
            var followData = [String : Any]()
            let timelinePostDict = ["poster_uid" : user.uid]
            postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
            
            // write the dictionary to our database
            ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                //return success based on whether we received an error
                success(error == nil)
            })
        }
    }
}
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
        // http://stackoverflow.com/questions/38462074/using-updatechildvalues-to-delete-from-firebase
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        let ref = DatabaseReference.toLocation(.root)
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            UserService.posts(for: user, completion: { (posts) in
                var unfollowData = [String : Any]()
                let postsKeys = posts.compactMap { $0.key }
                postsKeys.forEach {
                    // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
                    unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                }
                
                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    success(error == nil)
                })
            })
        }
    }
    //relationship between two users
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    //determine the current follow relationship between users.
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = DatabaseReference.toLocation(.followers(uid: user.uid))
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
