//
//  SampleLibrary.swift
//  RedPack
//
//  Created by Joshua Cheng on 9/12/23.
//

import Foundation
// Define the SampleLibrary class to manage the collection of samples
class SampleLibrary {
    var samples: [Sample] = []

    func importSample(fileURL: URL, category: String, metadata: String) {
        let sample = Sample(fileURL: fileURL, category: category, metadata: metadata)
        samples.append(sample)
    }
}
