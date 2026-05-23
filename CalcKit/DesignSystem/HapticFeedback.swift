import UIKit

enum HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    /// Taptic Engine を事前 warm-up する。App 起動時に呼ぶ。
    static func warmUp() {
        UIImpactFeedbackGenerator(style: .light).prepare()
        UIImpactFeedbackGenerator(style: .rigid).prepare()
    }
}
