import SwiftUI

enum AppTheme {
    static let background = Color(hex: "#0A0F1C")

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "#0A0F1C"), Color(hex: "#111827")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accent = Color(hex: "#61A3F2")
}
