//
//  Sample.swift
//  RedPack
//
//  Created by Joshua Cheng on 9/12/23.
//

import Foundation


// Define the Sample class to represent individual samples
class Sample {
    var fileURL: URL
    var category: String
    var metadata: String

    init(fileURL: URL, category: String, metadata: String) {
        self.fileURL = fileURL
        self.category = category
        self.metadata = metadata
    }
}

