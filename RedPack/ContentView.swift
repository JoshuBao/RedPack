import SwiftUI

struct ContentView: View {
    @ObservedObject var sampleLibraryApp = SampleLibraryApp()

    var body: some View {
        VStack {
            Text("Sample Library App")
                .font(.largeTitle)
                .padding()

            Button(action: {
                sampleLibraryApp.importSample()
                //sampleLibraryApp.updateSampleList()
            }) {
                Text("Import Sample")
                    .font(.headline)
                    .padding()
            }
            
            Button(action: {
                // Call the assignMetadataToSamples function with a folder path
                sampleLibraryApp.assignMetadataToSamples(inFolder: "Sounds/TestKit")
            }) {
                Text("Import Library")
                    .font(.headline)
                    .padding()
            }

            Button(action: {
                // Export the first sample in the library to the document directory
                if let selectedSample = sampleLibraryApp.sampleLibrary.samples.first {
                    let exportDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    sampleLibraryApp.exportSample(sample: selectedSample, toDirectory: exportDirectoryURL)
                }
            }) {
                Text("Export Sample")
                    .font(.headline)
                    .padding()
            }

            List(sampleLibraryApp.sampleLibrary.samples, id: \.fileURL) { sample in
                Text("\(sample.category): \(sample.metadata)")
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
