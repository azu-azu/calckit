import SwiftUI

struct StatusBarView: View {
    let safeAreaTop: CGFloat

    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        HStack {
            Text(Self.dateFormatter.string(from: now))
                .dynamicFont(size: 13, weight: .regular, design: .monospaced)
                .foregroundColor(DesignTokens.CommonTextColors.quaternary)

            Spacer()

            Text(Self.timeFormatter.string(from: now))
                .dynamicFont(size: 13, weight: .regular, design: .monospaced)
                .foregroundColor(DesignTokens.CommonTextColors.quaternary)
        }
        .padding(.horizontal, 36)
        .padding(.top, safeAreaTop > 0 ? safeAreaTop + 18 : 24)
        .onReceive(timer) { now = $0 }
    }
}
