import Foundation

// Define the SampleLibrary class to manage the collection of samples
class SampleLibrary {
    var samples: [Sample] = []

    func importSample(fileURL: URL, category: String, metadata: String, name: String) {
        let sample = Sample(fileURL: fileURL, category: category, metadata: metadata, name: name)
        samples.append(sample)
    }
}
