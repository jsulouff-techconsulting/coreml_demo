//
//  AudioTransVM.swift
//  CoreMLAssn
//
//  Created by Joshua Sulouff on 11/11/25.
//
import Combine
import Foundation
import Speech

final class AudioTransVM: ObservableObject {
    enum State {
        case unReady, ready, running, success(AudioTransVM.Success), failure(AudioTransVM.Failure)
    }
    
    struct Success {
        var transcribed:String
        var sentiment:String = ""
    }
    
    struct Failure {
        var reason:String
    }
    
    func ready() {
        self.state = .ready
    }
    
    func fail(_ reason:String) {
        self.state = .failure(Failure(reason: reason))
        debugPrint("The transcription failed: \(reason)")
    }
    
    func finish(transcription:String) {
        self.state = .success(Success(transcribed: transcription))
    }
    
    @Published var state:State = .unReady
    
    func startTranscribingFile(file:URL) async {
        self.state = .running
        SFSpeechRecognizer.requestAuthorization {
            speechAuthStatus in
            if speechAuthStatus == .authorized {
                var transcript = ""
                debugPrint("User gave permission to perform speech recognition")
                
                guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id_ID")) else {
                    self.fail("The recognizer failed to initialize.")
                    return
                }
                
                debugPrint("transcribing audio file: \(file)")
                
                let recognizerRequest = SFSpeechURLRecognitionRequest(url: file)
                recognizer.recognitionTask(with: recognizerRequest) {
                    (result, error) in
                    
                    guard let result = result else {
                        self.fail("\(error!)")
                        return
                    }
                    
                    if result.isFinal {
                        debugPrint("Transcription complete")
                        self.finish(transcription: result.bestTranscription.formattedString)
                    }
                }
            }
            else {
                self.fail("Permission denied.")
                return
            }
        }
    }
    
}
