import Cocoa
import FlutterMacOS
import WidgetKit

@main
class AppDelegate: FlutterAppDelegate {
  private var widgetChannel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    if let window = mainFlutterWindow,
       let controller = window.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "dev.fcleaner/widget",
        binaryMessenger: controller.engine.binaryMessenger
      )
      self.widgetChannel = channel

      channel.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "reloadTimelines":
          if #available(macOS 11.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
          }
          result(true)
        case "updateWidgetData":
          guard let args = call.arguments as? [String: Any],
                let jsonString = args["json"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing json string", details: nil))
            return
          }
          self?.saveWidgetData(jsonString: jsonString)
          if #available(macOS 11.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
          }
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  private func saveWidgetData(jsonString: String) {
    let fileManager = FileManager.default
    let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    guard let appFolder = appSupport?.appendingPathComponent("dev.fcleaner.fcleaner", isDirectory: true) else { return }
    do {
      try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true, attributes: nil)
      let fileURL = appFolder.appendingPathComponent("widget_data.json")
      try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
      print("Failed to save widget data: \(error)")
    }
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      widgetChannel?.invokeMethod("onDeepLink", arguments: url.absoluteString)
    }
    NSApp.activate(ignoringOtherApps: true)
    mainFlutterWindow?.makeKeyAndOrderFront(nil)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
