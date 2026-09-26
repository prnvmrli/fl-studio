import WidgetKit
import SwiftUI

public struct FCleanerWidget: Widget {
    public let kind: String = "FCleanerWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        let config = StaticConfiguration(kind: kind, provider: FCleanerTimelineProvider()) { entry in
            FCleanerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FCleaner Disk Monitor")
        .description("View reclaimable Flutter artifacts, Xcode DerivedData, and developer caches.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])

        if #available(macOS 14.0, *) {
            return config.contentMarginsDisabled()
        } else {
            return config
        }
    }
}
