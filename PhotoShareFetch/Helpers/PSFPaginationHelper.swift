//
//  PSFPaginationHelper.swift
//  PhotoShareFetch
//
//  Created by Admin on 08.08.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import Foundation

protocol PSFKeyed {
    var key: String? { get set }
}

class PSFPaginationHelper<T:PSFKeyed> {
    
    enum  PSFPaginationState {
    case initial   //no data has been loaded yet
    case ready     //waiting for next request to paginate & load the nextpage
    case loading   //currently paginating and waiting for data from Firebase
    case end       //all data has been paginated
    }

    // MARK: - Properties
    
    let pageSize: UInt // number of posts on page
   
    let serviceMethod: (UInt, String?, @escaping (([T]) -> Void)) -> Void
    var state: PSFPaginationState = .initial //current pagination state
    var lastObjectKey: String? //Firebase uses object keys to determine the last position of the page (using this as an offset for paginating.)
    
    // MARK: - Init
    
    //with this init can change the default page size for this helper & set the service method that will be paginated and return data
    
    init(pageSize: UInt = 3, serviceMethod: @escaping (UInt, String?, @escaping (([T]) -> Void)) -> Void) {
        self.pageSize = pageSize
        self.serviceMethod = serviceMethod
    }
     //paginates the content
    func paginate(completion: @escaping ([T]) -> Void) {
      
        switch state {
       
        case .initial:
            lastObjectKey = nil
            fallthrough //using this keyword to execute the ready case below
            
        case .ready:
            state = .loading
            serviceMethod(pageSize, lastObjectKey) { [unowned self] (objects: [T]) in
                // using defer for make sure that following code is executed whenever the closure returns.(helpful for removing duplicate code)
                defer {
                    if let lastObjectKey = objects.last?.key {
                        self.lastObjectKey = lastObjectKey
                    }
                    self.state = objects.count < Int(self.pageSize) ? .end : .ready
                }
                guard let _ = self.lastObjectKey else {
                    return completion(objects)
                }
                //when using lastObjectKey the previous object from the last page is returned.first object will be a duplicate post in the timeline
                let newObjects = Array(objects.dropFirst())
                completion(newObjects)
            }
            
        case .loading, .end:
            return
        }

}
    // reset the pagination helper
    func reloadData(completion: @escaping ([T]) -> Void) {
        state = .initial
        
        paginate(completion: completion)
    }
}


