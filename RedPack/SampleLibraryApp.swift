//
//  SampleLibraryApp.swift
//  RedPack
//
//  Created by Joshua Cheng on 9/12/23.
//
import SwiftUI
import Foundation
import AVFoundation
import Combine
// Define the SampleLibraryApp class to handle the user interface and interactions
class SampleLibraryApp: ObservableObject{
    @Published var sampleLibrary: SampleLibrary = SampleLibrary()
    
        var audioPlayer: AVAudioPlayer?
       func importSample() {
           // Construct the relative path to your testfile.wav
            let relativePath = "Test.wav"
            
            // Get the URL of your app's main bundle
           if let bundleURL = Bundle.main.url(forResource: relativePath, withExtension: "wav") {
                // Check if the file actually exists at the specified URL
                if FileManager.default.fileExists(atPath: bundleURL.path) {
                    // Prompt the user for category and metadata input (simplified here).
                    let category = "Default"
                    let metadata = "This is a sample"

                    // Add the sample to the library.
                    sampleLibrary.importSample(fileURL: bundleURL, category: category, metadata: metadata)
                    
                    // Play the imported sound
                    playSound(fileURL: bundleURL)
                    
                    // Update the sample list.
                    updateSampleList()
                } else {
                    // Handle the case where the file does not exist
                    print("File does not exist at: \(bundleURL.path)")
                    // You can also show an error message to the user if needed.
                }
            } else {
                // Handle the case where the file URL is nil
                print("File URL is nil")
                // You can also show an error message to the user if needed.
            }
       }
    // Function to play a sound
       private func playSound(fileURL: URL) {
           do {
               audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
               audioPlayer?.play()
           } catch {
               print("Error playing sound: \(error.localizedDescription)")
           }
       }
    //Funciton to play a sound
    func exportSample(sample: Sample, toDirectory directoryURL: URL) {
        // Implement the export functionality here
        // You should copy the sample's fileURL to the specified directory
        let sourceURL = sample.fileURL
           let fileName = sourceURL.lastPathComponent
           let destinationURL = directoryURL.appendingPathComponent(fileName)
           
           do {
               // Use FileManager to copy the sample file to the export directory.
               try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
               
               // You can add additional logic here, such as displaying a success message.
           } catch {
               // Handle any errors that may occur during the copying process.
               print("Error exporting sample: \(error.localizedDescription)")
               // You can also show an error message to the user.
           }
    }
           

       func updateSampleList() {
           // In this basic implementation, we'll simply notify SwiftUI to refresh the view.
           // You can use @Published properties to achieve this.
           // If you have more complex logic or filters, adjust it accordingly.
           objectWillChange.send()
       }
}



// You would need to add the GUI implementation using a framework like SwiftUI or UIKit
// The GUI will call the methods of the SampleLibraryApp class to interact with the app

