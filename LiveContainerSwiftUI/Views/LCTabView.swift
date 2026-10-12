import SwiftUI
import WebKit

// Native SwiftUI wrapper that loads your custom HTML layout
struct LCWebLauncherView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // Hooks up the native JavaScript bridges we coded into your script.js file
        contentController.add(context.coordinator, name: "launchFilePicker")
        contentController.add(context.coordinator, name: "launchApp")
        contentController.add(context.coordinator, name: "deleteApp")
        
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false // Locks interface scale natively
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: LCWebLauncherView

        init(_ parent: LCWebLauncherView) {
            self.parent = parent
        }

        // Listens for touch actions executing on your iPhone screen layout
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "launchFilePicker" {
                // Call LiveContainer's native document controller picker
                NotificationCenter.default.post(name: NSNotification.Name("LC_TriggerFilePicker"), object: nil)
            } else if message.name == "launchApp", let bundleID = message.body as? String {
                // Commands the engine underneath to execute the selected IPA container environment
                NotificationCenter.default.post(name: NSNotification.Name("LC_LaunchAppWithBundleID"), object: bundleID)
            } else if message.name == "deleteApp", let bundleID = message.body as? String {
                // Native removal handler
                NotificationCenter.default.post(name: NSNotification.Name("LC_DeleteAppWithBundleID"), object: bundleID)
            }
        }
    }
}

// Main Window Controller layout that overrides default list tabs
struct LCTabView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Points straight to your hosted custom layout deployment!
            LCWebLauncherView(url: URL(string: "https://github.io")!)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
