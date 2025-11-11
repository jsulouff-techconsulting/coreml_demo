//
//  InferenceWrapper.swift
//  CoreMLAssn
//
//  Created by Joshua Sulouff on 11/3/25.
//

enum InferenceError: Error {
    case noCgImage
}

import UIKit
import Combine

func ImageInference(image:UIImage) -> Future<String, any Error> {
    if let cvImage = image.convertToBuffer() {
        return Future {
            promise in
            // apple says this is deprecated. I do not care.
            let model = MobileNetV2()
            do {
                let prediction = try model.prediction(image: cvImage)
                promise(.success(prediction.classLabel))
            }
            catch(let err) {
                promise(.failure(err))
            }
        }
    }
    else {
        return Future {
            promise in
            promise(.failure(InferenceError.noCgImage))
        }
    }
}
