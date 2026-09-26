import SwiftUI
import WidgetKit

// MARK: - App Color Palette

private enum FCleanerColors {
    static let background = Color(hex: "0D121B")
    static let cardBackground = Color(hex: "161E2C")
    static let border = Color(hex: "243147")
    static let teal = Color(hex: "00BFA5")
    static let cyan = Color(hex: "00E5FF")
    static let amber = Color(hex: "FFAB00")
    static let purple = Color(hex: "7C4DFF")
    static let green = Color(hex: "00E676")
    static let textSecondary = Color(white: 0.65)
}

// MARK: - Root Entry View

public struct FCleanerWidgetEntryView: View {
    public var entry: FCleanerEntry
    @Environment(\.widgetFamily) var family

    public init(entry: FCleanerEntry) {
        self.entry = entry
    }

    public var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(data: entry.data)
            case .systemMedium:
                MediumWidgetView(data: entry.data)
            case .systemLarge:
                LargeWidgetView(data: entry.data)
            default:
                MediumWidgetView(data: entry.data)
            }
        }
        .widgetBackground(FCleanerColors.background)
    }
}

// MARK: - Container Background Extension

extension View {
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(macOS 14.0, *) {
            self.containerBackground(for: .widget) {
                color
            }
        } else {
            self.background(color)
        }
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let data: FCleanerWidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 6) {
                ZStack {
                    LinearGradient(
                        colors: [FCleanerColors.teal, FCleanerColors.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                }

                Text("FCleaner")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                Circle()
                    .fill(data.totalBytes > 0 ? FCleanerColors.amber : FCleanerColors.green)
                    .frame(width: 7, height: 7)
            }

            Spacer(minLength: 2)

            // Metric
            VStack(alignment: .leading, spacing: 2) {
                Text(data.formattedTotal)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, FCleanerColors.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(data.totalBytes > 0 ? "Reclaimable" : "Clean")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(FCleanerColors.textSecondary)
            }

            Spacer(minLength: 2)

            // Top item preview
            if let topCache = data.caches.first {
                HStack(spacing: 5) {
                    Image(systemName: topCache.iconName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(topCache.color)

                    Text(topCache.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Spacer()

                    Text(topCache.formattedSize)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(FCleanerColors.textSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(FCleanerColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(FCleanerColors.border, lineWidth: 0.8)
                )
            } else {
                Text("Zero clutter")
                    .font(.system(size: 10))
                    .foregroundColor(FCleanerColors.textSecondary)
            }
        }
        .padding(12)
        .widgetURL(URL(string: "fcleaner://scan"))
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let data: FCleanerWidgetData

    var body: some View {
        HStack(spacing: 14) {
            // Left Hero Column
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ZStack {
                        LinearGradient(
                            colors: [FCleanerColors.teal, FCleanerColors.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }

                    Text("FCleaner")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(data.formattedTotal)
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, FCleanerColors.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(data.statusMessage)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(FCleanerColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Link(destination: URL(string: "fcleaner://scan")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 10, weight: .bold))
                        Text("Clean Caches")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [FCleanerColors.teal, FCleanerColors.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .background(FCleanerColors.border)

            // Right Items List
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("ACTIVE CACHES")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(FCleanerColors.textSecondary)
                    Spacer()
                    Circle()
                        .fill(FCleanerColors.green)
                        .frame(width: 6, height: 6)
                }

                if data.caches.isEmpty {
                    Spacer()
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 22))
                            .foregroundColor(FCleanerColors.green)
                        Text("All caches are lean!")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ForEach(data.caches.prefix(4)) { cache in
                        HStack(spacing: 7) {
                            Image(systemName: cache.iconName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(cache.color)
                                .frame(width: 14)

                            Text(cache.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Spacer()

                            Text(cache.formattedSize)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .widgetURL(URL(string: "fcleaner://scan"))
    }
}

// MARK: - Large Widget View

struct LargeWidgetView: View {
    let data: FCleanerWidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                ZStack {
                    LinearGradient(
                        colors: [FCleanerColors.teal, FCleanerColors.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("FCleaner System Monitor")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Flutter & Developer Cache Doctor")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(FCleanerColors.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(data.totalBytes > 0 ? FCleanerColors.amber : FCleanerColors.green)
                        .frame(width: 7, height: 7)

                    Text(data.totalBytes > 0 ? "Attention Needed" : "Optimal")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(data.totalBytes > 0 ? FCleanerColors.amber : FCleanerColors.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(FCleanerColors.cardBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(FCleanerColors.border, lineWidth: 0.8)
                )
            }

            // Big Metric Hero Card
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TOTAL RECLAIMABLE SPACE")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundColor(FCleanerColors.cyan)

                    Text(data.formattedTotal)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, FCleanerColors.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(data.caches.count) Cache Targets")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)

                    Text("Updated just now")
                        .font(.system(size: 10))
                        .foregroundColor(FCleanerColors.textSecondary)
                }
            }
            .padding(12)
            .background(FCleanerColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FCleanerColors.border, lineWidth: 1)
            )

            // Usage Proportional Bar
            if data.totalBytes > 0 {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(data.caches) { cache in
                            let fraction = CGFloat(cache.bytes) / CGFloat(max(1, data.totalBytes))
                            let width = max(4, geo.size.width * fraction)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(cache.color)
                                .frame(width: width, height: 8)
                        }
                    }
                }
                .frame(height: 8)
            }

            // Cache Items List
            VStack(spacing: 6) {
                ForEach(data.caches.prefix(5)) { cache in
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(cache.color.opacity(0.15))
                                .frame(width: 24, height: 24)

                            Image(systemName: cache.iconName)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(cache.color)
                        }

                        Text(cache.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Text(cache.formattedSize)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(FCleanerColors.cardBackground.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(FCleanerColors.border.opacity(0.6), lineWidth: 0.6)
                    )
                }
            }

            Spacer()

            // Footer Quick Actions
            HStack(spacing: 8) {
                Link(destination: URL(string: "fcleaner://scan")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                        Text("Scan & Clean")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [FCleanerColors.teal, FCleanerColors.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Link(destination: URL(string: "fcleaner://doctor")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "cross.case.fill")
                        Text("Doctor")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(FCleanerColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(FCleanerColors.border, lineWidth: 1)
                    )
                }

                Link(destination: URL(string: "fcleaner://dashboard")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Dashboard")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(FCleanerColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(FCleanerColors.border, lineWidth: 1)
                    )
                }
            }
        }
        .padding(14)
    }
}
