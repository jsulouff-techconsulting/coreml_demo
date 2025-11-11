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
    @Published var identity:String?
    @Published var modelFailReason:String?
    @Published var selectedImage:UIImage?
    
    var MLModel:MobileNetV2?
    
    init() {
        do {
            self.MLModel = try MobileNetV2(configuration: .init())
        }
        catch (let err) {
            self.modelFailReason = err.localizedDescription
        }
    }
    
    func clear() {
        self.identity = nil
        self.modelFailReason = nil
        self.selectedImage = nil
    }
    
    func tryInference(image:UIImage) async {
        guard MLModel != nil else {
            debugPrint("The model is nil.")
            return
        }
        
        do {
            if let buffer = convertImage(image: image) {
                if let output = try MLModel?.prediction(image: buffer) {
                    await MainActor.run {
                        debugPrint("Inference completed. Response: \(output.classLabel)")
                        self.identity = output.classLabel
                    }
                }
                else {
                    debugPrint("The model did not return any data.")
                }
            }
            else {
                debugPrint("Image failed to convert")
                modelFailReason = "Image failed to convert"
            }
        }
        catch (let err) {
            self.modelFailReason = err.localizedDescription
        }
    }
    
    
    
}
