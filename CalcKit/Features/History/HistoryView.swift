import SwiftUI

struct HistoryView: View {
    @Environment(HistoryStore.self) private var historyStore

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("History")
                .dynamicFont(
                    size: DesignTokens.FeatureTypography.sectionTitleSize,
                    weight: DesignTokens.FeatureTypography.sectionTitleWeight
                )
                .foregroundColor(DesignTokens.CommonTextColors.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.InputLayout.screenHorizontal)
                .padding(.top, 16)
                .padding(.bottom, 16)

            if historyStore.items.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48, design: .rounded))
                        .foregroundColor(DesignTokens.CommonTextColors.quinary)
                    Text("保存された計算はありません")
                        .dynamicFont(size: 16, weight: .regular)
                        .foregroundColor(DesignTokens.CommonTextColors.quaternary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(historyStore.items) { item in
                            historyCard(item)
                        }
                    }
                    .padding(.horizontal, DesignTokens.InputLayout.screenHorizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func historyCard(_ item: HistoryItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.name)
                    .dynamicFont(size: 16, weight: .semibold)
                    .foregroundColor(DesignTokens.CommonTextColors.primary)

                Spacer()

                Text(item.createdAt, style: .date)
                    .dynamicFont(size: 12, weight: .regular)
                    .foregroundColor(DesignTokens.CommonTextColors.quaternary)
            }

            Text(item.expression)
                .dynamicFont(size: 14, weight: .regular)
                .foregroundColor(DesignTokens.CommonTextColors.tertiary)

            Text("= \(item.result)")
                .dynamicFont(size: 20, weight: .semibold, design: .monospaced)
                .foregroundColor(AppTheme.accent)
        }
        .cardStyle()
        .contextMenu {
            Button(role: .destructive) {
                historyStore.deleteItem(item)
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }
}
