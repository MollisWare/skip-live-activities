// Copyright 2026 MollisWare
// SPDX-License-Identifier: Apache-2.0
#if os(iOS)
import SwiftUI
import WidgetKit
import ActivityKit
import SkipLiveActivities

/// Lock screen and banner layout for a `LiveActivityContent`.
@available(iOS 16.2, *)
public struct LiveActivityLockScreenView: View {
    let content: LiveActivityContent

    public init(content: LiveActivityContent) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: content.symbol ?? "bolt.fill")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(content.title).font(.headline)
                    if let subtitle = content.subtitle {
                        Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let timer = content.timer {
                    Text(timerInterval: timer.start...max(timer.start, timer.end), countsDown: timer.countsDown)
                        .monospacedDigit()
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 90)
                } else if let status = content.status {
                    Text(status).font(.title3.weight(.semibold))
                }
            }
            LiveActivityProgressView(content: content)
            if !content.stages.isEmpty {
                LiveActivityStagesView(stages: content.stages, progress: content.effectiveProgress() ?? 0)
            }
        }
        .padding()
    }
}

/// Progress bar that the OS keeps running when the content has a timer.
@available(iOS 16.2, *)
struct LiveActivityProgressView: View {
    let content: LiveActivityContent

    var body: some View {
        if let timer = content.timer {
            ProgressView(timerInterval: timer.start...max(timer.start, timer.end), countsDown: timer.countsDown) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
        } else if let progress = content.progress {
            ProgressView(value: min(1, max(0, progress)))
        }
    }
}

/// Stage names with the current stage emphasized, proportional to the stage weights.
@available(iOS 16.2, *)
struct LiveActivityStagesView: View {
    let stages: [LiveActivityStage]
    let progress: Double

    private var currentIndex: Int {
        let total = stages.reduce(0.0) { $0 + $1.weight }
        guard total > 0 else { return 0 }
        var running = 0.0
        for (index, stage) in stages.enumerated() {
            running += stage.weight / total
            if progress < running { return index }
        }
        return stages.count - 1
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                Text(stage.title)
                    .font(.caption)
                    .fontWeight(index == currentIndex ? .bold : .regular)
                    .foregroundStyle(index == currentIndex ? Color.primary : Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

/// The ready-made widget for the extension: lock screen view plus Dynamic Island.
///
/// ```swift
/// @main struct MyWidgets: WidgetBundle {
///     var body: some Widget { SkipLiveActivityWidget() }
/// }
/// ```
@available(iOS 16.2, *)
public struct SkipLiveActivityWidget: Widget {
    public init() {}

    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            LiveActivityLockScreenView(content: context.state)
                .widgetURL(context.state.deepLink)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.symbol ?? "bolt.fill").font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let timer = context.state.timer {
                        Text(timerInterval: timer.start...max(timer.start, timer.end), countsDown: timer.countsDown)
                            .monospacedDigit()
                            .frame(maxWidth: 80)
                    } else if let status = context.state.status {
                        Text(status)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.title).font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        if let subtitle = context.state.subtitle {
                            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                        }
                        LiveActivityProgressView(content: context.state)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.symbol ?? "bolt.fill")
            } compactTrailing: {
                if let status = context.state.status {
                    Text(status).font(.caption2)
                } else if let timer = context.state.timer {
                    Text(timerInterval: timer.start...max(timer.start, timer.end), countsDown: timer.countsDown)
                        .monospacedDigit()
                        .frame(maxWidth: 44)
                }
            } minimal: {
                Image(systemName: context.state.symbol ?? "bolt.fill")
            }
            .widgetURL(context.state.deepLink)
        }
    }
}
#endif
