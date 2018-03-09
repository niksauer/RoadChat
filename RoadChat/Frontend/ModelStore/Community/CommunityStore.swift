//
//  CommunityStore.swift
//  RoadChat
//
//  Created by Malcolm Malam on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

class CommunityStore{
    
    func create(_ post: CommunityMessageRequest, completion: @escaping (Error?) -> Void){
        let communityService = CommunityService()
        
        do{
            try communityService.create(post) { post, error in
                guard let post = post else {
                    completion(error!)
                    return
                }
                
                do {
                    _ = try CommunityMessage.create(from: post, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
                } catch{
                    completion(error)
                    }
            }
        } catch {
            
            completion(error)
            
            }
        }
                
    func getCommunityPosts(){
        
        
        
    }
    
}
            
            
            
            


