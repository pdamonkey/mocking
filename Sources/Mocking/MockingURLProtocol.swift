//
//  MockingURLProtocol.swift
//  Mocking
//
//  Created by Matthew Gallagher on 28/06/2023.
//

import OSLog
import Foundation

/// MockingURLProtocol used to mock URL responses for offline user or testing.
public final class MockingURLProtocol: URLProtocol {
    private static var mockedRequests: [URLRequest] = []
    private static var mockedURLs: [URL: Mock] = [:]
    private static var mockedRegex: [String: Mock] = [:]
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "mocking")

    /// Register ``MockingURLProtocol`` as a URL Protocol.
    public static func register() {
        URLProtocol.registerClass(MockingURLProtocol.self)
    }

    /// Unregister ``MockingURLProtocol`` as a URL Protocol.
    public static func unregister() {
        mockedRequests = []
        URLProtocol.unregisterClass(MockingURLProtocol.self)
    }

    /// Add a URL mock response.
    /// - Parameters:
    ///   - url: The url to be mocked
    ///   - data: The data to return
    ///   - response: The response to return
    public static func mock(url: URL, data: Data, response: HTTPURLResponse) {
        mockedURLs[url] = Mock(data: data, response: response, error: nil)
    }

    /// Add a URL mock response.
    /// - Parameters:
    ///   - url: The url to be mocked
    ///   - data: The data to return
    ///   - statusCode: The status code to return
    public static func mock(url: URL, data: Data, statusCode: Int = 200) {
        mockedURLs[url] = Mock(data: data, response: HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!, error: nil)
    }

    /// Add a URL mock response.
    /// - Parameters:
    ///   - url: The url to be mocked
    ///   - error: The error to return
    ///   - statusCode: The status code to return
    public static func mock(url: URL, error: Error, statusCode: Int) {
        mockedURLs[url] = Mock(data: nil, response: HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!, error: error)
    }

    /// Add a mock response using regex to match against the URL.
    /// - Parameters:
    ///   - regex: The regex to used to mock the URL
    ///   - data: The data to return
    ///   - statusCode: The status code to return, defaults to 200
    public static func mock(regex: String, data: Data, statusCode: Int = 200) {
        mockedRegex[regex] = Mock(data: data, response: HTTPURLResponse(url: URL.example, statusCode: statusCode, httpVersion: nil, headerFields: nil)!, error: nil)
    }

    /// Indicates if the `mock` argument was passed on launch.
    /// - returns a boolean value indicating the result
    public static var isMocking: Bool {
        guard let value = CommandLine.arguments.dropFirst().first else { return false }
        return value == "--mocking"
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        guard mockedRequests.contains(request) == false else { return false }

        mockedRequests.append(request)

        guard request.url != nil else {
            logger.warning("⚠️ unable to mock as the request did not contain a valid URL")
            return false
        }

        return true
    }

    public override func startLoading() {
        guard let client = client else {
            Self.logger.warning("⚠️ no client found, could not load the request"); return
        }

        guard let url = request.url else {
            update(client: client, url: URL.example, error: MockingURLError.invalidURL)
            Self.logger.error("⛔️ request did not contain a URL"); return
        }

        var mockedResponse: Mock?

        // Check for mocked URLs
        if let mocked = Self.mockedURLs[url] {
            mockedResponse = mocked
        }

        // Check for Regex mocked URLs
        Self.mockedRegex.keys.forEach { regex in
            if url.sanitised.range(of: regex, options: .regularExpression) != nil, let mocked = Self.mockedRegex[regex] {
                mockedResponse = mocked
                return
            }
        }

        // A mock was found, use it for the response
        if let mockedResponse {
            update(client: client, url: url, response: mockedResponse.response, data: mockedResponse.data, error: mockedResponse.error)
            Self.logger.info("🎭 mocked <\(url.absoluteString, privacy: .public)>"); return
        }

        // Check for mock files matching sanitised URL
        guard let path = Bundle.main.url(forResource: url.sanitised, withExtension: nil) else {
            update(client: client, url: url, error: MockingURLError.notFoundInBundle)
            Self.logger.warning("⚠️ mocked file not found for URL <\(url, privacy: .public) - \(url.sanitised)>"); return
        }

        // Retrieve the data from the mocked path
        guard let data = data(fromPath: path, url: url) else {
            update(client: client, url: url, error: MockingURLError.mockNotReadableData)
            Self.logger.error("⛔️ unable to read mocked url <\(url.sanitised, privacy: .public)>"); return
        }

        update(client: client, url: url, data: data)
        Self.logger.info("🎭 mocked <\(url.absoluteString, privacy: .public)>")
    }

    public override func stopLoading() {}

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    private func update(client: URLProtocolClient, url: URL, response: URLResponse? = nil, data: Data? = nil, error: Swift.Error? = nil) {
        if let data { client.urlProtocol(self, didLoad: data) }
        if let error { client.urlProtocol(self, didFailWithError: error) }

        if let response {
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        } else {
            let response = HTTPURLResponse(url: url, statusCode: (error == nil ? 200 : 501), httpVersion: nil, headerFields: nil)!
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        client.urlProtocolDidFinishLoading(self)
    }

    private func data(fromPath path: URL, url: URL) -> Data? {
        let data: Data?

        if url.pathExtension.isEmpty, let json = try? String(contentsOf: path) {
            data = json.data(using: .utf8)
        } else {
            data = try? Data(contentsOf: path)
        }

        return data
    }
}
