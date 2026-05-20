import SwiftUI

struct SideMenuTriggerButton: View {
    let action: () -> Void

    var body: some View {
        CircleIconButton(systemName: "line.3.horizontal", action: action)
            .accessibilityLabel("メニューを開く")
    }
}
