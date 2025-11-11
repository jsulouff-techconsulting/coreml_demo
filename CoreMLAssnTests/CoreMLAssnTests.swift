//
//  CoreMLAssnTests.swift
//  CoreMLAssnTests
//
//  Created by Joshua Sulouff on 10/29/25.
//

import Testing
@testable import CoreMLAssn
import UIKit

struct CoreMLAssnTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    func load_image(named:String) async throws {
        let ROOT = "TestImages"
    }
    
    @Test func image_check() async throws {
        
        
        
        let images:[(String, UIImage)] = [
            ("shark", UIImage(named:"TestImages/shark.jpg")!)
        ]
        
        
        
    }
    
    @Test func sound_check() async throws {
        let sounds:[(String, String)] = [
            ("I kinda popped off, and went gamer mode on these literal children.", "clip.wav")
        ]
    }
    

}
