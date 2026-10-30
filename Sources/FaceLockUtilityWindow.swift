import AppKit

public class FaceLockUtilityWindow: NSWindow {
    public var onRefresh: (() -> Void)?
    public var onSearch: (() -> Void)?

    public override func cancelOperation(_ sender: Any?) {
        self.orderOut(sender)
    }

    public override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.keyCode == 53 { // ESC key
            self.orderOut(nil)
            return true
        }

        if event.modifierFlags.contains(.command) {
            let chars = (event.charactersIgnoringModifiers ?? "").lowercased()
            if chars == "w" {
                self.orderOut(nil)
                return true
            }
            if chars == "r", let refresh = onRefresh {
                refresh()
                return true
            }
            if chars == "f", let search = onSearch {
                search()
                return true
            }
        }
        return super.performKeyEquivalent(with: event)
    }

    public override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC key
            self.orderOut(nil)
            return
        }
        super.keyDown(with: event)
    }
}
