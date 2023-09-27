import Foundation
import UniformTypeIdentifiers

class DraggedSamplesManager: ObservableObject {
    static let shared = DraggedSamplesManager()

    @Published var draggedSampleIndex: Int?

    private init() {}

    func isSampleDragged(_ index: Int) -> Bool {
        return draggedSampleIndex == index
    }

    func setDraggedSampleIndex(_ index: Int?) {
        draggedSampleIndex = index
    }

    func exportSample(_ sample: Sample, to destinationURL: URL) {
 
            do {
                try FileManager.default.copyItem(at: sample.fileURL, to: destinationURL)
                print("Sample exported successfully.")
            } catch {
                print("Error exporting sample: \(error.localizedDescription)")
            }
        
    }

    func exportSampleToDesktop(_ sample: Sample) {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let destinationURL = desktopURL.appendingPathComponent(sample.name)
        exportSample(sample, to: destinationURL)
    }

    func exportSampleToFolder(_ sample: Sample, folderURL: URL) {
        let destinationURL = folderURL.appendingPathComponent(sample.name)
        exportSample(sample, to: destinationURL)
    }

    func exportSampleToApplication(_ sample: Sample, applicationURL: URL) {
        // You can customize this method to handle exporting to specific applications
        // For example, you can use the `NSWorkspace.shared.open(_:)` method to open the application with the sample.
    }
}
