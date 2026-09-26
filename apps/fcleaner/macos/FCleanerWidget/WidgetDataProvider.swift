import Foundation
import WidgetKit
import SwiftUI

// MARK: - Byte Formatter

public enum ByteFormatter {
    public static func format(_ bytes: Int64) -> String {
        guard bytes > 0 else { return "0 B" }
        let units = ["B", "KB", "MB", "GB", "TB"]
        var size = Double(bytes)
        var unitIndex = 0

        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }

        if unitIndex == 0 {
            return "\(bytes) B"
        }
        let formatStr = size >= 10 ? "%.1f" : "%.2f"
        return String(format: "\(formatStr) %@", size, units[unitIndex])
    }
}

// MARK: - Color Hex Helper

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 191, 165)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Widget Models

public struct CacheItem: Identifiable, Codable {
    public var id: String { name }
    public let name: String
    public let bytes: Int64
    public let iconName: String
    public let colorHex: String

    public init(name: String, bytes: Int64, iconName: String, colorHex: String) {
        self.name = name
        self.bytes = bytes
        self.iconName = iconName
        self.colorHex = colorHex
    }

    public var formattedSize: String {
        ByteFormatter.format(bytes)
    }

    public var color: Color {
        Color(hex: colorHex)
    }
}

public struct FCleanerWidgetData: Codable {
    public let totalBytes: Int64
    public let lastScanTime: Date?
    public let itemCount: Int
    public let caches: [CacheItem]
    public let statusMessage: String

    public init(
        totalBytes: Int64,
        lastScanTime: Date?,
        itemCount: Int,
        caches: [CacheItem],
        statusMessage: String
    ) {
        self.totalBytes = totalBytes
        self.lastScanTime = lastScanTime
        self.itemCount = itemCount
        self.caches = caches
        self.statusMessage = statusMessage
    }

    public var formattedTotal: String {
        ByteFormatter.format(totalBytes)
    }

    public static let placeholder = FCleanerWidgetData(
        totalBytes: 15_420_000_000,
        lastScanTime: Date(),
        itemCount: 48,
        caches: [
            CacheItem(name: "DerivedData", bytes: 8_200_000_000, iconName: "hammer.fill", colorHex: "00E5FF"),
            CacheItem(name: "Gradle Cache", bytes: 4_100_000_000, iconName: "shippingbox.fill", colorHex: "7C4DFF"),
            CacheItem(name: "Pub Cache", bytes: 2_300_000_000, iconName: "archivebox.fill", colorHex: "00BFA5"),
            CacheItem(name: "CocoaPods", bytes: 820_000_000, iconName: "cube.box.fill", colorHex: "FFAB00")
        ],
        statusMessage: "15.4 GB Reclaimable"
    )

    public static let clean = FCleanerWidgetData(
        totalBytes: 0,
        lastScanTime: Date(),
        itemCount: 0,
        caches: [],
        statusMessage: "Caches Clean"
    )
}

// MARK: - Entry

public struct FCleanerEntry: TimelineEntry {
    public let date: Date
    public let data: FCleanerWidgetData

    public init(date: Date, data: FCleanerWidgetData) {
        self.date = date
        self.data = data
    }
}

// MARK: - Data Provider

public final class WidgetDataProvider {
    public static let shared = WidgetDataProvider()

    private let fileManager = FileManager.default

    private var realUserHomeURL: URL {
        if let pw = getpwuid(getuid()) {
            let path = String(cString: pw.pointee.pw_dir)
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return fileManager.homeDirectoryForCurrentUser
    }

    private var sharedDataFileURL: URL {
        realUserHomeURL
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("dev.fcleaner.fcleaner")
            .appendingPathComponent("widget_data.json")
    }

    public func fetchLatestData() -> FCleanerWidgetData {
        // 1. Try reading cached data from shared JSON file
        let fileURL = sharedDataFileURL
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let rawData = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let widgetData = try decoder.decode(FCleanerWidgetData.self, from: rawData)
                return widgetData
            } catch {
                // If decoding fails, fall through to live check
            }
        }

        // 2. Fallback: Perform fast live scan of known macOS developer cache folders
        return inspectStandardCaches()
    }

    private func inspectStandardCaches() -> FCleanerWidgetData {
        let home = realUserHomeURL

        struct CacheTarget {
            let name: String
            let relativePath: String
            let icon: String
            let colorHex: String
        }

        let targets: [CacheTarget] = [
            CacheTarget(name: "DerivedData", relativePath: "Library/Developer/Xcode/DerivedData", icon: "hammer.fill", colorHex: "00E5FF"),
            CacheTarget(name: "Pub Cache", relativePath: ".pub-cache", icon: "archivebox.fill", colorHex: "00BFA5"),
            CacheTarget(name: "Gradle Cache", relativePath: ".gradle/caches", icon: "shippingbox.fill", colorHex: "7C4DFF"),
            CacheTarget(name: "CocoaPods", relativePath: "Library/Caches/CocoaPods", icon: "cube.box.fill", colorHex: "FFAB00"),
            CacheTarget(name: "Android Cache", relativePath: ".android/build-cache", icon: "gearshape.2.fill", colorHex: "00E676")
        ]

        var detectedCaches: [CacheItem] = []
        var totalBytes: Int64 = 0

        for target in targets {
            let targetURL = home.appendingPathComponent(target.relativePath)
            if fileManager.fileExists(atPath: targetURL.path) {
                let size = quickDirectorySize(at: targetURL)
                if size > 0 {
                    detectedCaches.append(
                        CacheItem(
                            name: target.name,
                            bytes: size,
                            iconName: target.icon,
                            colorHex: target.colorHex
                        )
                    )
                    totalBytes += size
                }
            }
        }

        detectedCaches.sort { $0.bytes > $1.bytes }

        let message = totalBytes > 0
            ? "\(ByteFormatter.format(totalBytes)) Reclaimable"
            : "No Heavy Caches"

        return FCleanerWidgetData(
            totalBytes: totalBytes,
            lastScanTime: Date(),
            itemCount: detectedCaches.count,
            caches: detectedCaches,
            statusMessage: message
        )
    }

    private func quickDirectorySize(at url: URL) -> Int64 {
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total: Int64 = 0
        var sampledCount = 0

        for case let fileURL as URL in enumerator {
            sampledCount += 1
            if sampledCount > 3000 {
                // Safeguard against freezing widget daemon on massive folders
                break
            }
            do {
                let values = try fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .isRegularFileKey])
                if values.isRegularFile == true {
                    total += Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
                }
            } catch {
                continue
            }
        }
        return total
    }
}

// MARK: - Timeline Provider

public struct FCleanerTimelineProvider: TimelineProvider {
    public init() {}

    public func placeholder(in context: Context) -> FCleanerEntry {
        FCleanerEntry(date: Date(), data: .placeholder)
    }

    public func getSnapshot(in context: Context, completion: @escaping (FCleanerEntry) -> Void) {
        if context.isPreview {
            completion(FCleanerEntry(date: Date(), data: .placeholder))
        } else {
            let data = WidgetDataProvider.shared.fetchLatestData()
            completion(FCleanerEntry(date: Date(), data: data))
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<FCleanerEntry>) -> Void) {
        let currentDate = Date()
        let data = WidgetDataProvider.shared.fetchLatestData()
        let entry = FCleanerEntry(date: currentDate, data: data)

        // Refresh automatically every 30 minutes, or when parent app updates
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
