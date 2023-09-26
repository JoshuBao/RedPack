import Foundation
import AVFoundation

// Define the Sample class to represent individual samples
class Sample {
    var fileURL: URL
    var category: String
    var metadata: String
    var name: String // Include the 'name' property

    init(fileURL: URL, category: String, metadata: String, name: String) {
        self.fileURL = fileURL
        self.category = category
        self.metadata = metadata
        self.name = name // Initialize the 'name' property
    }
}
