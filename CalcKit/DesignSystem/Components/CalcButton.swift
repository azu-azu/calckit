import SwiftUI
import UIKit

enum CalcButtonStyle {
    case number
    case function
    case operatorStyle
    case equals

    var backgroundColor: Color {
        switch self {
        case .number: Color(hex: "#A6A6A6")
        case .function: Color(hex: "#B8B0A7")
        case .operatorStyle: Color(hex: "#E99689")
        case .equals: Color(hex: "#97BEC1")
        }
    }

    var foregroundColor: Color {
        switch self {
        case .number, .function, .operatorStyle, .equals: Color(hex: "#111111")
        }
    }

}

// MARK: - Raised Button Modifier

struct RaisedButtonStyle: ViewModifier {
    let style: CalcButtonStyle
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(AppTheme.background)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(style.backgroundColor)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(EdgeInsets(top: 2, leading: 2, bottom: 4, trailing: 2))
            .background(
                RoundedRectangle(cornerRadius: cornerRadius + 2)
                    .fill(Color.black.opacity(0.6))
            )
    }
}

struct CalcButtonView: View {
    let label: String
    let style: CalcButtonStyle
    let action: () -> Void

    init(
        _ label: String,
        style: CalcButtonStyle = .number,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.style = style
        self.action = action
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            action()
        } label: {
            Text(label)
                .dynamicFont(
                    size: DesignTokens.CalcTypography.buttonSize,
                    weight: DesignTokens.CalcTypography.buttonWeight
                )
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(RaisedButtonStyle(
                    style: style,
                    cornerRadius: DesignTokens.CalcLayout.buttonCornerRadius
                ))
        }
        .buttonStyle(.plain)
    }
}
