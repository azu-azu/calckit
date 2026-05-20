import SwiftUI

enum Page: String, CaseIterable, Identifiable {
    case home
    case warikan
    case dayCount
    case goalCalc
    case math
    case history

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "ホーム"
        case .warikan: "ワリカン"
        case .dayCount: "日数計算"
        case .goalCalc: "目標計算"
        case .math: "数学"
        case .history: "History"
        }
    }

    var icon: String {
        switch self {
        case .home: "plus.slash.minus"
        case .warikan: "yensign.circle"
        case .dayCount: "calendar"
        case .goalCalc: "target"
        case .math: "x.squareroot"
        case .history: "clock.arrow.circlepath"
        }
    }
}

struct ContentView: View {
    @State private var selectedPage: Page = .home
    @State private var isMenuPresented = false

    private func openMenu() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation(.easeInOut(duration: 0.3)) {
            isMenuPresented = true
        }
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            // Current page
            currentPageView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Navigation buttons (home以外で表示)
            if selectedPage != .home {
                VStack {
                    Spacer()
                    HStack {
                        SideMenuTriggerButton {
                            openMenu()
                        }
                        Spacer()
                        CircleIconButton(systemName: "house.fill") {
                            selectedPage = .home
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }

            // Overlay + Menu
            SideMenuOverlay(isPresented: $isMenuPresented)

            SideMenu(
                isPresented: $isMenuPresented,
                selectedPage: $selectedPage
            )
        }
        .overlay(alignment: .top) {
            GeometryReader { geo in
                StatusBarView(safeAreaTop: geo.safeAreaInsets.top)
            }
            .ignoresSafeArea()
        }
        .gesture(sideMenuDragGesture())
        .statusBarHidden(true)
        .preferredColorScheme(.dark)
    }

    // MARK: - Swipe Gesture

    private func sideMenuDragGesture() -> some Gesture {
        DragGesture()
            .onEnded { value in
                let horizontalAmount = value.translation.width
                let verticalAmount = abs(value.translation.height)
                let swipeThreshold: CGFloat = 50

                guard abs(horizontalAmount) > verticalAmount else { return }

                if horizontalAmount > swipeThreshold && !isMenuPresented {
                    // 右スワイプ: 左端20px以内からのみメニューを開く
                    if value.startLocation.x <= 20 {
                        openMenu()
                    }
                } else if horizontalAmount < -swipeThreshold && isMenuPresented {
                    // 左スワイプ: メニューを閉じる
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuPresented = false
                    }
                }
            }
    }

    @ViewBuilder
    private var currentPageView: some View {
        switch selectedPage {
        case .home:
            HomeCalculatorView(onMenu: openMenu)
        case .warikan:
            WarikanView()
        case .dayCount:
            DayCountView()
        case .goalCalc:
            GoalCalcView()
        case .math:
            MathToolsView()
        case .history:
            HistoryView()
        }
    }
}
