//
//  AudioView.swift
//  CoreMLAssn
//
//  Created by Joshua Sulouff on 11/11/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct AudioTranscriptionView: View {
    @StateObject var model:AudioTransVM = AudioTransVM()
    
    struct Success: View {
        var result:AudioTransVM.Success
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Transcription Result:")
                Text(result.transcribed)
            }
        }
    }
    
    struct Failure: View {
        var result:AudioTransVM.Failure
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Transcription Failed:")
                Text(result.reason)
            }
        }
    }
    
    struct Ready: View {
        @ObservedObject var viewmodel:AudioTransVM
        
        @State var filePickerShown:Bool = false
        @State private var path = URL(string: "")
        
        var body: some View {
            VStack() {
                
            }
            .fileImporter(isPresented: $filePickerShown, allowedContentTypes: [.item]) {
                result in
                switch result {
                    case .success(let url):
                        self.path = url
                        let _ = self.path?.startAccessingSecurityScopedResource()
                    case .failure(let reason):
                        debugPrint("File importer failed: \(reason)")
                }
            }
            .onAppear {
                if self.path != nil {
                    self.viewmodel.ready()
                }
            }
        }
    }
    
    struct Running: View {
        var body: some View {
            Text("Parsing...")
        }
    }
    
    var body: some View {
        switch model.state {
        case .unReady:
            Text("THE VIEW IS NOT READY (THIS IS A BUG).")
        case .ready:
            Self.Ready(viewmodel: self.model)
        case .running:
            Self.Running()
        case .success(let success):
            Self.Success(result: success)
        case .failure(let failure):
            Self.Failure(result: failure)
        }
    }
}

#Preview {
    AudioTranscriptionView()
}
