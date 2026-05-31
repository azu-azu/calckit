import SwiftUI

struct KeyboardReturnButton: View {
    enum Size { case regular, compact, small }

    let size: Size
    let action: () -> Void

    init(size: Size = .regular, action: @escaping () -> Void) {
        self.size = size
        self.action = action
    }

    private var dimension: CGFloat {
        switch size { case .regular: 44; case .compact: 36; case .small: 32 }
    }

    private var fontSize: CGFloat {
        switch size { case .regular: 18; case .compact: 16; case .small: 14 }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .regular: DesignTokens.InputLayout.cardCornerRadius
        default:       DesignTokens.InputLayout.compactFieldCornerRadius
        }
    }

    var body: some View {
        Button {
            HapticFeedback.impact(.light)
            action()
        } label: {
            Image(systemName: "return")
                .dynamicFont(size: fontSize, weight: .semibold)
                .foregroundColor(AppTheme.accent)
                .frame(width: dimension, height: dimension)
                .background(AppTheme.accent.opacity(0.15))
                .cornerRadius(cornerRadius)
        }
        .buttonStyle(.plain)
    }
}
