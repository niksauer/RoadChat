//
//  JSendAPIConnector.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

enum JSendAPIResult {
    case success(JSendResponse)
    case failure(Error)
}

enum JSendResponse {
    case success(JSON)
    case fail(String?)
    case error(String?)
}

enum JSendAPIError: Error {
    case invalidData
    case invalidJSON
}

struct JSendAPIConnector {
    private static let session = URLSession(configuration: .default)
    
    private static func getResponse(for data: Data) throws -> JSendResponse {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
            throw JSendAPIError.invalidData
        }
        
        guard let status = json["status"] as? String else {
            throw JSendAPIError.invalidJSON
        }
        
        switch status {
        case "success":
            guard let data = json["data"] as? JSON else {
                throw JSendAPIError.invalidJSON
            }
            return JSendResponse.success(data)
        case "fail":
            return JSendResponse.fail(json["data"] as? String)
        case "error":
            return JSendResponse.error(json["error"] as? String)
        default:
            throw JSendAPIError.invalidJSON
        }
    }
    
    private static func executeSessionTask(request: URLRequest, completion: @escaping (JSendAPIResult) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            let result: JSendAPIResult
            
            if let data = data {
                do {
                    result = JSendAPIResult.success(try getResponse(for: data))
                } catch {
                    result = JSendAPIResult.failure(error)
                }
            } else {
                result = JSendAPIResult.failure(error!)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    static func makeGETRequest(to url: URL, completion: @escaping (JSendAPIResult) -> Void) {
        let request = URLRequest(url: url)
        executeSessionTask(request: request, completion: completion)
    }
    
    static func makePOSTRequest<T: Encodable>(to url: URL, body: T, completion: @escaping (JSendAPIResult) -> Void) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        executeSessionTask(request: request, completion: completion)
    }

    static func makePUTRequest<T: Encodable>(to url: URL, body: T, completion: @escaping (JSendAPIResult) -> Void) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try JSONEncoder().encode(body)
        executeSessionTask(request: request, completion: completion)
    }
    
    static func makeDELETERequest(to url: URL, completion: @escaping (JSendAPIResult) -> Void) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        executeSessionTask(request: request, completion: completion)
    }
    
}
