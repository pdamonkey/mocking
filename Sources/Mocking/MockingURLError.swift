//
//  MockingURLError.swift
//  Mocking
//
//  Created by Matthew Gallagher on 28/06/2023.
//

import Foundation

public enum MockingURLError: Swift.Error, LocalizedError {
    case invalidURL
    case mockNotReadableData
    case notFoundInBundle

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is missing or invalid"
        case .mockNotReadableData:
            return "The mocked data could not be read"
        case .notFoundInBundle:
            return "The mocked data could not be found in the Bundle"
        }
    }
}
