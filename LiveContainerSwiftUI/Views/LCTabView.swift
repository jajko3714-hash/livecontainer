import SwiftUI
import WebKit

struct LCWebLauncherView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let ctrl = WKUserContentController()
        
        // This golden bridge hooks up your website controls to the real iPhone systems
        ctrl.add(context.coordinator, name: "launchFilePicker")
        ctrl.add(context.coordinator, name: "launchApp")
        ctrl.add(context.coordinator, name: "deleteApp")
        config.userContentController = ctrl
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // This targets your exact live launcher design on your github.io page
        if let url = URL(string: "https://github.io") {
            uiView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: LCWebLauncherView
        init(_ parent: LCWebLauncherView) { self.parent = parent }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "launchFilePicker" {
                NotificationCenter.default.post(name: NSNotification.Name("LC_TriggerFilePicker"), object: nil)
            } else if message.name == "launchApp", let bundleID = message.body as? String {
                NotificationCenter.default.post(name: NSNotification.Name("LC_LaunchAppWithBundleID"), object: bundleID)
            } else if message.name == "deleteApp", let bundleID = message.body as? String {
                NotificationCenter.default.post(name: NSNotification.Name("LC_DeleteAppWithBundleID"), object: bundleID)
            }
        }
    }
}

struct LCTabView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            LCWebLauncherView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
