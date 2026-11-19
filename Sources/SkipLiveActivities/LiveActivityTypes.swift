// Copyright 2026 MollisWare
// SPDX-License-Identifier: Apache-2.0
#if !SKIP_BRIDGE
import Foundation

/// A countdown or count-up that the operating system renders without further updates.
public struct LiveActivityTimer: Codable, Hashable, Sendable {
    /// When the timer started. Used to compute elapsed progress.
    public var start: Date
    /// When the timer ends.
    public var end: Date
    /// `true` to show the remaining time, `false` to show the elapsed time.
    public var countsDown: Bool

    public init(start: Date, end: Date, countsDown: Bool = true) {
        self.start = start
        self.end = end
        self.countsDown = countsDown
    }

    /// Fraction of the interval that has elapsed at `date`, clamped to 0...1.
    public func progress(at date: Date = Date()) -> Double {
        let total = end.timeIntervalSince1970 - start.timeIntervalSince1970
        if total <= 0.0 { return 1.0 }
        let elapsed = date.timeIntervalSince1970 - start.timeIntervalSince1970
        return min(1.0, max(0.0, elapsed / total))
    }
}

/// One step of a multi-step activity, such as warm-up, main set and cool-down.
public struct LiveActivityStage: Codable, Hashable, Sendable {
    /// Short name of the step.
    public var title: String
    /// Relative length of the step. Stages are drawn proportionally to their weights.
    public var weight: Double

    public init(title: String, weight: Double = 1.0) {
        self.title = title
        self.weight = weight
    }
}

/// The platform-neutral description of what a Live Activity shows.
///
/// The same content renders as an ActivityKit Live Activity on iOS and as a
/// promoted ongoing notification on Android 16. The layout is a fixed template,
/// so the look differs per platform but the information does not.
public struct LiveActivityContent: Codable, Hashable, Sendable {
    /// Main line.
    public var title: String
    /// Secondary line.
    public var subtitle: String?
    /// Short chip text, about 7 characters (Dynamic Island, Android status chip).
    public var status: String?
    /// SF Symbol name. On Android it is mapped to a drawable by name, falling back to the app icon.
    public var symbol: String?
    /// App-driven progress from 0 to 1. Ignored when `timer` is set.
    public var progress: Double?
    /// Time-based progress the OS keeps running on its own.
    public var timer: LiveActivityTimer?
    /// Optional steps shown as progress segments.
    public var stages: [LiveActivityStage]
    /// Opened when the user taps the activity.
    public var deepLink: URL?

    public init(
        title: String,
        subtitle: String? = nil,
        status: String? = nil,
        symbol: String? = nil,
        progress: Double? = nil,
        timer: LiveActivityTimer? = nil,
        stages: [LiveActivityStage] = [],
        deepLink: URL? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.symbol = symbol
        self.progress = progress
        self.timer = timer
        self.stages = stages
        self.deepLink = deepLink
    }

    /// The progress to display at `date`: timer progress if there is a timer, otherwise the app-driven value.
    public func effectiveProgress(at date: Date = Date()) -> Double? {
        if let timer = timer { return timer.progress(at: date) }
        if let progress = progress { return min(1.0, max(0.0, progress)) }
        return nil
    }
}

/// Whether the app may show Live Activities.
public enum LiveActivityPermission: String, Codable, Sendable {
    /// The user has not been asked yet (Android only; iOS has no prompt).
    case notDetermined
    /// The user turned Live Activities or notifications off.
    case denied
    /// Fully enabled.
    case authorized
    /// Android only: notifications work, but the user (or an OS older than Android 16) does not allow
    /// promoted Live Updates, so a plain ongoing notification is shown instead.
    case authorizedWithoutPromotion
}

/// How an ended activity leaves the screen.
public enum LiveActivityDismissal: Sendable {
    /// Remove right away.
    case immediate
    /// Keep the final content visible until the OS removes it (iOS: up to four hours; Android: until dismissed).
    case afterSystemDefault
    /// Keep the final content visible until the given date.
    case after(Date)
}

/// Lifecycle state reported by `LiveActivityManager.observe(id:)`.
public enum LiveActivityState: String, Codable, Sendable {
    case active
    case stale
    case ended
    /// The user swiped the activity away.
    case dismissed
}

public enum LiveActivityError: Error, Sendable {
    /// The platform or device does not support Live Activities.
    case unsupported
    /// Permission has not been granted.
    case notPermitted
    /// An activity with this id is already running.
    case alreadyExists(String)
    /// There is no running activity with this id.
    case notFound(String)
    /// The platform rejected the request.
    case failed(String)
}
#endif
