//
//  FeedbackPulse.swift
//  FeedbackPulse
//
//  iOS SDK for Feedback Pulse - User Feedback Collection
//

import Foundation

#if os(iOS)
import UIKit
#endif

/// Main entry point for the FeedbackPulse SDK
public final class FeedbackPulse {

    /// Shared instance for convenient access
    public static let shared = FeedbackPulse()

    /// The API key for authentication
    private var apiKey: String?

    /// The environment (production or development)
    private var environment: FeedbackEnvironment = .production

    /// Base URL for the API
    private var baseURL: URL = URL(string: "https://api.fpulse.app/v1")!

    /// URLSession for network requests
    private let session: URLSession

    /// Debug mode - prints logs to console
    public var debugMode: Bool = false

    // MARK: - Initialization

    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Configuration

    /// Configure the SDK with your API key
    /// - Parameters:
    ///   - apiKey: Your Feedback Pulse API key (starts with fp_)
    ///   - environment: The environment to send feedback to (default: .production)
    public static func configure(apiKey: String, environment: FeedbackEnvironment = .production) {
        shared.apiKey = apiKey
        shared.environment = environment

        if shared.debugMode {
            print("[FeedbackPulse] Configured with environment: \(environment.rawValue)")
        }
    }

    /// Set a custom base URL (useful for testing)
    /// - Parameter url: Custom API base URL
    public static func setBaseURL(_ url: URL) {
        shared.baseURL = url
    }

    // MARK: - Submit Feedback

    /// Submit feedback with sentiment and optional comment
    /// - Parameters:
    ///   - sentiment: The sentiment rating (positive, neutral, or negative)
    ///   - comment: Optional text comment from the user
    ///   - metadata: Optional dictionary of additional metadata
    ///   - completion: Callback with result
    public static func submit(
        sentiment: FeedbackSentiment,
        comment: String? = nil,
        metadata: [String: Any]? = nil,
        completion: @escaping (Result<FeedbackResponse, FeedbackError>) -> Void
    ) {
        shared.submitFeedback(
            sentiment: sentiment,
            comment: comment,
            metadata: metadata,
            completion: completion
        )
    }

    /// Submit feedback with sentiment and optional comment (async/await)
    @available(iOS 15.0, macOS 12.0, *)
    public static func submit(
        sentiment: FeedbackSentiment,
        comment: String? = nil,
        metadata: [String: Any]? = nil
    ) async throws -> FeedbackResponse {
        try await withCheckedThrowingContinuation { continuation in
            submit(sentiment: sentiment, comment: comment, metadata: metadata) { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Private Methods

    private func submitFeedback(
        sentiment: FeedbackSentiment,
        comment: String?,
        metadata: [String: Any]?,
        completion: @escaping (Result<FeedbackResponse, FeedbackError>) -> Void
    ) {
        guard let apiKey = apiKey else {
            completion(.failure(.notConfigured))
            return
        }

        let url = baseURL.appendingPathComponent("feedback")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        var body: [String: Any] = [
            "sentiment": sentiment.rawValue,
            "environment": environment.rawValue
        ]

        if let comment = comment, !comment.isEmpty {
            body["comment"] = comment
        }

        // Add device metadata
        var deviceMetadata = collectDeviceMetadata()
        if let userMetadata = metadata {
            for (key, value) in userMetadata {
                deviceMetadata[key] = value
            }
        }
        body["metadata"] = deviceMetadata

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.encodingError))
            return
        }

        if debugMode {
            print("[FeedbackPulse] Submitting feedback: \(sentiment.rawValue)")
        }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.log("Network error: \(error.localizedDescription)")
                    completion(.failure(.networkError(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                switch httpResponse.statusCode {
                case 200, 201:
                    do {
                        let response = try JSONDecoder().decode(FeedbackResponse.self, from: data)
                        self?.log("Feedback submitted successfully: \(response.feedbackId)")
                        completion(.success(response))
                    } catch {
                        self?.log("Decoding error: \(error)")
                        completion(.failure(.decodingError))
                    }
                case 401:
                    completion(.failure(.unauthorized))
                case 429:
                    completion(.failure(.rateLimited))
                default:
                    self?.log("HTTP error: \(httpResponse.statusCode)")
                    completion(.failure(.httpError(httpResponse.statusCode)))
                }
            }
        }
        task.resume()
    }

    private func collectDeviceMetadata() -> [String: Any] {
        var metadata: [String: Any] = [:]

        #if os(iOS)
        metadata["platform"] = "iOS"
        metadata["os_version"] = UIDevice.current.systemVersion
        metadata["device_model"] = UIDevice.current.model
        #elseif os(macOS)
        metadata["platform"] = "macOS"
        let version = ProcessInfo.processInfo.operatingSystemVersion
        metadata["os_version"] = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #endif

        if let bundleId = Bundle.main.bundleIdentifier {
            metadata["app_bundle_id"] = bundleId
        }

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            metadata["app_version"] = appVersion
        }

        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            metadata["app_build"] = buildNumber
        }

        metadata["sdk_version"] = "1.0.0"

        return metadata
    }

    private func log(_ message: String) {
        if debugMode {
            print("[FeedbackPulse] \(message)")
        }
    }
}
