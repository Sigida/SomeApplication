//
//  UserService.swift
//  PhotoShareFetch
//
//  Created by Admin on 13.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct UserService {
    
    typealias FIRUser = FirebaseAuth.User
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        
        // construct a relative path to the reference of the user's information in the database.
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(user)
        })
    }
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        
        // create a dictionary to store the username the user has provided inside the database
        let userAttrs = ["username": username]
        
        // specify a relative path for the location of where we want to store our data
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        // write the data we want to store
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            //read the user we just wrote to the database and create a user from the snapshot
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    //retrieve all of a user's posts from Firebase
    static func posts(for user: User,
                      completion: @escaping ([Post]) -> Void) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            //use dispatch groups to wait for all of the asynchronous code to complete before calling our completion handler on the main thread
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] = snapshot.reversed().compactMap {
                guard let post = Post(snapshot: $0)
                    else { return nil }
                
                dispatchGroup.enter()
                
                LikeService.isPostLiked(post) { (isLiked) in
                    post.isLiked = isLiked
                    
                    dispatchGroup.leave()
                }
                return post
            }
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts)
            })
        })
}
    //fetch all users
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        // Create a DatabaseReference to read all users from the database
        let ref = Database.database().reference().child("users")
        
        //Read the users node from the database
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            // Take the snapshot and perform a few transformations. First, we convert all of the child DataSnapshot into User using failable initializer (filter out the current user object from the User array)
            let users = snapshot.compactMap(User.init).filter { $0.uid != currentUser.uid }
            
            // Create a new DispatchGroup so that we can be notified when all asynchronous tasks are finished executing. We'll use the notify(queue:) method on DispatchGroup as a completion handler for when all follow data has been read
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                
                //Make a request for each individual user to determine if the user is being followed by the current user
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
            }
            //Run the completion block after all follow relationship data has returned
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
    //fetch all of a user's followers( UIDs) and return them as an String array.
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        let followersRef = Database.database().reference().child("followers").child(user.uid)
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
}

/* JSON tree structure will look like:
 PhotoShareFetch : {
 timeline: {
 user1_uid: {
 post1_key: {
 poster_uid: user2_uid
 },
 post2_key: {
 poster_uid: user2_uid
 },
 post3_key: {
 poster_uid: user1_uid
 }
 },
 user2_uid: { ... }
 },
 followers: { ... },
 following: { ... },
 postLikes: { ... },
 posts: { ... },
 users: { ... }
 }
*/
