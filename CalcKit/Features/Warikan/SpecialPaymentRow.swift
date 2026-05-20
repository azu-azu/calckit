import SwiftUI

struct SpecialPaymentRow<F: Hashable>: View {
    @Binding var payment: SpecialPayment
    var isFocused: FocusState<F?>.Binding
    let focusValue: F
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Amount
            VStack(alignment: .leading, spacing: 4) {
                Text("金額")
                    .dynamicFont(size: 12, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                TextField("0", text: $payment.amountText)
                    .keyboardType(.numberPad)
                    .focused(isFocused, equals: focusValue)
                    .dynamicFont(size: 16, weight: .medium)
                    .foregroundColor(DesignTokens.CommonTextColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DesignTokens.InputColors.fieldBackground)
                    .cornerRadius(8)
            }

            // Count
            VStack(alignment: .leading, spacing: 4) {
                Text("人数")
                    .dynamicFont(size: 12, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                HStack {
                    Button { if payment.count > 1 { payment.count -= 1 } } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                    }
                    Text("\(payment.count)")
                        .dynamicFont(size: 16, weight: .medium)
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                        .frame(width: 30)
                    Button { payment.count += 1 } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.accent)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(width: 100)

            // Clear
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                    .font(.system(size: 20, design: .rounded))
            }
        }
        .padding(12)
        .background(DesignTokens.CommonBackgroundColors.cardSubtle)
        .cornerRadius(10)
    }
}
