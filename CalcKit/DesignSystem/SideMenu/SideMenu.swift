import SwiftUI
import UIKit

struct SideMenu: View {
    @Binding var isPresented: Bool
    @Binding var selectedPage: Page

    var body: some View {
        GeometryReader { geo in
            let safe = geo.safeAreaInsets
            let size = geo.size

            let baseMenuWidth = min(
                size.width * DesignTokens.SideMenuLayout.menuWidthRatio,
                DesignTokens.SideMenuLayout.menuMaxWidth
            )
            let leadingOffset = max(
                safe.leading,
                DesignTokens.SideMenuLayout.minLeadingOffset
            )
            let effectiveMenuWidth = baseMenuWidth + leadingOffset + DesignTokens.SideMenuLayout.menuHorizontalPadding

            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {

                            // Header
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("⚡")
                                        .font(.title)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("CalcKit")
                                            .dynamicFont(
                                                size: DesignTokens.SideMenuTypography.headerTitleSize,
                                                weight: DesignTokens.SideMenuTypography.headerTitleWeight
                                            )
                                            .foregroundColor(DesignTokens.CommonTextColors.primary)
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 60)
                            .padding(.bottom, 16)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.background, AppTheme.background.opacity(0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            Divider()
                                .background(DesignTokens.SideMenuColors.divider)
                                .padding(.horizontal, 16)

                            // Menu Items
                            VStack(alignment: .leading, spacing: DesignTokens.SideMenuLayout.itemSpacing) {
                                ForEach(Page.allCases) { page in
                                    menuItem(page: page)
                                }

                                Divider()
                                    .background(DesignTokens.SideMenuColors.divider)
                                    .padding(.top, DesignTokens.SideMenuLayout.itemSpacing)

                                // Footer
                                Text("v1.1.0")
                                    .dynamicFont(
                                        size: DesignTokens.SideMenuTypography.footerInfoSize,
                                        weight: DesignTokens.SideMenuTypography.footerInfoWeight
                                    )
                                    .foregroundColor(DesignTokens.SideMenuColors.textMuted)
                                    .padding(.top, DesignTokens.SideMenuLayout.itemSpacing)

                                Spacer()
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 16)

                            Spacer(minLength: safe.bottom + 30)
                        }
                    }
                    .frame(width: baseMenuWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .overlay(alignment: .bottomLeading) {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            close()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(DesignTokens.CommonTextColors.secondary)
                                .frame(width: 44, height: 44)
                                .background(DesignTokens.CommonBackgroundColors.cardHighlight)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 16)
                        .padding(.bottom, safe.bottom + 16)
                    }
                    .padding(.leading, leadingOffset + DesignTokens.SideMenuLayout.menuHorizontalPadding)
                    .background(DesignTokens.SideMenuColors.background)
                    .cornerRadius(DesignTokens.SideMenuLayout.cornerRadius)
                    .shadow(color: Color.black.opacity(0.4), radius: 8, x: -4, y: 0)
                    .shadow(color: Color.black.opacity(0.4), radius: 8, x: 4, y: 0)
                    .offset(x: isPresented ? 0 : -effectiveMenuWidth - DesignTokens.SideMenuLayout.menuHideOffset)
                    .transition(.move(edge: .leading).combined(with: .opacity))

                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
    }

    private func menuItem(page: Page) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selectedPage = page
            close()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: page.icon)
                    .font(.system(size: DesignTokens.SideMenuTypography.itemIconSize, design: .rounded))
                    .foregroundColor(
                        selectedPage == page
                            ? AppTheme.accent
                            : DesignTokens.SideMenuColors.iconColor
                    )
                    .frame(width: 24, height: 24)

                Text(page.title)
                    .dynamicFont(
                        size: DesignTokens.SideMenuTypography.itemTitleSize,
                        weight: selectedPage == page ? .semibold : DesignTokens.SideMenuTypography.itemTitleWeight
                    )
                    .foregroundColor(
                        selectedPage == page
                            ? AppTheme.accent
                            : DesignTokens.CommonTextColors.primary
                    )

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: DesignTokens.SideMenuTypography.chevronSize, design: .rounded))
                    .foregroundColor(DesignTokens.SideMenuColors.textMuted)
            }
            .padding(.vertical, DesignTokens.SideMenuLayout.itemVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func close() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPresented = false
        }
    }
}
