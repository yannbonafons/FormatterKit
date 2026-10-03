# FormatterKit

A lightweight Swift library that wraps `Foundation.DateFormatter` and `Foundation.NumberFormatter` with thread-safe, cached singletons and convenience extensions on `Date`, `String`, `TimeInterval`, and `Int`.

## Project structure

```
Sources/FormatterKit/
  Common/
    FormatterProtocol.swift         # Shared FormatterProtocol (cache key generation)
  DateFormatter/
    DateFormatType.swift            # DateFormatTypeProtocol + built-in DateFormatType enum
    DateFormatterManager.swift      # Thread-safe singleton (NSLock) with DateFormatter cache
    DateExtensions.swift            # Convenience extensions on Date, String, TimeInterval
  PriceFormatter/
    PriceFormatTypeProtocol.swift   # PriceFormatTypeProtocol (currencyCode)
    PriceFormatterManager.swift     # Thread-safe singleton (NSLock) with NumberFormatter cache
    PriceExtensions.swift           # Convenience extension on Int (price in cents)
  Locale/
    Locale+Utils.swift              # LocaleResolverProtocol + LocaleResolver (device locale resolution)
Tests/FormatterKitTests/            # Unit tests (Swift Testing), locale injected via a mock LocaleResolverProtocol
Example/FormatterKitApp/            # Demo app (Xcode project via project.yml / XcodeGen)
```

## Stack

- Swift 6, strict concurrency (`Sendable`)
- SPM (swift-tools-version: 6.2)
- Minimum deployment: iOS 17
- Testing framework: Swift Testing (`import Testing`)
- Approachable concurrency: YES
- Default actor isolation: MainActor
- Strict concurrency checking: Complete
- SwiftLint via SPM build tool plugin (`realm/SwiftLint 0.57+`)

## Architecture

### Core components

| Type | Role |
|---|---|
| `FormatterProtocol` | Public `nonisolated` protocol shared by both formatters — derives a `cacheKey` from a `specificKeyPart` and the resolved locale identifier |
| `DateFormatTypeProtocol` | Public `nonisolated` protocol, extends `FormatterProtocol` — any conforming type can define a date format (`formatString`) |
| `DateFormatType` (enum) | Built-in formats: `iso8601`, `shortDate`, `longDate`, `shortTime`, `fullDateTime`, `dayMonth`, `monthYear`, `custom(String)` |
| `DateFormatterManaging` | Protocol abstracting the date manager (for mocking/testing) |
| `DateFormatterManager` | `final class`, singleton (`shared`), thread-safe via `NSLock`. Caches `DateFormatter` instances keyed by `cacheKey` |
| `PriceFormatTypeProtocol` | Public `nonisolated` protocol, extends `FormatterProtocol` — any conforming type defines a `currencyCode` |
| `PriceFormatterManaging` | Protocol abstracting the price manager (for mocking/testing) |
| `PriceFormatterManager` | `final class`, singleton (`shared`), thread-safe via `NSLock`. Caches `NumberFormatter` (`.currencyAccounting` style) instances keyed by `cacheKey` |
| `LocaleResolverProtocol` / `LocaleResolver` | Resolves the locale used by both managers from device preferred languages, falling back to `"en"`. Each manager holds one, swappable via an internal `updateLocaleResolver(localeResolver:)` for tests |
| `Date` / `String` / `TimeInterval` extensions | Sugar calling `DateFormatterManager.shared` |
| `Int` extension (`price(using:)`) | Sugar calling `PriceFormatterManager.shared`, treating the integer as a price in cents |

### Flow

```
Date/String/TimeInterval  ──▶  DateFormatterManager.shared
Int (cents)               ──▶  PriceFormatterManager.shared
                                   │
                                   ├─ cache hit → reuse formatter
                                   └─ cache miss → create (using localeResolver.resolvedLocale), cache, return
```

### Key design decisions

- **NSLock** for thread-safety (not actor) — keeps the API synchronous
- **Generic `DateFormatTypeProtocol` / `PriceFormatTypeProtocol`** — consumers can define their own format enums
- **Locale resolution** — picks first device-preferred language supported by the app bundle, defaults to `"en"`; injectable per-manager for testing (see Testing below)
- **`.currencyAccounting` style** for prices — negative amounts render in parentheses (e.g. `($12.34)`) rather than with a minus sign

### Access control convention

- `public` only on types/members that the consumer module needs
- `DateFormatType` enum, `LocaleResolverProtocol`/`LocaleResolver`, and the managers' `updateLocaleResolver`/`clearCache` testing hooks are `internal` — consumers define their own conforming types

## Testing

- Both managers are singletons with an injectable `localeResolver: LocaleResolverProtocol`. Tests force a locale with a mock conforming to `LocaleResolverProtocol` and call `updateLocaleResolver(localeResolver:)` on `DateFormatterManager.shared` / `PriceFormatterManager.shared`, restoring the default `LocaleResolver()` in a `defer` block afterward.
- Because the managers are shared global state, test suites that mutate the locale resolver use `@Suite(.serialized)` so tests don't race each other, and reset the cache in `init()`.

## Git flow

- **main** — stable releases (tags `x.y.z`)
- **develop** — integration branch
- Feature branches from `develop`, merged back via PR
- Current version: **1.0.1**

## Code Style

- **4-space indentation**
- **PascalCase** for types, **camelCase** for properties/methods
- **@Observable** classes (only use Combine when @Observable is not enough)
- **Swift concurrency** (async/await) over Combine
- **Swift Testing** for unit tests (not XCTest)
- No force unwrapping
- Prefer `let` over `var`
- `public` only where necessary for cross-module access
- ViewModifiers exposed via View extensions (ViewModifier is private)
- `MARK:` comments to organize file sections
- Doc comments (`///`) on public API

### Other
- Use shell command (ls, grep, find, git) when possible
