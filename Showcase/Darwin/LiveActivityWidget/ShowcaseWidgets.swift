import SwiftUI
import WidgetKit
import SkipLiveActivitiesUI

/// The widget extension is a few lines: register the template widget from SkipLiveActivitiesUI.
@main
struct ShowcaseWidgets: WidgetBundle {
    var body: some Widget {
        SkipLiveActivityWidget()
    }
}
