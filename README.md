# FormatterKit

A lightweight date and price formatting helper with formatter caching, locale resolution, and custom format support.

## Formatters

- **Date** — wraps `DateFormatter` via `DateFormatterManager`, with convenience extensions on `Date`, `String`, and `TimeInterval`.
- **Price** — wraps `NumberFormatter` (accounting currency style) via `PriceFormatterManager`, with a convenience extension on `Int` (price expressed in cents).

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

- Performance: `DateFormatter`/`NumberFormatter` instances are cached and reused to avoid recreating expensive formatters repeatedly.
- Thread safety: cache access and formatter usage are protected by a lock, so formatting/parsing APIs stay synchronous and safe.
- Locale handling: each manager resolves the locale via a `LocaleResolver` that tries the first preferred user language supported by `Bundle.main.localizations`; if none matches, it falls back to `en`.
- Extensibility: define your own date formats by conforming to `DateFormatTypeProtocol`, or your own price formats by conforming to `PriceFormatTypeProtocol`.
- Cache key: derived from the conforming type, its format-specific part (`formatString` for dates, `currencyCode` for prices), and the resolved locale identifier.

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

Prices work the same way, conforming to `PriceFormatTypeProtocol` and formatting an `Int` expressed in cents:

```swift
import FormatterKit

struct USD: PriceFormatTypeProtocol {
    let currencyCode: String = "USD"
}

let priceString = 1299.price(using: USD()) // "$12.99"
```

## Using The Managers Directly

```swift
import Foundation
import FormatterKit

let dateManager = DateFormatterManager.shared
let format = APIDateFormat()

let text = dateManager.string(from: Date(), using: format)
let date = dateManager.date(from: "2026-04-05", using: format)

let priceManager = PriceFormatterManager.shared
let price = priceManager.string(priceInCents: 1299, using: USD())
```

## Public API

- `DateFormatterManaging`
- `DateFormatterManager.shared`
- `Date.string(using:)`
- `String.date(using:)`
- `TimeInterval.string(using:)`
- `DateFormatTypeProtocol`
- `PriceFormatterManaging`
- `PriceFormatterManager.shared`
- `Int.price(using:)`
- `PriceFormatTypeProtocol`

## Example App: FormatterKitApp

Launch the Example app located in `Example/` for a minimal integration sample.

## License

MIT — see [LICENSE](LICENSE).
