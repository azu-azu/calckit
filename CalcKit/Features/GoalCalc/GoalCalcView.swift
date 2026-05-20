import SwiftUI

struct GoalCalcView: View {
    @State private var mode: Mode = .period
    @State private var targetText = ""
    @State private var isPlus = true
    @State private var weekdaysOnly = false
    @State private var peopleCount = 1
    @FocusState private var isFocused: Bool

    // Period mode
    @State private var periodCountText = "1"
    @State private var selectedPeriod: Period = .year

    // Deadline mode
    @State private var deadlineType: DeadlineType = .yearEnd
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var customDate = Date()

    enum Mode: String, CaseIterable, Identifiable {
        case period = "期間指定"
        case deadline = "期限指定"
        var id: String { rawValue }
    }

    enum Period: String, CaseIterable, Identifiable {
        case day = "日"
        case week = "週"
        case month = "月"
        case year = "年"
        var id: String { rawValue }

        func daysMultiplier(weekdaysOnly: Bool) -> Double {
            if weekdaysOnly {
                switch self {
                case .day: 1
                case .week: 5
                case .month: 21.74
                case .year: 260.71
                }
            } else {
                switch self {
                case .day: 1
                case .week: 7
                case .month: 30.44
                case .year: 365
                }
            }
        }
    }

    enum DeadlineType: String, CaseIterable, Identifiable {
        case yearEnd = "今年の年末"
        case monthEnd = "月末"
        case custom = "日付指定"
        var id: String { rawValue }
    }

    // MARK: - Computed

    private var targetValue: Double {
        Double(targetText) ?? 0
    }

    private var periodCount: Double {
        Double(periodCountText) ?? 1
    }

    private func daysFor(_ period: Period) -> Double {
        period.daysMultiplier(weekdaysOnly: weekdaysOnly)
    }

    private var totalDays: Double {
        switch mode {
        case .period:
            return periodCount * selectedPeriod.daysMultiplier(weekdaysOnly: weekdaysOnly)
        case .deadline:
            return daysUntilDeadline
        }
    }

    private var daysUntilDeadline: Double {
        let calendar = Calendar.current
        let today = Date()
        let target: Date

        switch deadlineType {
        case .yearEnd:
            target = calendar.date(from: DateComponents(year: calendar.component(.year, from: today), month: 12, day: 31))!
        case .monthEnd:
            var comps = DateComponents(year: calendar.component(.year, from: today), month: selectedMonth + 1, day: 0)
            // 選択月が現在月より前なら来年
            if selectedMonth < calendar.component(.month, from: today) {
                comps.year = calendar.component(.year, from: today) + 1
            }
            target = calendar.date(from: comps)!
        case .custom:
            target = customDate
        }

        if weekdaysOnly {
            return Double(calendar.businessDaysBetween(from: today, to: target))
        }
        return Double(calendar.totalDaysBetween(from: today, to: target))
    }

