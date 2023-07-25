# Mocking

![Platforms](https://img.shields.io/badge/Platforms-iOS-lightgrey.svg)
![Swift](https://img.shields.io/badge/Swift-5.7-F16D39.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Introduction 👋🏼

A Swift package to add Mocking capabilities to your iOS app.

When mocking is enabled and registered, any URL will look for a corresponding JSON file by default that matches the sanitised value of the URL's absoluteString value.  

Additional manual mocking can also be added to override this default behavour for specific needs.  

Any URL that isn't mocked will be reported using OSLog to help idenfity areas to mock.  

## Prerequisites

* Swift 5.7
* iOS 14

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add the Mocking package as a dependency to your `Package.swift` file, and add it as a dependency to your target.

```swift
// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(url: "https://github.com/pdamonkey/Mocking.git", upToNextMajor: "1.0.0")
    ],
    targets: [
        .target(name: "MyPackage", dependencies: ["Mocking"])
    ]
)
```

## Usage

To use the framework, import the module:
```swift
import Mocking
```

Check if the `--mocking` Launch Argument has been set:
```swift
if MockingURLProtocol.isMocking {
    ...
}
```

Register MockingURLProtocol with URLProtocol:
```swift
MockingURLProtocol.register()
```

Add MockingURLProtocol to the URL configuration if required:
```swift
configuration.protocolClasses = [MockingURLProtocol.self]
```


Add mock matching URL to return specific Data object and HTTP Response:
```swift
MockingURLProtocol.mock(url: url, data: data-to-return, response: response-to-return)
```

Add mock matching URL to return specific Data and optional Status Code (defaults to 200)
```swift
MockingURLProtocol.mock(url: url, data: data-to-return, 404)
```

Add mock matching URL to return specific Error and Status Code:
```swift
MockingURLProtocol.mock(url: url, error: MyError.notAuthenticated, statusCode: 401)
```

Use Regex to mock pretified URL's to a particular mock file:
```swift
MockingURLProtocol.mock(regex: "^my-url-thumbnail-*", data: Bundle.main.mockFile(name: "thumbnail"))
```

U&nregister MockingURLProtocol with URLProtocol (if required):
```swift
MockingURLProtocol.unregister()
```
