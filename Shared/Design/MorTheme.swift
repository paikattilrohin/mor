import SwiftUI
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

enum MorTheme {
    static let backgroundTop = Color(red: 0.06, green: 0.21, blue: 0.42)
    static let backgroundBottom = Color.black
    static let cardTop = Color(red: 0.06, green: 0.18, blue: 0.33)
    static let cardBottom = Color(red: 0.03, green: 0.10, blue: 0.20)
    static let buttonBlue = Color(red: 0.17, green: 0.39, blue: 0.98)
    static let buttonBluePressed = Color(red: 0.14, green: 0.31, blue: 0.83)
    static let trackBackground = Color.white.opacity(0.12)
    static let trackIdle = Color(red: 0.54, green: 0.60, blue: 0.69)
    static let trackActive = Color.white
    static let successTop = Color(red: 0.06, green: 0.47, blue: 0.21)
    static let successBottom = Color(red: 0.03, green: 0.37, blue: 0.15)
    static let errorTop = Color(red: 0.49, green: 0.10, blue: 0.14)
    static let errorBottom = Color(red: 0.39, green: 0.05, blue: 0.09)
    static let accentYellow = Color(red: 1.00, green: 0.86, blue: 0.12)
    static let accentBlue = Color(red: 0.24, green: 0.47, blue: 0.98)
    static let offWhite = Color(red: 0.95, green: 0.96, blue: 0.99)

    static let pressThreshold: TimeInterval = 0.35
    static let roundTransitionDelay: UInt64 = 850_000_000
    static let failureTransitionDelay: UInt64 = 900_000_000

    static func backgroundGradient() -> LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func frameWidth(for totalWidth: CGFloat) -> CGFloat {
        #if os(watchOS)
        return min(totalWidth * 0.92, 184)
        #else
        return min(totalWidth * 0.82, 340)
        #endif
    }

    static var logoFont: Font {
        #if os(watchOS)
        return .system(size: 30, weight: .heavy, design: .rounded)
        #else
        return .system(size: 56, weight: .heavy, design: .rounded)
        #endif
    }

    static var titleFont: Font {
        #if os(watchOS)
        return .system(size: 24, weight: .semibold, design: .rounded)
        #else
        return .system(size: 34, weight: .bold, design: .rounded)
        #endif
    }

    static var subtitleFont: Font {
        #if os(watchOS)
        return .system(size: 14, weight: .medium, design: .rounded)
        #else
        return .system(size: 18, weight: .medium, design: .rounded)
        #endif
    }

    static var buttonFont: Font {
        #if os(watchOS)
        return .system(size: 15, weight: .bold, design: .rounded)
        #else
        return .system(size: 22, weight: .bold, design: .rounded)
        #endif
    }

    static var symbolFontSize: CGFloat {
        #if os(watchOS)
        return 40
        #else
        return 86
        #endif
    }

    static var sectionSpacing: CGFloat {
        #if os(watchOS)
        return 10
        #else
        return 24
        #endif
    }

    static var buttonVerticalPadding: CGFloat {
        #if os(watchOS)
        return 10
        #else
        return 14
        #endif
    }

    static var screenHorizontalPadding: CGFloat {
        #if os(watchOS)
        return 10
        #else
        return 8
        #endif
    }

    static var screenVerticalPadding: CGFloat {
        #if os(watchOS)
        return 10
        #else
        return 12
        #endif
    }

    static var panelPadding: CGFloat {
        #if os(watchOS)
        return 10
        #else
        return 14
        #endif
    }

    static var gameplaySpacing: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 14
        #endif
    }

    static var cardVerticalPadding: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 18
        #endif
    }

    static var cardHorizontalPadding: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 14
        #endif
    }

    static var instructionFont: Font {
        #if os(watchOS)
        return .system(size: 13, weight: .medium, design: .rounded)
        #else
        return .system(size: 16, weight: .medium, design: .rounded)
        #endif
    }

    static var statTitleFont: Font {
        #if os(watchOS)
        return .system(size: 12, weight: .medium, design: .rounded)
        #else
        return .system(size: 14, weight: .medium, design: .rounded)
        #endif
    }

    static var statValueFont: Font {
        #if os(watchOS)
        return .system(size: 16, weight: .semibold, design: .rounded)
        #else
        return .system(size: 18, weight: .semibold, design: .rounded)
        #endif
    }

    static var largeCornerRadius: CGFloat {
        #if os(watchOS)
        return 12
        #else
        return 18
        #endif
    }
}

enum MorHaptics {
    static func tap() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }

    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }

    static func failure() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.failure)
        #endif
    }
}
