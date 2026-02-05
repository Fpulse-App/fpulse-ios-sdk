# FeedbackPulse iOS SDK

Official iOS SDK for [Feedback Pulse](https://fpulse.app) - Collect user feedback in your iOS and macOS apps.

## Requirements

- iOS 14.0+ / macOS 11.0+
- Swift 5.7+
- Xcode 14.0+

## Installation

### Swift Package Manager

Add FeedbackPulse to your project using Swift Package Manager:

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/feedbackpulse/feedbackpulse-ios
   ```
3. Select the version and click **Add Package**

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/feedbackpulse/feedbackpulse-ios", from: "1.0.0")
]
```

## Quick Start

### 1. Configure the SDK

Configure FeedbackPulse in your app's initialization (e.g., `AppDelegate` or `@main App`):

```swift
import FeedbackPulse

// In your AppDelegate or App init
FeedbackPulse.configure(apiKey: "fp_your_api_key_here")
```

Get your API key from the [Feedback Pulse Dashboard](https://fpulse.app/dashboard/settings).

### 2. Submit Feedback

#### Programmatic Submission

```swift
// Simple submission
FeedbackPulse.submit(sentiment: .positive) { result in
    switch result {
    case .success(let response):
        print("Feedback submitted: \(response.feedbackId)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

// With comment
FeedbackPulse.submit(
    sentiment: .negative,
    comment: "The app crashes when I tap the button"
) { result in
    // Handle result
}

// With custom metadata
FeedbackPulse.submit(
    sentiment: .neutral,
    comment: "Could be better",
    metadata: ["screen": "settings", "user_id": "12345"]
) { result in
    // Handle result
}
```

#### Using async/await (iOS 15+)

```swift
do {
    let response = try await FeedbackPulse.submit(
        sentiment: .positive,
        comment: "Love this app!"
    )
    print("Submitted: \(response.feedbackId)")
} catch {
    print("Error: \(error)")
}
```

### 3. Pre-built Feedback UI (SwiftUI)

Use the built-in feedback view for a ready-to-use UI:

```swift
import SwiftUI
import FeedbackPulse

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        Button("Send Feedback") {
            showFeedback = true
        }
        .feedbackSheet(isPresented: $showFeedback)
    }
}
```

#### Customize the Feedback View

```swift
.feedbackSheet(
    isPresented: $showFeedback,
    title: "How's your experience?",
    subtitle: "We'd love to hear from you",
    primaryColor: .blue,
    onSubmit: { sentiment, comment in
        print("User submitted: \(sentiment)")
    }
)
```

Or use `FeedbackView` directly:

```swift
FeedbackView(
    title: "Send Feedback",
    subtitle: "Help us improve",
    primaryColor: .green,
    onSubmit: { sentiment, comment in
        // Custom handling
    },
    onDismiss: {
        // Handle dismissal
    }
)
```

## Configuration Options

### Environment

Send feedback to different environments (useful for separating dev/prod data):

```swift
// Production (default)
FeedbackPulse.configure(apiKey: "fp_xxx", environment: .production)

// Development
FeedbackPulse.configure(apiKey: "fp_xxx", environment: .development)
```

### Debug Mode

Enable debug logging:

```swift
FeedbackPulse.shared.debugMode = true
```

### Custom Base URL

For self-hosted or testing:

```swift
FeedbackPulse.setBaseURL(URL(string: "https://your-server.com/v1")!)
```

## Sentiment Options

- `.positive` - User is happy
- `.neutral` - User is okay
- `.negative` - User is unhappy

## Automatic Metadata

The SDK automatically collects:

- Platform (iOS/macOS)
- OS version
- Device model
- App bundle ID
- App version & build number
- SDK version

## Error Handling

```swift
FeedbackPulse.submit(sentiment: .positive) { result in
    switch result {
    case .success(let response):
        // Handle success
    case .failure(let error):
        switch error {
        case .notConfigured:
            // SDK not initialized
        case .unauthorized:
            // Invalid API key
        case .rateLimited:
            // Too many requests
        case .networkError(let underlying):
            // Network issue
        case .httpError(let statusCode):
            // Server error
        default:
            // Other error
        }
    }
}
```

## Example App

```swift
import SwiftUI
import FeedbackPulse

@main
struct MyApp: App {
    init() {
        FeedbackPulse.configure(apiKey: "fp_your_api_key")
        #if DEBUG
        FeedbackPulse.shared.debugMode = true
        FeedbackPulse.configure(apiKey: "fp_your_api_key", environment: .development)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        VStack(spacing: 20) {
            Text("My App")
                .font(.largeTitle)

            Button("Send Feedback") {
                showFeedback = true
            }
            .buttonStyle(.borderedProminent)
        }
        .feedbackSheet(isPresented: $showFeedback)
    }
}
```

## Support

- Documentation: [https://fpulse.app/docs](https://fpulse.app/docs)
- Issues: [GitHub Issues](https://github.com/feedbackpulse/feedbackpulse-ios/issues)
- Email: support@fpulse.app

## License

MIT License - see [LICENSE](LICENSE) for details.
