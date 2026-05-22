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

    private var resultDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日（E）"
        return formatter.string(from: resultDate)
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
        .onTapGesture { isDaysFocused = false }
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

    private var dateAfterInputs: some View {
        VStack(spacing: DesignTokens.InputLayout.itemSpacing) {
            HStack {
                Text("スタート日")
                    .dynamicFont(size: 14, weight: .medium)
                    .foregroundColor(DesignTokens.CommonTextColors.secondary)
                Spacer()
                DatePicker("", selection: $baseDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(AppTheme.accent)
            }

            Divider().background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)

            HStack {
                Text("日数")
                    .dynamicFont(size: 14, weight: .medium)
                    .foregroundColor(DesignTokens.CommonTextColors.secondary)
                Spacer()
                TextField("0", text: $daysText)
                    .dynamicFont(size: 16, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.primary)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .focused($isDaysFocused)
                    .frame(width: 80)
                Text("日後")
                    .dynamicFont(size: 14, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.tertiary)
            }
        }
        .cardStyle()
    }

    private var daysBetweenResult: some View {
        VStack(spacing: 8) {
            Text("\(dayCount)")
                .dynamicFont(
                    size: DesignTokens.FeatureTypography.resultSize,
                    weight: DesignTokens.FeatureTypography.resultWeight,
                    design: .monospaced
                )
                .foregroundColor(AppTheme.accent)
            Text(businessDaysOnly ? "平日" : "日間")
                .dynamicFont(size: 16, weight: .regular)
                .foregroundColor(DesignTokens.CommonTextColors.tertiary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var dateAfterResult: some View {
        VStack(spacing: 8) {
            Text(resultDateString)
                .dynamicFont(
                    size: DesignTokens.FeatureTypography.resultSize * 0.6,
                    weight: DesignTokens.FeatureTypography.resultWeight,
                    design: .monospaced
                )
                .foregroundColor(AppTheme.accent)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(businessDaysOnly ? "\(daysOffset)平日後" : "\(daysOffset)日後")
                .dynamicFont(size: 16, weight: .regular)
                .foregroundColor(DesignTokens.CommonTextColors.tertiary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}
