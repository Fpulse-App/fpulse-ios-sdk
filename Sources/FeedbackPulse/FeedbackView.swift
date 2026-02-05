//
//  FeedbackView.swift
//  FeedbackPulse
//
//  Pre-built SwiftUI feedback collection view
//

#if os(iOS)
import SwiftUI
import UIKit

/// A pre-built SwiftUI view for collecting user feedback
@available(iOS 14.0, *)
public struct FeedbackView: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var selectedSentiment: FeedbackSentiment?
    @State private var comment: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String?

    /// Customizable title
    public var title: String

    /// Customizable subtitle
    public var subtitle: String

    /// Primary color for the view
    public var primaryColor: Color

    /// Callback when feedback is submitted
    public var onSubmit: ((FeedbackSentiment, String?) -> Void)?

    /// Callback when view is dismissed
    public var onDismiss: (() -> Void)?

    public init(
        title: String = "Send us your feedback",
        subtitle: String = "How are you feeling about our app?",
        primaryColor: Color = .green,
        onSubmit: ((FeedbackSentiment, String?) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.primaryColor = primaryColor
        self.onSubmit = onSubmit
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Sentiment Selection
                HStack(spacing: 20) {
                    SentimentButton(
                        emoji: "😊",
                        label: "Good",
                        isSelected: selectedSentiment == .positive,
                        color: .green
                    ) {
                        selectedSentiment = .positive
                    }

                    SentimentButton(
                        emoji: "😐",
                        label: "Okay",
                        isSelected: selectedSentiment == .neutral,
                        color: .yellow
                    ) {
                        selectedSentiment = .neutral
                    }

                    SentimentButton(
                        emoji: "😞",
                        label: "Bad",
                        isSelected: selectedSentiment == .negative,
                        color: .red
                    ) {
                        selectedSentiment = .negative
                    }
                }
                .padding(.vertical)

                // Comment Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us more (optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextEditor(text: $comment)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }

                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Spacer()

                // Submit Button
                Button(action: submitFeedback) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isSubmitting ? "Sending..." : "Send Feedback")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedSentiment != nil ? primaryColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(selectedSentiment == nil || isSubmitting)

                // Powered by
                Text("Powered by Feedback Pulse")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss?()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Thank you!", isPresented: $showSuccess) {
                Button("OK") {
                    onDismiss?()
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Your feedback has been submitted successfully.")
            }
        }
    }

    private func submitFeedback() {
        guard let sentiment = selectedSentiment else { return }

        isSubmitting = true
        errorMessage = nil

        let commentToSend = comment.isEmpty ? nil : comment

        FeedbackPulse.submit(sentiment: sentiment, comment: commentToSend) { result in
            isSubmitting = false

            switch result {
            case .success:
                onSubmit?(sentiment, commentToSend)
                showSuccess = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Sentiment Button

@available(iOS 14.0, *)
private struct SentimentButton: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 40))

                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? color : .secondary)
            }
            .padding()
            .background(isSelected ? color.opacity(0.15) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Extension

@available(iOS 14.0, *)
public extension View {
    /// Present the FeedbackPulse feedback sheet
    func feedbackSheet(
        isPresented: Binding<Bool>,
        title: String = "Send us your feedback",
        subtitle: String = "How are you feeling about our app?",
        primaryColor: Color = .green,
        onSubmit: ((FeedbackSentiment, String?) -> Void)? = nil
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            FeedbackView(
                title: title,
                subtitle: subtitle,
                primaryColor: primaryColor,
                onSubmit: onSubmit,
                onDismiss: { isPresented.wrappedValue = false }
            )
        }
    }
}

#endif
