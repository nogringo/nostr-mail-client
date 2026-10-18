import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  // A right click leaves the app inactive, and Flutter only tracks the mouse
  // in the key window: menus opened that way got no hover.
  override func sendEvent(_ event: NSEvent) {
    if event.type == .rightMouseDown && !isKeyWindow {
      NSApp.activate(ignoringOtherApps: true)
      makeKeyAndOrderFront(nil)
    }
    super.sendEvent(event)
  }
}
