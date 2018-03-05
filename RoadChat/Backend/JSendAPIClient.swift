//
//  JSendAPIClient.swift
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

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct JSendAPIClient {
    private let session = URLSession(configuration: .default)
    
    let baseURL: String
    let token: String?

    func makeGETRequest(to path: String, params: JSON?, completion: @escaping (JSendAPIResult) -> Void) {
        let url = URL(baseURL: baseURL, path: path, params: params)
        let request = URLRequest(url: url, method: .get)
        
        executeSessionDataTask(request: request, completion: completion)
    }
    
    func makePOSTRequest<T: Encodable>(to path: String, body: T, completion: @escaping (JSendAPIResult) -> Void) throws {
        let url = URL(baseURL: baseURL, path: path, params: nil)
        let request = try URLRequest(url: url, method: .post, body: body)
        
        executeSessionDataTask(request: request, completion: completion)
    }

    func makePUTRequest<T: Encodable>(to path: String, body: T, completion: @escaping (JSendAPIResult) -> Void) throws {
        let url = URL(baseURL: baseURL, path: path, params: nil)
        let request = try URLRequest(url: url, method: .put, body: body)
        
        executeSessionDataTask(request: request, completion: completion)
    }
    
    func makeDELETERequest(to path: String, params: JSON?, completion: @escaping (JSendAPIResult) -> Void) {
        let url = URL(baseURL: baseURL, path: path, params: nil)
        let request = URLRequest(url: url, method: .delete)
        
        executeSessionDataTask(request: request, completion: completion)
    }
    
    private func executeSessionDataTask(request: URLRequest, completion: @escaping (JSendAPIResult) -> Void) {
        var request = request
        
        // set content type headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // set bearer authorization header
        request.setValue(token, forHTTPHeaderField: "Authorization: Bearer")
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            let result: JSendAPIResult
            
            if let data = data {
                do {
                    result = JSendAPIResult.success(try self.getResponse(for: data))
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
 
    private func getResponse(for data: Data) throws -> JSendResponse {
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
}

extension URL {
    init(baseURL: String, path: String, params: JSON?) {
        var components = URLComponents(string: "\(baseURL)/\(path)")!

        if let params = params {
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: String(describing: value))
                components.queryItems?.append(queryItem)
            }
        }
        
        self = components.url!
    }
}

extension URLRequest {
    init(url: URL, method: HTTPMethod) {
        self.init(url: url)
        
        // set http method
        httpMethod = method.rawValue
    }
    
    init<T: Encodable>(url: URL, method: HTTPMethod, body: T) throws {
        self.init(url: url, method: method)
        
        switch method {
        case .post, .put:
            // set body content
            httpBody = try JSONEncoder().encode(body)
        default:
            break
        }
    }
}
