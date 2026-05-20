import SwiftUI
struct CircleIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.impact(.light)
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(DesignTokens.CommonTextColors.secondary)
                .frame(width: 44, height: 44)
                .background(DesignTokens.CommonBackgroundColors.cardHighlight)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
