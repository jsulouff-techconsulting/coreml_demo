//
//  ImageClassViewModel.swift
//  CoreMLAssn
//
//  Created by Joshua Sulouff on 10/29/25.
//
import Combine
import CoreML
import SwiftUI

let inferenceRes = (224, 224)

final class ImageClassViewModel: ObservableObject {
    
    enum State {
        case unready, ready, processing, success(Success), failed(Failure)
    }
    
    @Published var state:State = .unready
    
    func ready() {
        self.state = .ready
    }
    
    struct Success {
        var identifiedAs:String
    }
    
    func finish(_ id: String) {
        self.state = .success(Success(identifiedAs: id))
    }
    
    struct Failure {
        var reason:String
    }
    
    func fail(reason:String) {
        debugPrint("The model failed: \(reason)")
        self.state = .failed(Failure(reason: reason))
    }
    
    func tryInference(image:UIImage) async {
        self.state = .processing
        do {
            let model = try MobileNetV2(configuration: .init())
            if let buffer = convertImage(image: image) {
                let output = try model.prediction(image: buffer)
                debugPrint("Image inference complete: \(output)")
                self.finish(output.classLabel)
            }
            else {
                self.fail(reason: "Could not convert the image to a CVBuffer")
                return
            }
        }
        catch (let err) {
            self.fail(reason: "\(err)")
        }
    }
}
