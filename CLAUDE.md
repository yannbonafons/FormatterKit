# FormatterKit

A lightweight Swift library that wraps `Foundation.DateFormatter` with a thread-safe, cached singleton and convenience extensions on `Date`, `String`, and `TimeInterval`.

## Project structure

```
Sources/FormatterKit/
  DateFormatType.swift            # DateFormatTypeProtocol + built-in DateFormatType enum
  DateFormatterManager.swift      # Thread-safe singleton (NSLock) with DateFormatter cache
  DateExtensions.swift            # Convenience extensions on Date, String, TimeInterval
Tests/FormatterKitTests/          # Unit tests (Swift Testing)
Example/DateFormatterApp/         # Demo app (Xcode project via project.yml / XcodeGen)
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
| `DateFormatTypeProtocol` | Public `nonisolated` protocol — any conforming type can define a date format (`formatString`) with an auto-generated `cacheKey` |
| `DateFormatType` (enum) | Built-in formats: `iso8601`, `shortDate`, `longDate`, `shortTime`, `fullDateTime`, `dayMonth`, `monthYear`, `custom(String)` |
| `DateFormatterManaging` | Protocol abstracting the manager (for mocking/testing) |
| `DateFormatterManager` | `final class`, singleton (`shared`), thread-safe via `NSLock`. Caches `DateFormatter` instances keyed by `cacheKey`. Resolves locale from device preferred languages falling back to `"en"` |
| `Date` / `String` / `TimeInterval` extensions | Sugar calling `DateFormatterManager.shared` |

### Flow

```
Date/String/TimeInterval  ──▶  DateFormatterManager.shared
                                   │
                                   ├─ cache hit → reuse DateFormatter
                                   └─ cache miss → create, cache, return
```

### Key design decisions

- **NSLock** for thread-safety (not actor) — keeps the API synchronous
- **Generic `DateFormatTypeProtocol`** — consumers can define their own format enums
- **Locale resolution** — picks first device-preferred language supported by the app bundle, defaults to `"en"`

### Access control convention

- `public` only on types/members that the consumer module needs
- `DateFormatType` enum is `internal` — consumers define their own conforming types

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
