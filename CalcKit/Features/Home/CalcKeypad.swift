import SwiftUI
import UIKit

struct CalcKeypad: View {
    let onDigit: (String) -> Void
    let onOperator: (CalcEngine.Operator) -> Void
    let onEquals: () -> Void
    let onClear: () -> Void
    let onBackspace: () -> Void
    let onDecimal: () -> Void
    let onPercent: () -> Void
    let onOpenParen: () -> Void
    let onCloseParen: () -> Void
    let onToggleSign: () -> Void

    private let spacing = DesignTokens.CalcLayout.buttonSpacing

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width - 24
            let buttonWidth = (totalWidth - spacing * 3) / 4

            VStack(spacing: spacing) {
                // Row 1: (, ), %, ←
                HStack(spacing: spacing) {
                    CalcButtonView("(", style: .function) { onOpenParen() }
                    CalcButtonView(")", style: .function) { onCloseParen() }
                    CalcButtonView("%", style: .function) { onPercent() }
                    iconButton("delete.backward", style: .function) { onBackspace() }
                }

                // Row 2: 7, 8, 9, ÷
                HStack(spacing: spacing) {
                    CalcButtonView("7") { onDigit("7") }
                    CalcButtonView("8") { onDigit("8") }
                    CalcButtonView("9") { onDigit("9") }
                    CalcButtonView("÷", style: .operatorStyle) { onOperator(.divide) }
                }

                // Row 3: 4, 5, 6, ×
                HStack(spacing: spacing) {
                    CalcButtonView("4") { onDigit("4") }
                    CalcButtonView("5") { onDigit("5") }
                    CalcButtonView("6") { onDigit("6") }
                    CalcButtonView("×", style: .operatorStyle) { onOperator(.multiply) }
                }

                // Row 4: 1, 2, 3, -
                HStack(spacing: spacing) {
                    CalcButtonView("1") { onDigit("1") }
                    CalcButtonView("2") { onDigit("2") }
                    CalcButtonView("3") { onDigit("3") }
                    CalcButtonView("-", style: .operatorStyle) { onOperator(.subtract) }
                }

                // Row 5: 0 (wide), ., +
                HStack(spacing: spacing) {
                    wideButton("0", width: buttonWidth * 2 + spacing, style: .number) { onDigit("0") }
                    CalcButtonView(".") { onDecimal() }
                    CalcButtonView("+", style: .operatorStyle) { onOperator(.add) }
                }

                // Row 6: AC, ±, =
                HStack(spacing: spacing) {
                    CalcButtonView("AC", style: .function) { onClear() }
                    iconButton("plus.forwardslash.minus", style: .function) { onToggleSign() }
                    wideButton("=", width: buttonWidth * 2 + spacing, style: .equals) { onEquals() }
                }

            }
            .padding(.horizontal, 12)
        }
    }

    private func iconButton(_ systemName: String, style: CalcButtonStyle, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: DesignTokens.CalcTypography.buttonSize - 4, weight: .medium, design: .rounded))
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(RaisedButtonStyle(
                    style: style,
                    cornerRadius: DesignTokens.CalcLayout.buttonCornerRadius
                ))
        }
        .buttonStyle(.plain)
    }

    private func wideButton(_ label: String, width: CGFloat, style: CalcButtonStyle, action: @escaping () -> Void) -> some View {
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
                .frame(maxHeight: .infinity)
                .frame(width: width)
                .modifier(RaisedButtonStyle(
                    style: style,
                    cornerRadius: DesignTokens.CalcLayout.buttonCornerRadius
                ))
        }
        .buttonStyle(.plain)
    }
}
