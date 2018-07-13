//
//  Storyboard+Utility.swift
//  PhotoShareFetch
//
//  Created by Admin on 13.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

extension UIStoryboard {
    enum PSFType: String {
        case main
        case login
        
        var filename: String {
            return rawValue.capitalized
        }
        
    }
    
    convenience init(type: PSFType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
    
    static func initialViewController(for type: PSFType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        //Check that the storyboard has an initial view controller
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate initial view controller for \(type.filename) storyboard.")
        }
        
        return initialViewController
    }
}
