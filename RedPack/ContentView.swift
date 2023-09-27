import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var sampleLibraryApp = SampleLibraryApp()
    @State private var selectedCategory = "All"
    @State private var selectedIndex = 0
    @State private var volume: Double = 0.5
    @State private var scrollTarget: Int? = nil

    @ObservedObject var draggedSamplesManager = DraggedSamplesManager.shared

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
                        self.sampleLibraryApp.importLibrary(inFolder: folderURL.path)
                        print("Dropped folder path: \(folderURL.path)")
                    }
                }
            }
        }
        return true
    }

    func handleArrowKey(_ direction: Direction) {
        let filteredCount = filteredSamples().count
        switch direction {
        case .up:
            if filteredCount > 1 {
                if selectedIndex > 0 {
                    selectedIndex -= 1
                    scrollTarget = selectedIndex
                } else {
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
                    selectedIndex = 0
                    scrollTarget = selectedIndex
                }
            }
        }
    }

    private func handlePickerSelectionChange() {
        let filtered = filteredSamples()

        if filtered.isEmpty {
            selectedIndex = -1
        } else if selectedIndex >= filtered.count {
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

            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: 10) {
                        ForEach(filteredSamples().indices, id: \.self) { index in
                            let isDragged = draggedSamplesManager.isSampleDragged(index)

                            Button(action: {
                                selectedIndex = index
                                sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                            }) {
                                Text("\(filteredSamples()[index].name): \(filteredSamples()[index].category)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(selectedIndex == index ? Color.blue.opacity(0.8) : Color.clear)
                                    .cornerRadius(8)
                                    .id(index)

                                    .opacity(isDragged ? 0.5 : 1.0)
                            }
                            .onDrag {
                                draggedSamplesManager.setDraggedSampleIndex(index)

                                // Create an NSItemProvider with a file URL
                                let itemProvider = NSItemProvider(object: filteredSamples()[index].fileURL as NSURL)

                                // Set a preferred file name if you want
                                itemProvider.suggestedName = filteredSamples()[index].name

                                return itemProvider
                            }
                            .onDrop(of: [UTType.fileURL], isTargeted: nil) { providers in
                                draggedSamplesManager.setDraggedSampleIndex(nil)

                                guard let itemProvider = providers.first else {
                                    return false
                                }

                                itemProvider.loadObject(ofClass: NSURL.self) { item, error in
                                    if let url = item as? URL {
                                        // Check if the dragged URL is a sample file URL
                                        if let draggedIndex = filteredSamples().firstIndex(where: { $0.fileURL == url }) {
                                            let draggedSample = filteredSamples()[draggedIndex]

                                            // Destination URL on the desktop
                                            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
                                            let destinationURL = desktopURL.appendingPathComponent(draggedSample.name)

                                            do {
                                                try FileManager.default.copyItem(at: draggedSample.fileURL, to: destinationURL)
                                                print("Sample copied successfully.")
                                            } catch {
                                                print("Error copying sample: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }

                                return true
                            }



                        }
                    }
                    .onChange(of: scrollTarget) { target in
                        withAnimation {
                            scrollViewProxy.scrollTo(target, anchor: .center)
                        }
                    }
                }
                .padding(.horizontal)
                .padding()
            }

            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .cornerRadius(10)
                .onDrop(of: [UTType.directory], isTargeted: nil) { providers in
                    return self.dropLibrary(providers)
                }

            HStack {
                Text("Volume:")
                Slider(value: $volume, in: 0.0...1.0)
                    .frame(width: 150)
                    .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if let key = event.charactersIgnoringModifiers, key == " " {
                    sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                    return nil
                } else if event.keyCode == 125 {
                    handleArrowKey(.down)
                    sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                    return nil
                } else if event.keyCode == 126 {
                    sampleLibraryApp.playSound(fileURL: filteredSamples()[selectedIndex].fileURL, volume: volume)
                    handleArrowKey(.up)
                    return nil
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
