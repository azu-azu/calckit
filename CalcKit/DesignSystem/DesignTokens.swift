import SwiftUI

struct DesignTokens {

    // MARK: - Common Text Colors

    enum CommonTextColors {
        static let primary = Color.white.opacity(0.95)
        static let secondary = Color.white.opacity(0.8)
        static let tertiary = Color.white.opacity(0.7)
        static let quaternary = Color.white.opacity(0.6)
        static let quinary = Color.white.opacity(0.5)
    }

    // MARK: - Common Background Colors

    enum CommonBackgroundColors {
        static let cardHighlight = Color.white.opacity(0.15)
        static let cardBorderSubtle = Color.white.opacity(0.1)
        static let cardSubtle = Color.white.opacity(0.08)
    }

    // MARK: - Calculator Colors

    enum CalcColors {
        static let displayText = CommonTextColors.primary
        static let expressionText = CommonTextColors.tertiary
    }

    // MARK: - Calculator Typography

    enum CalcTypography {
        static let displaySize: CGFloat = 48
        static let displayWeight: Font.Weight = .light
        static let expressionSize: CGFloat = 20
        static let expressionWeight: Font.Weight = .regular
        static let buttonSize: CGFloat = 24
        static let buttonWeight: Font.Weight = .medium
    }

    // MARK: - Calculator Layout

    enum CalcLayout {
        static let buttonCornerRadius: CGFloat = 16
        static let buttonSpacing: CGFloat = 8
        static let buttonHeight: CGFloat = 56
        static let toolbarHeight: CGFloat = 40
        static let displayHorizontalPadding: CGFloat = 24
        static let displayBottomPadding: CGFloat = 12
    }

    // MARK: - Input Colors (Warikan, GoalCalc etc.)

    enum InputColors {
        static let fieldBackground = Color.white.opacity(0.08)
    }

    // MARK: - Input Layout

    enum InputLayout {
        static let fieldCornerRadius: CGFloat = 12
        static let fieldPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 16
        static let screenHorizontal: CGFloat = 24
        static let cardPadding: CGFloat = 16
    }

    // MARK: - SideMenu Colors

    enum SideMenuColors {
        static let background = AppTheme.background.opacity(0.95)
        static let overlay = Color.black.opacity(0.35)
        static let divider = Color.white.opacity(0.2)
        static let iconColor = CommonTextColors.secondary
        static let textMuted = CommonTextColors.quaternary
    }

    // MARK: - SideMenu Layout

    enum SideMenuLayout {
        static let menuWidthRatio: CGFloat = 0.8
        static let menuMaxWidth: CGFloat = 300
        static let menuHorizontalPadding: CGFloat = 16
        static let menuHideOffset: CGFloat = 20
        static let minLeadingOffset: CGFloat = 16
        static let cornerRadius: CGFloat = 10
        static let itemVerticalPadding: CGFloat = 14
        static let itemSpacing: CGFloat = 20
    }

    // MARK: - SideMenu Typography

    enum SideMenuTypography {
        static let headerTitleSize: CGFloat = 20
        static let headerTitleWeight: Font.Weight = .bold
        static let itemTitleSize: CGFloat = 17
        static let itemTitleWeight: Font.Weight = .regular
        static let itemIconSize: CGFloat = 18
        static let chevronSize: CGFloat = 13
        static let footerInfoSize: CGFloat = 12
        static let footerInfoWeight: Font.Weight = .regular
    }

    // MARK: - Feature Typography

    enum FeatureTypography {
        static let sectionTitleSize: CGFloat = 18
        static let sectionTitleWeight: Font.Weight = .semibold
        static let resultSize: CGFloat = 32
        static let resultWeight: Font.Weight = .semibold
    }

    // MARK: - Status Colors

    enum StatusColors {
        static let danger = Color(hex: "#FF5C5C")
        static let warning = Color(hex: "#FFC069")
        static let success = Color(hex: "#4ADE80")
    }
}
