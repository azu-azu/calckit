import UIKit

enum HapticFeedback {
    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            lightGenerator.impactOccurred()
            DispatchQueue.main.async { lightGenerator.prepare() }
        case .rigid:
            rigidGenerator.impactOccurred()
            DispatchQueue.main.async { rigidGenerator.prepare() }
        @unknown default:
            let gen = UIImpactFeedbackGenerator(style: style)
            gen.prepare()
            gen.impactOccurred()
        }
    }

    /// Taptic Engine を事前 warm-up する。App 起動時に呼ぶ。
    static func warmUp() {
        lightGenerator.prepare()
        rigidGenerator.prepare()
    }
}
