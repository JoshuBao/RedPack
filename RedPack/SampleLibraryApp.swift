import Foundation
import AVFoundation
import Combine

class SampleLibraryApp: ObservableObject {
    @Published var sampleLibrary: SampleLibrary = SampleLibrary()
    var audioPlayer: AVAudioPlayer?
    
    func importSample() {
        if let path = Bundle.main.path(forResource: "Test", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                if let player = audioPlayer {
                    player.play()
                } else {
                    print("AVAudioPlayer is nil")
                }
                
                let category = "Default"
                let metadata = "This is a sample"
                let name = url.lastPathComponent // Set the name to the file name
                
                sampleLibrary.importSample(fileURL: url, category: category, metadata: metadata, name: name) // Pass the name parameter
                
                updateSampleList()
            } catch {
                print("Couldn't load the file: \(error.localizedDescription)")
                // You can also show an error message to the user if needed.
            }
        } else {
            print("File not found")
            // You can also show an error message to the user if needed.
        }
    }

    func importLibrary(inFolder folderPath: String, fromBundle: Bool = true) {
        let fileManager = FileManager.default

        var folderURL: URL

        if fromBundle {
            if let path = Bundle.main.path(forResource: folderPath, ofType: nil) {
                folderURL = URL(fileURLWithPath: path)
            } else {
                print("Folder path not found in the bundle")
                return
            }
        } else {
            folderURL = URL(fileURLWithPath: folderPath)
        }

        let sampleTypeMapping: [String: String] = [
            "kick": "Kick",
            "snare": "Snare",
            "clap": "Clap",
            "snap": "Snap",
            "hat": "Hi-Hat",
            "hh": "Hi-Hat",
            "cymbal": "Cymbal",
            "tom": "Tom",
            "808": "808",
            "perc": "Percussion",
            "fx": "FX"
        ]

        // Function to recursively search for audio files
        func searchForAudioFiles(inDirectory directoryURL: URL) {
            do {
                let folderContents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)

                for fileURL in folderContents {
                    let fileExtension = fileURL.pathExtension.lowercased()
                    if ["wav", "mp3", "aiff"].contains(fileExtension) {
                        var sampleType = "Other"

                        for (keyword, type) in sampleTypeMapping {
                            if fileURL.lastPathComponent.lowercased().contains(keyword) {
                                sampleType = type
                                break
                            }
                        }

                        let metadata = "This is a \(sampleType) sample"
                        let name = fileURL.lastPathComponent // Set the name to the file name

                        // Add the sample to the library
                        sampleLibrary.importSample(fileURL: fileURL, category: sampleType, metadata: metadata, name: name) // Pass the name parameter

                        // You can also play the sound or perform other actions if needed
                        // playSound(fileURL: fileURL)

                        print("Sample: \(fileURL.lastPathComponent), Type: \(sampleType), Metadata: \(metadata)")
                    } else if fileURL.hasDirectoryPath {
                        // If it's a directory, recursively search for audio files
                        searchForAudioFiles(inDirectory: fileURL)
                    }
                }

                // After importing, update the sample list
                updateSampleList()
            } catch {
                print("Error reading folder contents: \(error)")
            }
        }

        searchForAudioFiles(inDirectory: folderURL)
    }

    func playSound(fileURL: URL, volume: Double) {
           do {
               audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
               if let player = audioPlayer {
                   player.volume = Float(volume) // Set the volume here
                   player.play()
               } else {
                   print("AVAudioPlayer is nil")
               }
           } catch {
               print("Error playing sound: \(error.localizedDescription)")
           }
       }
       
    
    func exportSample(sample: Sample, toDirectory directoryURL: URL) {
        let sourceURL = sample.fileURL
        let fileName = sourceURL.lastPathComponent
        let destinationURL = directoryURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            // You can add additional logic here, such as displaying a success message.
        } catch {
            print("Error exporting sample: \(error.localizedDescription)")
            // You can also show an error message to the user.
        }
    }
    
    func updateSampleList() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

}
