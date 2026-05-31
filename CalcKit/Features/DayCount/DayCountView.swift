import SwiftUI

struct DayCountView: View {
    @State private var mode: Mode = .daysBetween
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var baseDate = Date()
    @State private var daysText = "30"
    @State private var businessDaysOnly = false
    @FocusState private var isDaysFocused: Bool

    enum Mode: String, CaseIterable, Identifiable {
        case daysBetween = "日数計算"
        case dateAfter = "X日後"
        var id: String { rawValue }
    }

    private var dayCount: Int {
        let calendar = Calendar.current
        if businessDaysOnly {
            return calendar.businessDaysBetween(from: startDate, to: endDate)
        }
        return calendar.totalDaysBetween(from: startDate, to: endDate)
    }

    private var daysOffset: Int { Int(daysText) ?? 0 }

    private var resultDate: Date {
        let calendar = Calendar.current
        if businessDaysOnly {
            return calendar.date(byAddingBusinessDays: daysOffset, to: baseDate)
        }
        return calendar.date(byAdding: .day, value: daysOffset, to: baseDate) ?? baseDate
    }

    private static let resultFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月d日（E）"
        return f
    }()

    private var resultDateString: String {
        Self.resultFormatter.string(from: resultDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.InputLayout.sectionSpacing) {
                Text("日数計算")
                    .dynamicFont(
                        size: DesignTokens.FeatureTypography.sectionTitleSize,
                        weight: DesignTokens.FeatureTypography.sectionTitleWeight
                    )
                    .foregroundColor(DesignTokens.CommonTextColors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("モード", selection: $mode) {
                    ForEach(Mode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)

                if mode == .daysBetween {
                    daysBetweenInputs
                } else {
                    dateAfterInputs
                }

                HStack {
                    Text("平日のみ")
                        .dynamicFont(size: 16, weight: .regular)
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                    Spacer()
                    Toggle("", isOn: $businessDaysOnly)
                        .tint(AppTheme.accent)
                }
                .cardStyle()

                if mode == .daysBetween {
                    daysBetweenResult
                } else {
                    dateAfterResult
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, DesignTokens.InputLayout.screenHorizontal)
            .padding(.top, 16)
        }
        .onChange(of: mode) { _, newMode in
            guard newMode == .dateAfter else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + DesignTokens.Timing.keyboardFocusDelay) {
                isDaysFocused = true
            }
        }
    }

    private var daysBetweenInputs: some View {
        VStack(spacing: DesignTokens.InputLayout.itemSpacing) {
            HStack {
                Text("スタート日")
                    .dynamicFont(size: 14, weight: .medium)
                    .foregroundColor(DesignTokens.CommonTextColors.secondary)
                Spacer()
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(AppTheme.accent)
            }

            Divider().background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)

            HStack {
                Text("エンド日")
                    .dynamicFont(size: 14, weight: .medium)
                    .foregroundColor(DesignTokens.CommonTextColors.secondary)
                Spacer()
                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(AppTheme.accent)
            }
        }
        .cardStyle()
    }

    @ViewBuilder private var dateAfterInputs: some View {
        HStack {
            Text("スタート日")
                .dynamicFont(size: 14, weight: .medium)
                .foregroundColor(DesignTokens.CommonTextColors.secondary)
            Spacer()
            DatePicker("", selection: $baseDate, displayedComponents: .date)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .cardStyle()

        VStack(alignment: .leading, spacing: 6) {
            Text("日数")
                .dynamicFont(size: 14, weight: .medium)
                .foregroundColor(DesignTokens.CommonTextColors.secondary)
            HStack(spacing: 8) {
                HStack {
                    TextField("0", text: $daysText)
                        .keyboardType(.numberPad)
                        .focused($isDaysFocused)
                        .dynamicFont(size: 20, weight: .semibold)
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                    Spacer()
                    Text("日後")
                        .dynamicFont(size: 14, weight: .regular)
                        .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                }
                .padding(DesignTokens.InputLayout.fieldPadding)
                .background(DesignTokens.InputColors.fieldBackground)
                .cornerRadius(DesignTokens.InputLayout.fieldCornerRadius)

                Button {
                    isDaysFocused = false
                } label: {
                    Image(systemName: "return")
                        .dynamicFont(size: 18, weight: .semibold)
                        .foregroundColor(AppTheme.accent)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.accent.opacity(0.15))
                        .cornerRadius(DesignTokens.InputLayout.cardCornerRadius)
                }
                .buttonStyle(.plain)
            }
        }
        .cardStyle()
    }

    private var daysBetweenResult: some View {
        resultCard(
            value: "\(dayCount)",
            size: DesignTokens.FeatureTypography.resultSize,
            subtitle: businessDaysOnly ? "平日" : "日間"
        )
    }

    private var dateAfterResult: some View {
        resultCard(
            value: resultDateString,
            size: DesignTokens.FeatureTypography.dateResultSize,
            subtitle: businessDaysOnly ? "\(daysOffset)平日後" : "\(daysOffset)日後"
        )
    }

    private func resultCard(value: String, size: CGFloat, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .dynamicFont(size: size, weight: DesignTokens.FeatureTypography.resultWeight, design: .monospaced)
                .foregroundColor(AppTheme.accent)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(subtitle)
                .dynamicFont(size: 16, weight: .regular)
                .foregroundColor(DesignTokens.CommonTextColors.tertiary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}
