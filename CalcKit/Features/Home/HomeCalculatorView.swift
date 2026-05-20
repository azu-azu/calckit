import SwiftUI

struct HomeCalculatorView: View {
    @Environment(HistoryStore.self) private var historyStore
    @State private var engine = CalcEngine()
    @State private var showSaveDialog = false
    var onMenu: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .saveDialog(isPresented: $showSaveDialog) { name in
            let item = HistoryItem(
                name: name,
                expression: engine.fullExpression,
                result: engine.result
            )
            historyStore.save(item: item)
        }
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
                    .background(Color(hex: "#424242"))
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
            onEquals: { engine.evaluate() },
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
        HStack {
            SideMenuTriggerButton { onMenu() }

            Spacer()

            Button(action: { showSaveDialog = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 14, design: .rounded))
                    Text("Save")
                        .dynamicFont(size: 14, weight: .medium)
                }
                .foregroundColor(AppTheme.accent)
                .padding(.horizontal, 16)
                .frame(height: DesignTokens.CalcLayout.toolbarHeight)
                .background(AppTheme.accent.opacity(0.12))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}
