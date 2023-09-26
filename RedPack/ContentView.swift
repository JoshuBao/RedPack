import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var sampleLibraryApp = SampleLibraryApp()
    @State private var selectedCategory = "All" // Initial selection for the Picker
    @State private var selectedIndex = 0 // Track the selected sample index
    @State private var volume: Double = 0.5 // Initial volume value
    @State private var scrollTarget: Int? = nil // Track scroll target
    
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
        let filteredCount = filteredSamples().count
        switch direction {
        case .up:
            if filteredCount > 1 {
                if selectedIndex > 0 {
                    selectedIndex -= 1
                    scrollTarget = selectedIndex
                } else {
                    // Wrap to the last sample when reaching the top
                    selectedIndex = filteredCount - 1
                    scrollTarget = selectedIndex
                }
            }
        case .down:
            if filteredCount > 1 {
                if selectedIndex < filteredCount - 1 {
                    selectedIndex += 1
                    scrollTarget = selectedIndex
                } else {
                    // Wrap to the first sample when reaching the bottom
                    selectedIndex = 0
                    scrollTarget = selectedIndex
                }
            }
        }
    }
    // Handle picker selection change
    private func handlePickerSelectionChange() {
        let filtered = filteredSamples()
        
        if filtered.isEmpty {
            // If there are no samples in the selected category, set selectedIndex to -1
            selectedIndex = -1
        } else if selectedIndex >= filtered.count {
            // If the previous selectedIndex is out of bounds for the new category, set it to 0
            selectedIndex = 0
        }
    }
    
    var body: some View {
     
            VStack {
                Text("RedPack")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    sampleLibraryApp.importSample()
                }) {
                    Text("Import Sample")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(DefaultButtonStyle())
                
                Button(action: {
                    sampleLibraryApp.importLibrary(inFolder: "Sounds/TestKit")
                }) {
                    Text("Import Library")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(DefaultButtonStyle())
                
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
                .buttonStyle(DefaultButtonStyle())
                
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
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCategory) { _ in
                     handlePickerSelectionChange()
                 }
                .padding(.horizontal)
                
                // Use a ScrollView to display the samples vertically
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        LazyVStack(spacing: 10) {
                            ForEach(filteredSamples().indices, id: \.self) { index in
                                Button(action: {
                                    
                                    selectedIndex = index // Update the selected index
                                    // Call the playSound function to play the sample
                                    sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                                }) {
                                    Text("\(filteredSamples()[index].name): \(filteredSamples()[index].category)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(selectedIndex == index ? Color.blue.opacity(0.8) : Color.clear)
                                        .cornerRadius(8)
                                        .id(index) // Assign an ID for ScrollViewReader
                                }
                            }
                        }
                        
                        .onChange(of: scrollTarget) { target in
                            // Scroll to the target when it changes
                            withAnimation {
                                scrollViewProxy.scrollTo(target, anchor: .center)
                            }
                        }
                        
                    }
                    //padding for the sides of the scrollview
                    .padding(.horizontal)
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
                
                // Add a volume slider
                HStack {
                    Text("Volume:")
                    Slider(value: $volume, in: 0.0...1.0)
                        .frame(width: 150)
                        .padding(.horizontal)
                }
                .padding()
            }
            .onAppear {
                // Set up observers for keyboard events
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let key = event.charactersIgnoringModifiers, key == " " {
                        // Handle spacebar key press
                        sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                        return nil // Consume the event
                    } else if event.keyCode == 125 {
                        // Handle down arrow key press (keyCode 125)
                        handleArrowKey(.down)
                        sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                        return nil // Consume the event
                    } else if event.keyCode == 126 {
                        // Handle up arrow key press (keyCode 126)
                        sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                        handleArrowKey(.up)
                        return nil // Consume the event
                    }
                    return event
                }
            }
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
