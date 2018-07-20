//
//  Post.swift
//  PhotoShareFetch
//
//  Created by Admin on 20.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//


import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post {
    
    var key: String?
    let imageURL: String
    let imageHeight: CGFloat
    let creationDate: Date
    
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        
        return ["image_url" : imageURL,
                "image_height" : imageHeight,
                "created_at" : createdAgo]
    }
    
    init(imageURL: String, imageHeight: CGFloat) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
    }
}
