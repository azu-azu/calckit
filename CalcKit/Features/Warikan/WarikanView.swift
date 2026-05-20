import SwiftUI

struct WarikanView: View {
    @State private var totalAmountText = ""
    @State private var peopleCount = 2
    @State private var specialPayments: [SpecialPayment] = []
    @State private var adjustedAmountText = ""
    @FocusState private var focusedField: FocusField?

    private enum FocusField: Hashable {
        case totalAmount
        case specialPayment(Int)
        case adjustedAmount
    }

    private var result: WarikanResult? {
        let total = Int(totalAmountText) ?? 0
        return WarikanEngine.calculate(
            totalAmount: total,
            totalPeople: peopleCount,
            specialPayments: specialPayments
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.InputLayout.sectionSpacing) {
                // Title
                HStack {
                    Text("ワリカン")
                        .dynamicFont(
                            size: DesignTokens.FeatureTypography.sectionTitleSize,
                            weight: DesignTokens.FeatureTypography.sectionTitleWeight
                        )
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                    Spacer()
                    Button {
                        totalAmountText = ""
                        peopleCount = 2
                        specialPayments = []
                        adjustedAmountText = ""
                        focusedField = .totalAmount
                    } label: {
                        Text("クリア")
                            .dynamicFont(size: 14, weight: .medium)
                            .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                    }
                }

                // Input section
                VStack(spacing: DesignTokens.InputLayout.itemSpacing) {
                    // Total amount
                    VStack(alignment: .leading, spacing: 6) {
                        Text("合計額")
                            .dynamicFont(size: 14, weight: .medium)
                            .foregroundColor(DesignTokens.CommonTextColors.secondary)
                        HStack {
                            TextField("0", text: $totalAmountText)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .totalAmount)
                                .dynamicFont(size: 20, weight: .semibold)
                                .foregroundColor(DesignTokens.CommonTextColors.primary)

                            if !totalAmountText.isEmpty {
                                Button {
                                    totalAmountText = ""
                                    focusedField = .totalAmount
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                                }
                            }
                        }
                        .padding(DesignTokens.InputLayout.fieldPadding)
                        .background(DesignTokens.InputColors.fieldBackground)
                        .cornerRadius(DesignTokens.InputLayout.fieldCornerRadius)
                    }

                    // People count
                    VStack(alignment: .leading, spacing: 6) {
                        Text("人数")
                            .dynamicFont(size: 14, weight: .medium)
                            .foregroundColor(DesignTokens.CommonTextColors.secondary)
                        HStack {
                            Button {
                                if peopleCount > 1 { peopleCount -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28, design: .rounded))
                                    .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                            }

                            Text("\(peopleCount)")
                                .dynamicFont(size: 24, weight: .semibold, design: .monospaced)
                                .foregroundColor(DesignTokens.CommonTextColors.primary)
                                .frame(width: 60)

                            Button {
                                peopleCount += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28, design: .rounded))
                                    .foregroundColor(AppTheme.accent)
                            }

                            Spacer()
                        }
                    }
                }
                .cardStyle()

                // Special payments
                VStack(spacing: 12) {
                    ForEach(specialPayments.indices, id: \.self) { index in
                        SpecialPaymentRow(
                            payment: $specialPayments[index],
                            isFocused: $focusedField,
                            focusValue: .specialPayment(index),
                            onClear: {
                                specialPayments[index].amount = 0
                                specialPayments[index].amountText = ""
                            }
                        )
                    }

                    Button {
                        specialPayments.append(SpecialPayment())
                        let newIndex = specialPayments.count - 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusedField = .specialPayment(newIndex)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("特殊払い追加")
                                .dynamicFont(size: 15, weight: .medium)
                        }
                        .foregroundColor(AppTheme.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppTheme.accent.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }

                // Result (リアルタイム表示)
                if let result {
                    resultCard(result)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, DesignTokens.InputLayout.screenHorizontal)
            .padding(.top, 16)
        }
        .keyboardCloseToolbar { focusedField = nil }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedField = .totalAmount
            }
        }
        .onChange(of: totalAmountText) { syncAdjustedAmount() }
        .onChange(of: peopleCount) { syncAdjustedAmount() }
        .onChange(of: specialPayments) { syncAdjustedAmount() }
    }

    private func syncAdjustedAmount() {
        // 訂正欄にフォーカス中は上書きしない
        guard focusedField != .adjustedAmount else { return }
        if let result {
            adjustedAmountText = String(result.perPerson)
        }
    }

    private var adjustedPerPerson: Int {
        Int(adjustedAmountText) ?? result?.perPerson ?? 0
    }

    private var adjustedResult: (actualTotal: Int, remainder: Int)? {
        guard let result else { return nil }
        let adjusted = adjustedPerPerson
        let total = adjusted * result.remainingPeople + result.specialTotal
        let remainder = result.totalAmount - total
        return (actualTotal: total, remainder: remainder)
    }

    private func resultCard(_ result: WarikanResult) -> some View {
        let displayPerPerson = adjustedPerPerson
        let displayActualTotal = adjustedResult?.actualTotal ?? result.actualTotal
        let displayRemainder = adjustedResult?.remainder ?? result.remainder

        return VStack(alignment: .leading, spacing: 12) {
            Text("結果")
                .dynamicFont(size: 16, weight: .semibold)
                .foregroundColor(DesignTokens.CommonTextColors.secondary)

            // 合計額（赤）
            HStack {
                Text("合計額")
                    .dynamicFont(size: 14, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                Spacer()
                Text("¥\(displayActualTotal.formatted())")
                    .dynamicFont(size: 14, weight: .semibold, design: .monospaced)
                    .foregroundColor(DesignTokens.StatusColors.danger)
            }

            // 端数
            HStack {
                Text("端数")
                    .dynamicFont(size: 14, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                Spacer()
                Text("¥\(displayRemainder.formatted())")
                    .dynamicFont(size: 14, weight: .medium, design: .monospaced)
                    .foregroundColor(displayRemainder == 0
                        ? DesignTokens.CommonTextColors.quaternary
                        : DesignTokens.StatusColors.warning)
            }

            Divider()
                .background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)

            if result.hasSpecialPayments {
                ForEach(result.specialPayments) { sp in
                    HStack {
                        Text("特殊払い")
                            .dynamicFont(size: 14, weight: .regular)
                            .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                        Spacer()
                        Text("¥\(sp.amount.formatted()) × \(sp.count)人")
                            .dynamicFont(size: 14, weight: .medium, design: .monospaced)
                            .foregroundColor(DesignTokens.CommonTextColors.secondary)
                    }
                }

                Divider()
                    .background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)
            }

            // ワリカン結果
            HStack {
                Text("ワリカン")
                    .dynamicFont(size: 16, weight: .medium)
                    .foregroundColor(DesignTokens.CommonTextColors.primary)
                Spacer()
                Text("¥\(displayPerPerson.formatted()) × \(result.remainingPeople)人")
                    .dynamicFont(size: 20, weight: .bold, design: .monospaced)
                    .foregroundColor(AppTheme.accent)
            }

            Divider()
                .background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)

            // 訂正欄
            VStack(alignment: .leading, spacing: 6) {
                Text("金額訂正")
                    .dynamicFont(size: 12, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                HStack(spacing: 8) {
                    TextField("\(result.perPerson)", text: $adjustedAmountText)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .adjustedAmount)
                        .dynamicFont(size: 18, weight: .semibold)
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(DesignTokens.InputColors.fieldBackground)
                        .cornerRadius(8)

                    Text("× \(result.remainingPeople)人")
                        .dynamicFont(size: 16, weight: .medium)
                        .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                }
            }
        }
        .cardStyle()
    }
}
