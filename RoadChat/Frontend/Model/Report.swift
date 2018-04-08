//
//  Reportable.swift
//  RoadChat
//
//  Created by Niklas Sauer on 23.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

protocol ReportOwner {
    var logDescription: String { get }
}

enum ReportType {
    case failedServerOperation(Operation, resource: String?, isMultiple: Bool, error: Error)
    case successfulCoreDataOperation(Operation, resource: String?, isMultiple: Bool)
    case failedCoreDataOperation(Operation, resource: String?, isMultiple: Bool, error: Error)
    case failedServerRequest(requestType: String, error: Error)
    
    enum Operation {
        case create
        case retrieve
        case update
        case delete
        case fetch
        case upvote
        case downvote
        
        var presentTense: String {
            switch self {
            case .retrieve:
                return "retrieve"
            case .update:
                return "updated"
            case .create:
                return "create"
            case .delete:
                return "delete"
            case .fetch:
                return "fetch"
            case .upvote:
                return "update"
            case .downvote:
                return "downvote"
            }
        }
        
        var pastTense: String {
            switch self {
            case .retrieve, .update:
                return "saved/updated"
            case .create:
                return "created"
            case .delete:
                return "deleted"
            case .fetch:
                return "fetched"
            case .upvote:
                return "upvoted"
            case .downvote:
                return "downvoted"
            }
        }
        
        var coreData: String {
            switch self {
            case .retrieve, .update:
                return "save/update"
            default:
                return presentTense
            }
        }
    }
}

struct Report: CustomStringConvertible {

    let type: ReportType
    let owner: ReportOwner?
    
    init(_ type: ReportType, owner: ReportOwner?) {
        self.type = type
        self.owner = owner
    }
    
    var description: String {
        switch type {
        case .failedServerOperation(let action, let resource, let isMultiple, let error):
            return "Failed to \(action.presentTense) \(getResourceMessage(resource: resource, isMultiple: isMultiple)) from server: \(error)"
            
        case .successfulCoreDataOperation(let action, let resource, let isMultiple):
            return "Successfully \(action.pastTense) \(getResourceMessage(resource: resource, isMultiple: isMultiple))."
            
        case .failedCoreDataOperation(let action, let resource, let isMultiple, let error):
            return "Failed to \(action.coreData) \(getResourceMessage(resource: resource, isMultiple: isMultiple)): \(error)"
            
        case .failedServerRequest(let resource, let error):
            return "Failed to send '\(resource)' to server: \(error)"
        }
    }
    
    private func getResourceMessage(resource: String?, isMultiple: Bool) -> String {
        guard let resource = resource else {
            return owner?.logDescription ?? ""
        }
        
        var message = isMultiple ? "'\(resource)'s" : "'\(resource)'"
        message.append("\(owner != nil ? " for \(owner!.logDescription)" : "")")
        
        return message
    }

}
