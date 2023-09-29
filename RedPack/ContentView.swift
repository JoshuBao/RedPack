import SwiftUI
import UniformTypeIdentifiers
import Foundation
import AppKit

struct ContentView: View {
    @ObservedObject var sampleLibraryApp = SampleLibraryApp()
    @State private var selectedCategory = "All"
    @State private var selectedIndex = 0
    @State private var volume: Double = 0.5
    @State private var scrollTarget: Int? = nil
    @State private var searchText: String = ""
    
    @ObservedObject var draggedSamplesManager = DraggedSamplesManager.shared
    
    @State private var importFolderURL: URL?
    @State private var isTargeted = false
    
    
    private func filteredSamples() -> [Sample] {
        var filteredSamples = sampleLibraryApp.sampleLibrary.samples
        
        // Apply category filter
        if selectedCategory != "All" {
            filteredSamples = filteredSamples.filter { $0.category == selectedCategory }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filteredSamples = filteredSamples.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filteredSamples
    }
    
    private func handleArrowKey(_ direction: Direction) {
        let filteredCount = filteredSamples().count
        switch direction {
        case .up:
            if filteredCount > 1 && selectedIndex > 0 {
                selectedIndex -= 1
                scrollTarget = selectedIndex
            }
        case .down:
            if filteredCount > 1 && selectedIndex < filteredCount - 1 {
                selectedIndex += 1
                scrollTarget = selectedIndex
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
            
            // Search bar
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("TextFieldBackground"))
                    .frame(height: 40)
                
                HStack {
                    TextField("Search Samples", text: $searchText)
                        .foregroundColor(Color.white)
                        .accentColor(Color("PrimaryText"))
                        .background(Color.clear)
                        .cornerRadius(10)
                        .padding(.leading, 8)
                        .onChange(of: searchText) { newValue in
                            // Handle search text change
                        }
                        .colorScheme(.dark)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.trailing, 8)
                        }
                    }
                }
            }
            .frame(width: 300)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
//            Button(action: {
//                sampleLibraryApp.importSample()
//            }) {
//                Text("Import Sample")
//                    .font(.headline)
//                    .padding()
//            }
//            .buttonStyle(DefaultButtonStyle())
//            
//            Button(action: {
//                sampleLibraryApp.importLibrary(inFolder: "Sounds/TestKit", fromBundle:true)
//            }) {
//                Text("Import Library")
//                    .font(.headline)
//                    .padding()
//            }
//            .buttonStyle(DefaultButtonStyle())
//            
//            Button(action: {
//                if let selectedSample = sampleLibraryApp.sampleLibrary.samples.first {
//                    let exportDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                    sampleLibraryApp.exportSample(sample: selectedSample, toDirectory: exportDirectoryURL)
//                }
//            }) {
//                Text("Export Sample")
//                    .font(.headline)
//                    .padding()
//            }
//            .buttonStyle(DefaultButtonStyle())
//            
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
                                
                                let itemProvider = NSItemProvider(object: filteredSamples()[index].fileURL as NSURL)
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
                                        if let draggedIndex = filteredSamples().firstIndex(where: { $0.fileURL == url }) {
                                            let draggedSample = filteredSamples()[draggedIndex]
                                            
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
            
            // DropArea for importing folders
            RoundedRectangle(cornerRadius: 10)
                .fill(isTargeted ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2))
                .overlay(
                    Text("Drop folders here to import")
                        .foregroundColor(isTargeted ? Color.white : Color.primary.opacity(0.5))
                )
                .frame(height: 100)
                .cornerRadius(10)
                .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
                    for provider in providers {
                        // Check if the provider can load a file URL
                        if provider.canLoadObject(ofClass: NSURL.self) {
                            provider.loadObject(ofClass: NSURL.self) { url, error in
                                if let error = error {
                                    self.handleError(error)
                                } else if let url = url as? URL {
                                    // Check if the URL represents a folder
                                    var isDirectory: ObjCBool = false
                                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                                        if isDirectory.boolValue {
                                            // Handle the received folder URL
                                            print("Received folder URL: \(url.path)")
                                            sampleLibraryApp.importLibrary(inFolder: url.path,fromBundle: false)
                                            // Add your custom logic for handling the folder
                                        } else {
                                            // Handle non-folder files if needed
                                        }
                                    }
                                }
                            }
                        } else {
                            print("Error: Provider does not have a file URL representation")
                        }
                       
                    }
                    return true
                
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
    func handleError(_ error: Error) {
        // Handle the error, e.g., show an alert to the user
        print("Error: \(error.localizedDescription)")
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    enum Direction {
        case up, down
    }
}
