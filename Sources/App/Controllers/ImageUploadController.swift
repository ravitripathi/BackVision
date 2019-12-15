//
//  ImageUploadController.swift
//  App
//
//  Created by Ravi Tripathi on 15/12/19.
//

import Foundation
import Vapor
import Vision

final class ImageUploadController {
    
    var data: Data?
    var textRecognitionRequest: VNRecognizeTextRequest
    
    init() {
        textRecognitionRequest = VNRecognizeTextRequest()
        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    func postUpload(_ req: Request) throws -> Future<HTTPResponse> {
        
        let promise: Promise<HTTPResponse> = req.eventLoop.newPromise()
        
        guard let decodedRequest = try? req.content.decode(MyFile.self) else {
            throw Abort(.badRequest)
        }
        
        _ = decodedRequest.map { (file) in
            self.data = file.filedata
        }
        
        guard let data = self.data else {
            throw Abort(.badRequest)
        }
        
        recogniseImage { (responseString) in
            let response = HTTPResponse(status: .ok, body: responseString)
            promise.succeed(result: response)
        }
        self.processImage(imageData: data)
        return promise.futureResult
    }
    
    func recogniseImage(completion: @escaping (String) -> ()) {
        var transcript = ""
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    let maximumCandidates = 1
                    for observation in requestResults {
                        guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                        transcript += candidate.string
                        transcript += "\n"
                    }
                }
            }
            completion(transcript)
        })
    }
    
    func processImage(imageData: Data) {
        let handler = VNImageRequestHandler(data: imageData, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
}

fileprivate struct MyFile: Content {
    var filedata: Data
}
