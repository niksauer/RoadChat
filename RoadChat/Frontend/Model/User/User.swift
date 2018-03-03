//
//  User.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject, Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case registry
    }
    
    required convenience init(from decoder: Decoder) throws {
        // NSManagedObject init
        guard let contextUserInfoKey = CodingUserInfoKey.context, let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else {
                fatalError("Failed to decode `User`.")
        }
        
        self.init(entity: entity, insertInto: nil)
        
        // decoding
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int32.self, forKey: .id)
        self.username = try values.decode(String.self, forKey: .username)
        self.email = try values.decode(String.self, forKey: .email)
        self.registry = try values.decode(Date.self, forKey: .registry).timeIntervalSince1970
    }
}
