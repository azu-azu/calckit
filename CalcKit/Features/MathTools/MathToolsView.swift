import SwiftUI

struct MathToolsView: View {
    @State private var sqrtInput = ""
    @FocusState private var isFocused: Bool

    private var sqrtResult: String {
        guard let value = Double(sqrtInput), value >= 0 else {
            return sqrtInput.isEmpty ? "" : "無効な値"
        }
        let result = sqrt(value)
        if result == result.rounded() {
            return String(format: "%.0f", result)
        }
        return String(format: "%.6f", result)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.InputLayout.sectionSpacing) {
                // Title
                Text("数学")
                    .dynamicFont(
                        size: DesignTokens.FeatureTypography.sectionTitleSize,
                        weight: DesignTokens.FeatureTypography.sectionTitleWeight
                    )
                    .foregroundColor(DesignTokens.CommonTextColors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Square root
                VStack(alignment: .leading, spacing: 12) {
                    Text("ルート計算")
                        .dynamicFont(size: 16, weight: .semibold)
                        .foregroundColor(DesignTokens.CommonTextColors.secondary)

                    HStack(spacing: 12) {
                        Text("√")
                            .dynamicFont(size: 28, weight: .light)
                            .foregroundColor(AppTheme.accent)

                        TextField("数値を入力", text: $sqrtInput)
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                            .dynamicFont(size: 20, weight: .medium)
                            .foregroundColor(DesignTokens.CommonTextColors.primary)
                            .padding(12)
                            .background(DesignTokens.InputColors.fieldBackground)
                            .cornerRadius(8)
                    }

                    if !sqrtResult.isEmpty {
                        HStack(spacing: 8) {
                            Text("=")
                                .dynamicFont(size: 20, weight: .regular)
                                .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                            Text(sqrtResult)
                                .dynamicFont(
                                    size: DesignTokens.FeatureTypography.resultSize,
                                    weight: DesignTokens.FeatureTypography.resultWeight,
                                    design: .monospaced
                                )
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                }
                .cardStyle()

                Spacer(minLength: 40)
            }
            .padding(.horizontal, DesignTokens.InputLayout.screenHorizontal)
            .padding(.top, 16)
        }
        .keyboardCloseToolbar { isFocused = false }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}
