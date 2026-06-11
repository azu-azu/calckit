import SwiftUI

struct HomeCalculatorView: View {
    @Environment(HistoryStore.self) private var historyStore
    @State private var engine = CalcEngine()
    @State private var showCopied = false
    @State private var copyToken = UUID()

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
    }

    private func autoSave() {
        let expr = engine.expression
        guard !expr.isEmpty, expr != engine.result else { return }
        historyStore.save(item: HistoryItem(
            name: "",
            expression: expr,
            result: engine.result
        ))
    }

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                VStack {
                    Spacer()
                    CalcDisplay(
                        expression: engine.expression,
                        intermediateSteps: engine.intermediateSteps,
                        displayValue: engine.displayValue
                    )
                }
                .background(Color.black.opacity(0.3))

                keypad
                    .frame(height: DesignTokens.CalcLayout.buttonHeight * 6
                        + DesignTokens.CalcLayout.buttonSpacing * 5)
                    .padding(.vertical, 12)
                    .background(DesignTokens.CalcColors.keypadBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
            )
            .padding(.top, 36)
            .padding(.horizontal, 4)

            calcToolbar
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
        }
    }

    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            // Left: Display
            VStack {
                Spacer()
                CalcDisplay(
                    expression: engine.expression,
                    intermediateSteps: engine.intermediateSteps,
                    displayValue: engine.displayValue
                )
                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Right: Keypad
            keypad
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }

    private var keypad: some View {
        CalcKeypad(
            onDigit: { engine.inputDigit($0) },
            onOperator: { engine.inputOperator($0) },
            onEquals: { engine.evaluate(); autoSave() },
            onClear: { engine.clear() },
            onBackspace: { engine.backspace() },
            onDecimal: { engine.inputDecimal() },
            onPercent: { engine.inputPercent() },
            onOpenParen: { engine.inputOpenParen() },
            onCloseParen: { engine.inputCloseParen() },
            onToggleSign: { engine.toggleSign() }
        )
    }

    private var calcToolbar: some View {
        HStack(spacing: 8) {
            Spacer()

            Button {
                HapticFeedback.impact(.light)
                UIPasteboard.general.string = engine.displayValue
                showCopied = true
                let token = UUID()
                copyToken = token
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if copyToken == token { showCopied = false }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, design: .rounded))
                    Text(showCopied ? "Copied!" : "コピー")
                        .dynamicFont(size: 14, weight: .medium)
                }
                .foregroundColor(showCopied ? DesignTokens.StatusColors.success : DesignTokens.CommonTextColors.secondary)
                .padding(.horizontal, 16)
                .frame(height: DesignTokens.CalcLayout.toolbarHeight)
                .background(DesignTokens.CommonBackgroundColors.cardSubtle)
                .cornerRadius(DesignTokens.InputLayout.cardCornerRadius)
                .animation(.easeInOut(duration: 0.15), value: showCopied)
            }
            .buttonStyle(.plain)
        }
    }
}
