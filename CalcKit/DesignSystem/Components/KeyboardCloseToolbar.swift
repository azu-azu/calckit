import SwiftUI

struct KeyboardCloseToolbar: ViewModifier {
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
    }
}

extension View {
    func keyboardCloseToolbar(_ onDismiss: @escaping () -> Void) -> some View {
        modifier(KeyboardCloseToolbar(onDismiss: onDismiss))
    }
}
