import SwiftUI

// Define a ButtonStyle for the Splice-style buttons
struct SpliceButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(3)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
            )
    }
}

struct ContentView: View {
    @ObservedObject var sampleLibraryApp = SampleLibraryApp()
    @State private var selectedCategory = "All" // Initial selection for the Picker

    // Function to filter samples by category
    private func filteredSamples() -> [Sample] {
        if selectedCategory == "All" {
            return sampleLibraryApp.sampleLibrary.samples
        } else {
            return sampleLibraryApp.sampleLibrary.samples.filter { $0.category == selectedCategory }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Sample Library App")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    sampleLibraryApp.importSample()
                }) {
                    Text("Import Sample")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(DefaultButtonStyle()) // Use the default button style for this button

                Button(action: {
                    sampleLibraryApp.importLibrary(inFolder: "Sounds/TestKit")
                }) {
                    Text("Import Library")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(DefaultButtonStyle()) // Use the default button style for this button

                Button(action: {
                    if let selectedSample = sampleLibraryApp.sampleLibrary.samples.first {
                        let exportDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        sampleLibraryApp.exportSample(sample: selectedSample, toDirectory: exportDirectoryURL)
                    }
                }) {
                    Text("Export Sample")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(DefaultButtonStyle()) // Use the default button style for this button

                // Add the Picker to filter samples by category
                Picker("Select Category", selection: $selectedCategory) {
                    Text("All").tag("All")
                    Text("Kick").tag("Kick")
                    Text("Snare").tag("Snare")
                    Text("Clap").tag("Clap")
                    Text("Snap").tag("Snap")
                    Text("Hi-Hat").tag("Hi-Hat")
                    Text("Cymbal").tag("Cymbal")
                    Text("Tom").tag("Tom")
                    Text("Percussion").tag("Percussion")
                    Text("FX").tag("FX")
                    Text("Other").tag("Other")
                
                }
                .pickerStyle(MenuPickerStyle()) // Display the Picker as a menu style

                // Use a ScrollView to display the samples vertically
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredSamples(), id: \.fileURL) { sample in
                            Button(action: {
                                // Call the playSound function to play the sample
                                sampleLibraryApp.playSound(fileURL: sample.fileURL)
                            }) {
                                Text("\(sample.name): \(sample.category)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .buttonStyle(SpliceButtonStyle()) // Apply the SpliceButtonStyle to sample buttons
                            }
                        }
                    }
                    .padding()
                }

            }
            .navigationTitle("Sample Library")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
