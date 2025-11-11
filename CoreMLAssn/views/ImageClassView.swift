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
    var body: some View {
        VStack {
            Button("Reset") {
                self.model.clear()
            }
            if let ident = model.identity {
                if let img = model.selectedImage {
                    InferenceSuccessResultView(image: img, inference: ident)
                }
                else {
                    Text("Inference: \(ident)")
                }
            }
            else if let errReason = model.modelFailReason {
                InferenceFailResultView(reason: errReason)
            }
            else {
                if let selectedImage = model.selectedImage {
                    Image(uiImage: selectedImage)
                    Button("Clear Image") {
                        self.model.selectedImage = nil
                    }
                    Button("Make Inference") {
                        Task {
                            await self.model.tryInference(image: selectedImage)
                        }
                    }
                }
                else {
                    PhotosPicker(selection:self.$selectionImage) {
                        Text("Select an Image")
                    }
                }
                
            }
        }
        
        .onChange(of: selectionImage) {
            guard selectionImage != nil else {
                return
            }
            Task {
                debugPrint("Image selected, starting task")
                if let ldImage = try? await selectionImage?.loadTransferable(type: Image.self) {
                    //https://old.reddit.com/r/swift/comments/1e2jm36/how_do_i_convert_a_swiftui_image_to_data/
                    //this probably isn't how this is supposed to be done
                    if let uiimage = ImageRenderer(content: ldImage.resizable().frame(width: 224, height: 224)).uiImage {
                        await self.model.tryInference(image: uiimage)
                        await self.model.tryInference(image: uiimage)
                    }
                    else {
                        debugPrint("Failed to change image to ui image")
                    }
                }
                else {
                    debugPrint("Photo picker failed.")
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
