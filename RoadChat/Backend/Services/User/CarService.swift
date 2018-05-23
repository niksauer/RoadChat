//
//  CarService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 06.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import UIKit

struct CarService: JSendService {
    
    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.Car.PublicCar
    let client: JSendAPIClient

    init(hostname: String, port: Int, credentials: APICredentialStore?) {
        self.client = JSendAPIClient(hostname: hostname, port: port, basePath: "car", credentials: credentials)
    }
    
    // MARK: - Public Methods
    func get(carID: RoadChatKit.Car.ID, completion: @escaping (PrimaryResource?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(carID)") { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func update(carID: RoadChatKit.Car.ID, to car: RoadChatKit.CarRequest, completion: @escaping (Error?) -> Void) throws {
        try client.makePUTRequest(to: "/\(carID)", body: car) { result in
            completion(self.getError(from: result))
        }
    }
    
    func delete(carID: RoadChatKit.Car.ID, completion: @escaping (Error?) -> Void) {
        client.makeDELETERequest(to: "/\(carID)") { result in
            completion(self.getError(from: result))
        }
    }
    
    func getImage(carID: RoadChatKit.Car.ID, completion: @escaping (RoadChatKit.Image.PublicImage?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(carID)/image") { result in
            let result = self.decode(RoadChatKit.Image.PublicImage.self, from: result)
            completion(result.instance, result.error)
        }
    }

    /// https://stackoverflow.com/questions/29623187/upload-image-with-multipart-form-data-ios-in-swift
    func uploadImage(_ image: UIImage, carID: RoadChatKit.Car.ID, completion: @escaping (Error?) -> Void) {
        var url = URL(string: "\(client.baseURL)/\(carID)/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        func generateBoundary() -> String {
            return "Boundary-\(UUID().uuidString)"
        }

        let boundary = generateBoundary()

        func photoDataToFormData(data: Data, boundary: String, fileName: String) -> Data {
            var fullData = Data()

            // 1 - Boundary should start with --
            let lineOne = "--" + boundary + "\r\n"
            fullData.append(lineOne.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

            // 2
            let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"\r\n"
            fullData.append(lineTwo.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

            // 3
            let lineThree = "Content-Type: image/jpg\r\n\r\n"
            fullData.append(lineThree.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

            // 4
            fullData.append(data)

            // 5
            let lineFive = "\r\n"
            fullData.append(lineFive.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

            // 6 - The end. Notice -- at the start and at the end
            let lineSix = "--" + boundary + "--\r\n"
            fullData.append(lineSix.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

            return fullData
        }

        let fullData = photoDataToFormData(data: UIImageJPEGRepresentation(image, 1)!, boundary: boundary, fileName: "car.jpg")
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")

        // REQUIRED!
        request.setValue(String(fullData.count), forHTTPHeaderField: "Content-Length")

        request.httpBody = fullData
        request.httpShouldHandleCookies = false
        
        client.executeSessionDataTask(request: request) { result in
            completion(self.getError(from: result))
        }
    }

}
