import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var sampleLibraryApp = SampleLibraryApp()
    @State private var selectedCategory = "All" // Initial selection for the Picker
    @State private var selectedIndex = 0 // Track the selected sample index

    // Function to filter samples by category
    private func filteredSamples() -> [Sample] {
        if selectedCategory == "All" {
            return sampleLibraryApp.sampleLibrary.samples
        } else {
            return sampleLibraryApp.sampleLibrary.samples.filter { $0.category == selectedCategory }
        }
    }

    private func dropLibrary(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let folderURL = url {
                        // Handle the dropped folder URL
                        self.sampleLibraryApp.importLibrary(inFolder: folderURL.path)
                        print("Dropped folder path: \(folderURL.path)")
                    }
                }
            }
        }
        return true
    }

    // Handle arrow key presses
    func handleArrowKey(_ direction: Direction) {
        switch direction {
        case .up:
            if selectedIndex > 0 {
                selectedIndex -= 1
            } else {
                // Wrap to the last sample when reaching the top
                selectedIndex = filteredSamples().count - 1
            }
        case .down:
            if selectedIndex < filteredSamples().count - 1 {
                selectedIndex += 1
            } else {
                // Wrap to the first sample when reaching the bottom
                selectedIndex = 0
            }
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
                    Text("Other").tag("Other")
                    Text("Kick").tag("Kick")
                    Text("Snare").tag("Snare")
                    Text("Clap").tag("Clap")
                    Text("Snap").tag("Snap")
                    Text("Hi-Hat").tag("Hi-Hat")
                    Text("Cymbal").tag("Cymbal")
                    Text("Tom").tag("Tom")
                    Text("808").tag("808")
                    Text("Percussion").tag("Percussion")
                    Text("FX").tag("FX")
                }
                .pickerStyle(MenuPickerStyle()) // Display the Picker as a menu style

                // Use a ScrollView to display the samples vertically
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredSamples().indices, id: \.self) { index in
                            Button(action: {
                                // Call the playSound function to play the sample
                                sampleLibraryApp.playSound(fileURL: filteredSamples()[index].fileURL)
                                selectedIndex = index // Update the selected index
                            }) {
                                Text("\(filteredSamples()[index].name): \(filteredSamples()[index].category)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(selectedIndex == index ? Color.blue.opacity(0.8) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }

                // Add a drop target to import a library
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 100)
                    .cornerRadius(10)
                    .onDrop(of: [UTType.directory], isTargeted: nil) { providers in
                        return self.dropLibrary(providers)
                    }
            }
            .onAppear {
                // Set up observers for keyboard events
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let key = event.charactersIgnoringModifiers, key == " " {
                        // Handle spacebar key press
                        sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL)
                        return nil // Consume the event
                    } else if event.keyCode == 125 {
                        // Handle down arrow key press (keyCode 125)
                        handleArrowKey(.down)
                        sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL)
                        return nil // Consume the event
                    } else if event.keyCode == 126 {
                        // Handle up arrow key press (keyCode 126)
                        sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL)
                        handleArrowKey(.up)
                        return nil // Consume the event
                    }
                    return event
                }
            }
        }
        .navigationTitle("Sample Library")
    }
}

enum Direction {
    case up, down
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
