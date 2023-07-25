//
//  Extensions.swift
//  Mocking
//
//  Created by Matthew Gallagher on 28/06/2023.
//

import Foundation

// MARK: - URL sanitising
extension URL {
    var sanitised: String {
        guard let withoutScheme = absoluteString.components(separatedBy: "//").last else { return "" }
        return withoutScheme.sanitised
    }

    static var example: URL {
        URL(string: "https://www.example.com")!
    }
}

// MARK: - String sanitising
extension String {
    var sanitised: String {
        replacingOccurrences(of: "/", with: "-")
    }
}

// MARK: - Bundle
extension Bundle {
    public func mockFile(name: String) -> Data {
        guard let path = url(forResource: name, withExtension: nil) else {
            fatalError("Mock file doesn't exist")
        }

        if let contents = try? String(contentsOf: path), let data = contents.data(using: .utf8) {
            return data
        }

        if let data = try? Data(contentsOf: path) {
            return data
        }

        return Data()
    }
}
