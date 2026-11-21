#if !SKIP_BRIDGE
#if !SKIP && os(iOS)
import ActivityKit

/// The fixed `ActivityAttributes` type used by every activity this library starts.
///
/// The widget extension registers an `ActivityConfiguration(for: LiveActivityAttributes.self)`
/// (see `SkipLiveActivitiesUI`) so the same type is shared between app and extension.
/// iOS only: Android has no equivalent.
public struct LiveActivityAttributes: ActivityAttributes {
    public typealias ContentState = LiveActivityContent

    /// The caller-chosen activity id.
    public var id: String

    public init(id: String) {
        self.id = id
    }
}
#endif
#endif
