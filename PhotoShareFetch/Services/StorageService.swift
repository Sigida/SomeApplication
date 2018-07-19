//
//  StorageService.swift
//  PhotoShareFetch
//
//  Created by Admin on 19.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//


import UIKit
import FirebaseStorage

struct StorageService {
    
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        
        // change the image from an UIImage to Data and reduce the quality of the image
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // upload our media data to the path provided as a parameter to the method.
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
           
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            //call downloadURL to get a URL reference and return it to the completion handler
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                completion(url)
            })
        })
    }
}
