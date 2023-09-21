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
           if let path = Bundle.main.path(forResource: "Test", ofType: "wav") {
                  let url = URL(fileURLWithPath: path)
                  
                  do {
                      // Create your audioPlayer in your parent class as a property
                      audioPlayer = try AVAudioPlayer(contentsOf: url)
                      audioPlayer?.play()
                      
                      // Prompt the user for category and metadata input (simplified here).
                      let category = "Default"
                      let metadata = "This is a sample"
                      
                      // Add the sample to the library.
                      sampleLibrary.importSample(fileURL: url, category: category, metadata: metadata)
                      
                      // Update the sample list.
                      updateSampleList()
                  } catch {
                      print("Couldn't load the file")
                      // You can also show an error message to the user if needed.
                  }
              } else {
                  print("File not found")
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

