//
//  MainMenuView.swift
//  CoreMLAssn
//
//  Created by Joshua Sulouff on 11/11/25.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            NavigationLink("Image Description") {
                ImageClassView()
            }
            NavigationLink("Sentiment Analysis") {
                // TODO
            }
                .disabled(true)
            NavigationLink("Audio Transcription") {
                AudioTranscriptionView()
            }
        }
    }
}

#Preview {
    MainMenuView()
}
