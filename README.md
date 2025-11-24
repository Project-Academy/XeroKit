### Installation

XeroKit is available via the [Swift Package Manager](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). Requires iOS 17.4+ or macOS Ventura and up.

```
https://github.com/Project-Academy/XeroKit
```

### Usage

```swift
 Xero.tokenFetcher = {
    // Your code to fetch the Bearer Token.
    guard let bearer: Bearer = try await supabase.functions
        .invoke("xero-access-token")
    else { throw AuthError.failedToFetchToken }
    return bearer
}

let employees = try await Employee.list()
let employee = try await Employee.with(id: "EMPLOYEE-ID")

let rates = try await EarningsRate.list()
let rate = try await EarningsRate.with(id: "EARNINGS-RATE-ID")
```
