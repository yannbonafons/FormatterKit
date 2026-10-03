# FormatterKit

A lightweight date and price formatting helper with formatter caching, locale resolution, and custom format support.

## Requirements

- iOS 17+
- Swift 6.0
- Xcode 26+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yannbonafons/FormatterKit", from: "1.0.0")
]
```

## How It Works

- Performance: `DateFormatter` instances are cached and reused to avoid recreating expensive formatters repeatedly.
- Thread safety: cache access and formatter usage are protected by a lock, so formatting/parsing APIs stay synchronous and safe.
- Locale handling: the manager tries to use the first preferred user language supported by `Bundle.main.localizations`; if none matches, it falls back to `en`.
- Extensibility: you can define your own formats by conforming to `DateFormatTypeProtocol`.
- Default cache key: `cacheKey` defaults to `"\(String(describing: self))\(formatString)"` via a protocol extension (you can still override it when needed).

## Quick Start

```swift
import Foundation
import FormatterKit

struct APIDateFormat: DateFormatTypeProtocol {
    let formatString: String = "yyyy-MM-dd"
}

let format = APIDateFormat()

let stringValue = Date().string(using: format)
let dateValue = "2026-04-05".date(using: format)
```

If you need a custom cache strategy, you can override `cacheKey`:

```swift
struct VersionedFormat: DateFormatTypeProtocol {
    let formatString: String = "yyyy-MM-dd"
    var cacheKey: String { "v2_\(formatString)" }
}
```

## Using The Manager Directly

```swift
import Foundation
import FormatterKit

let manager = DateFormatterManager.shared
let format = APIDateFormat()

let text = manager.string(from: Date(), using: format)
let date = manager.date(from: "2026-04-05", using: format)
```

## Public API

- `DateFormatterManaging`
- `DateFormatterManager.shared`
- `Date.string(using:)`
- `String.date(using:)`
- `TimeInterval.string(using:)`
- `DateFormatTypeProtocol`

## Example App: DateFormatterApp

Launch the Example app located in `Example/` for a minimal integration sample.

## License

MIT — see [LICENSE](LICENSE).
