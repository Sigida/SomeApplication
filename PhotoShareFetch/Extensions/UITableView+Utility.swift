//
//  UITableView+Utility.swift
//  PhotoShareFetch
//
//  Created by Admin on 08.08.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

protocol CellIdentifiable {
    static var cellIdentifier: String { get }
}
//define default values for protocol
extension CellIdentifiable where Self: UITableViewCell {

    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: CellIdentifiable { }

extension UITableView {
   //generic
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: CellIdentifiable {
       
        guard let cell = dequeueReusableCell(withIdentifier: T.cellIdentifier) as? T else {
            
            fatalError("Error dequeuing cell for identifier \(T.cellIdentifier)")
        }
        
        return cell
    }
}
