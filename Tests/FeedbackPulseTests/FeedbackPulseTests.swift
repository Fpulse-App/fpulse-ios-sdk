//
//  FeedbackPulseTests.swift
//  FeedbackPulseTests
//
//  Unit tests for the FeedbackPulse SDK
//

import XCTest
@testable import FeedbackPulse

final class FeedbackPulseTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset shared instance before each test
        FeedbackPulse.configure(apiKey: "fp_test_key", environment: .development)
    }

    func testConfigureWithAPIKey() {
        FeedbackPulse.configure(apiKey: "fp_my_test_key")
        // Configuration should not throw
        XCTAssertTrue(true)
    }

    func testConfigureWithEnvironment() {
        FeedbackPulse.configure(apiKey: "fp_test", environment: .development)
        XCTAssertTrue(true)
    }

    func testSentimentRawValues() {
        XCTAssertEqual(FeedbackSentiment.positive.rawValue, "positive")
        XCTAssertEqual(FeedbackSentiment.neutral.rawValue, "neutral")
        XCTAssertEqual(FeedbackSentiment.negative.rawValue, "negative")
    }

    func testEnvironmentRawValues() {
        XCTAssertEqual(FeedbackEnvironment.production.rawValue, "production")
        XCTAssertEqual(FeedbackEnvironment.development.rawValue, "development")
    }

    func testFeedbackErrorDescriptions() {
        XCTAssertNotNil(FeedbackError.notConfigured.errorDescription)
        XCTAssertNotNil(FeedbackError.unauthorized.errorDescription)
        XCTAssertNotNil(FeedbackError.rateLimited.errorDescription)
        XCTAssertNotNil(FeedbackError.httpError(500).errorDescription)
    }

    func testFeedbackResponseDecoding() throws {
        let json = """
        {
            "feedback_id": "abc123",
            "message": "Feedback received"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(FeedbackResponse.self, from: json)
        XCTAssertEqual(response.feedbackId, "abc123")
        XCTAssertEqual(response.message, "Feedback received")
    }

    func testDebugModeToggle() {
        FeedbackPulse.shared.debugMode = true
        XCTAssertTrue(FeedbackPulse.shared.debugMode)

        FeedbackPulse.shared.debugMode = false
        XCTAssertFalse(FeedbackPulse.shared.debugMode)
    }
}