    private var monthEndYear: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        return selectedMonth < currentMonth ? currentYear + 1 : currentYear
    }

    /// 期間指定モードの終了日
    private var periodEndDateText: String {
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: periodDateComponent, to: Date()) else { return "" }
        let y = calendar.component(.year, from: endDate)
        let m = calendar.component(.month, from: endDate)
        let d = calendar.component(.day, from: endDate)
        return "\(String(y))年\(m)月\(d)日"
    }

    private var periodDateComponent: DateComponents {
        let count = Int(periodCount)
        switch selectedPeriod {
        case .day: return DateComponents(day: count)
        case .week: return DateComponents(weekOfYear: count)
        case .month: return DateComponents(month: count)
        case .year: return DateComponents(year: count)
        }
    }

    private var dailyRate: Double {
        guard totalDays > 0, peopleCount > 0 else { return 0 }
        let rate = targetValue / totalDays / Double(peopleCount)
        return isPlus ? rate : -rate
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.InputLayout.sectionSpacing) {
                // Title
                Text("目標計算")
                    .dynamicFont(
                        size: DesignTokens.FeatureTypography.sectionTitleSize,
                        weight: DesignTokens.FeatureTypography.sectionTitleWeight
                    )
                    .foregroundColor(DesignTokens.CommonTextColors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Mode tab
                Picker("", selection: $mode) {
                    ForEach(Mode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)

                // Input section
                VStack(spacing: DesignTokens.InputLayout.itemSpacing) {
                    if mode == .period {
                        periodInputView
                    } else {
                        deadlineInputView
                    }

                    // Target number + Plus/Minus
                    HStack(spacing: 8) {
                        Button {
                            isPlus.toggle()
                        } label: {
                            Text(isPlus ? "+" : "−")
                                .dynamicFont(size: 22, weight: .bold)
                                .foregroundColor(isPlus ? DesignTokens.StatusColors.success : DesignTokens.StatusColors.danger)
                                .frame(width: 44, height: 44)
                                .background(
                                    (isPlus ? DesignTokens.StatusColors.success : DesignTokens.StatusColors.danger)
                                        .opacity(0.15)
                                )
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)

                        TextField("数値を入力", text: $targetText)
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                            .dynamicFont(size: 24, weight: .semibold)
                            .foregroundColor(DesignTokens.CommonTextColors.primary)
                            .padding(DesignTokens.InputLayout.fieldPadding)
                            .background(DesignTokens.InputColors.fieldBackground)
                            .cornerRadius(DesignTokens.InputLayout.fieldCornerRadius)
                    }

                    // People count
                    HStack {
                        Spacer()
                        Button {
                            if peopleCount > 1 { peopleCount -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24, design: .rounded))
                                .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                        }
                        Text("\(peopleCount)")
                            .dynamicFont(size: 20, weight: .semibold, design: .monospaced)
                            .foregroundColor(DesignTokens.CommonTextColors.primary)
                            .frame(width: 40)
                        Text("人で")
                            .dynamicFont(size: 16, weight: .regular)
                            .foregroundColor(DesignTokens.CommonTextColors.secondary)
                        Button {
                            peopleCount += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, design: .rounded))
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                }
                .cardStyle()

                // 平日のみ toggle
                HStack {
                    Text("平日のみ")
                        .dynamicFont(size: 16, weight: .regular)
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                    Spacer()
                    Toggle("", isOn: $weekdaysOnly)
                        .tint(AppTheme.accent)
                }
                .cardStyle()

                // 残り日数（deadline mode）
                if mode == .deadline && totalDays > 0 {
                    HStack {
                        Text("残り")
                            .dynamicFont(size: 14, weight: .regular)
                            .foregroundColor(DesignTokens.CommonTextColors.tertiary)
                        Spacer()
                        Text("\(Int(totalDays))\(weekdaysOnly ? "平日" : "日")")
                            .dynamicFont(size: 20, weight: .semibold, design: .monospaced)
                            .foregroundColor(AppTheme.accent)
                    }
                    .cardStyle()
                }

                // Results
                if targetValue > 0 {
                    VStack(spacing: 12) {
                        if peopleCount > 1 {
                            Text("1人あたり")
                                .dynamicFont(size: 14, weight: .medium)
                                .foregroundColor(DesignTokens.CommonTextColors.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        resultRow(label: weekdaysOnly ? "1時間 (8h/日)" : "1時間", value: dailyRate / (weekdaysOnly ? 8 : 24))
                        if totalDays > 1 {
                            Divider().background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)
                            resultRow(label: "1日", value: dailyRate)
                        }
                        if totalDays > daysFor(.week) {
                            Divider().background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)
                            resultRow(label: weekdaysOnly ? "1週 (5日)" : "1週間", value: dailyRate * daysFor(.week))
                        }
                        if totalDays > daysFor(.month) {
                            Divider().background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)
                            resultRow(label: weekdaysOnly ? "1ヶ月 (約22日)" : "1ヶ月", value: dailyRate * daysFor(.month))
                        }
                        if mode == .deadline {
                            Divider().background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)
                            resultRow(label: "最終期限", value: dailyRate * totalDays)
                        } else {
                            Divider().background(DesignTokens.CommonBackgroundColors.cardBorderSubtle)
                            resultRow(label: weekdaysOnly ? "1年 (約261日)" : "1年", value: dailyRate * daysFor(.year))
                        }
                    }
                    .cardStyle()
                }

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

    // MARK: - Period Input

    private var periodInputView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                TextField("1", text: $periodCountText)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .dynamicFont(size: 24, weight: .bold, design: .monospaced)
                    .foregroundColor(DesignTokens.CommonTextColors.primary)
                    .multilineTextAlignment(.center)
                    .frame(width: 50)
                    .padding(.vertical, 8)
                    .background(DesignTokens.InputColors.fieldBackground)
                    .cornerRadius(8)

                Picker("", selection: $selectedPeriod) {
                    ForEach(Period.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                Text("で")
                    .dynamicFont(size: 16, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.tertiary)
            }

            if !periodEndDateText.isEmpty {
                Text("→ \(periodEndDateText)まで")
                    .dynamicFont(size: 13, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    // MARK: - Deadline Input

    private var deadlineInputView: some View {
        VStack(spacing: 12) {
            Picker("", selection: $deadlineType) {
                ForEach(DeadlineType.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.segmented)

            switch deadlineType {
            case .yearEnd:
                HStack {
                    let year = Calendar.current.component(.year, from: Date())
                    Text("\(String(year))年12月31日まで")
                        .dynamicFont(size: 16, weight: .medium)
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                    Spacer()
                }
            case .monthEnd:
                HStack {
                    Text("\(String(monthEndYear))年\(selectedMonth)月末まで")
                        .dynamicFont(size: 14, weight: .medium)
                        .foregroundColor(DesignTokens.CommonTextColors.primary)
                    Spacer()
                    Picker("", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { m in
                            Text("\(m)月").tag(m)
                        }
                    }
                    .tint(AppTheme.accent)
                }
            case .custom:
                HStack {
                    Text("期限日")
                        .dynamicFont(size: 14, weight: .medium)
                        .foregroundColor(DesignTokens.CommonTextColors.secondary)
                    Spacer()
                    DatePicker("", selection: $customDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .tint(AppTheme.accent)
                }
            }
        }
    }

    // MARK: - Result Row

    private func resultRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .dynamicFont(size: 16, weight: .regular)
                .foregroundColor(DesignTokens.CommonTextColors.secondary)
            Spacer()
            Text(formatValue(value))
                .dynamicFont(size: 20, weight: .semibold, design: .monospaced)
                .foregroundColor(AppTheme.accent)
        }
    }

    private func formatValue(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : ""
        if value == value.rounded() {
            return "\(prefix)\(Int(value))"
        }
        return "\(prefix)\(String(format: "%.2f", value))"
    }
}
