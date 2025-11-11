//
//  ImageClassView.swift
//  CoreMLAssn
//
//  Created by Joshua Sulouff on 10/29/25.
//

import SwiftUI
import PhotosUI

//https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-select-pictures-using-photospicker

struct ImageClassView: View {
    @StateObject var model = ImageClassViewModel()
    @State var selectionImage: PhotosPickerItem?
    
    struct ResetButton: View {
        var model:ImageClassViewModel
        var body: some View {
            Button("Restart") {
                model.ready()
            }
        }
    }
    
    struct Ready: View {
        var parent:ImageClassView
        var body: some View {
            PhotosPicker( "Select an image to classify", selection: self.parent.$selectionImage, matching:.images)
        }
    }
    
    struct Fail: View {
        var reason: ImageClassViewModel.Failure
        var model: ImageClassViewModel
        var body: some View {
            Text("The classification failed: \(reason.reason)")
            ResetButton(model: model)
        }
    }
    
    struct Processing: View {
        var body: some View {
            Text("Making inference...")
        }
    }
    
    struct Success: View {
        var model:ImageClassViewModel
        var result:ImageClassViewModel.Success
        var body: some View {
            Text("Result:")
            Text("\(result.identifiedAs)")
            ResetButton(model: model)
        }
    }
    
    var body: some View {
        VStack {
            switch model.state {
            case .unready:
            Text("THE VIEW IS NOT READY")
            case .ready:
                Ready(parent: self)
            case .processing:
            Processing()
            case .success(let success):
                Success(model: self.model, result: success)
            case .failed(let failure):
                Fail(reason: failure, model: self.model)
            }
        }
        .onAppear() {
            model.ready()
        }
        .onChange(of: selectionImage) {
            debugPrint("Triggerd onchange")
            self.model.state = .processing
            Task {
                if let selectionImage = selectionImage {
                    do {
                        let ldImage = try await selectionImage.loadTransferable(type: Image.self)
                        guard let ldImage = ldImage else {
                            self.model.fail(reason: "Could not load selected image")
                            return
                        }
                        if let uiimage = ImageRenderer(content: ldImage.resizable().frame(width: 224, height: 224)).uiImage {
                            await self.model.tryInference(image: uiimage)
                        }
                        else {
                            debugPrint("Failed to change image to ui image")
                        }
                    }
                    catch (let err) {
                        self.model.fail(reason: "failed to select an image: \(err)")
                    }
                }
            }
        }
    }
}

struct InferenceFailResultView: View {
    var reason:String
    var body: some View {
        Text("The inference failed: \(self.reason)")
    }
}

struct InferenceSuccessResultView: View {
    var image:UIImage
    var inference:String
    
    var body: some View {
        Text("Best guess: \(inference)")
            .accessibilityIdentifier("success_inference_label")
        
    }
}

#Preview {
    ImageClassView()
}
