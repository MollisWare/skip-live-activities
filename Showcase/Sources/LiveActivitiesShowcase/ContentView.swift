import SwiftUI
import SkipLiveActivities

/// A workout that counts down to its end, with three stages.
private let activityID = "showcase-workout"

@MainActor struct ContentView: View {
    @State private var permission = LiveActivityManager.shared.permissionStatus()
    @State private var isRunning = false
    @State private var progress = 0.0
    @State private var message = "Not started"

    var body: some View {
        NavigationStack {
            Form {
                Section("Device") {
                    LabeledContent("Supported", value: LiveActivityManager.shared.isSupported ? "yes" : "no")
                    LabeledContent("Permission", value: permission.rawValue)
                    Button("Request permission") {
                        Task {
                            permission = await LiveActivityManager.shared.requestPermission()
                        }
                    }
                }
                Section("Activity") {
                    Button("Start 2 minute workout") { startActivity() }
                        .disabled(isRunning)
                    Button("Advance 25%") { advance() }
                        .disabled(!isRunning)
                    Button("End with summary") { endActivity() }
                        .disabled(!isRunning)
                    Text(message).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Live Activities")
        }
        .task {
            isRunning = LiveActivityManager.shared.activeIDs().contains(activityID)
            #if !SKIP
            // `-autostart` lets scripts and UI tests start the activity without tapping
            if CommandLine.arguments.contains("-autostart") && !isRunning {
                startActivity()
            }
            #endif
        }
    }

    private func content(progress: Double?, status: String?) -> LiveActivityContent {
        let start = Date()
        return LiveActivityContent(
            title: "Spinning",
            subtitle: "Studio 2",
            status: status,
            symbol: "figure.indoor.cycle",
            progress: progress,
            timer: nil,
            stages: [
                LiveActivityStage(title: "Warm-up", weight: 0.2),
                LiveActivityStage(title: "Main set", weight: 0.6),
                LiveActivityStage(title: "Cool-down", weight: 0.2)
            ],
            deepLink: URL(string: "showcase://workout")
        )
    }

    private func startActivity() {
        Task {
            do {
                let start = Date()
                var initial = content(progress: nil, status: "2:00")
                initial.timer = LiveActivityTimer(start: start, end: start.addingTimeInterval(120), countsDown: true)
                try await LiveActivityManager.shared.start(id: activityID, content: initial, staleDate: start.addingTimeInterval(180))
                isRunning = true
                progress = 0.0
                message = "Started"
            } catch {
                message = "Start failed: \(error)"
            }
            permission = LiveActivityManager.shared.permissionStatus()
        }
    }

    private func advance() {
        Task {
            progress = min(1.0, progress + 0.25)
            do {
                // an app-driven update replaces the timer with explicit progress
                try await LiveActivityManager.shared.update(id: activityID, content: content(progress: progress, status: "\(Int(progress * 100))%"))
                message = "Updated to \(Int(progress * 100))%"
            } catch {
                message = "Update failed: \(error)"
            }
        }
    }

    private func endActivity() {
        Task {
            await LiveActivityManager.shared.end(
                id: activityID,
                finalContent: content(progress: 1.0, status: "Done"),
                dismissal: LiveActivityDismissal.afterSystemDefault)
            isRunning = false
            message = "Ended"
        }
    }
}
