//
//   UIImage+Size.swift
//  PhotoShareFetch
//
//  Created by Admin on 20.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

extension UIImage {
    var aspectHeight: CGFloat {
        let heightRatio = size.height / 736
        let widthRatio = size.width / 414
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return size.height / aspectRatio
    }
}
