import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var httpServer: HTTPServer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Create the main window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set up the main view controller
        let mainViewController = ViewController()
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        
        // Start the HTTP server
        setupHTTPServer()
        
        return true
    }
    
    private func setupHTTPServer() {
        httpServer = HTTPServer()
        
        do {
            try httpServer?.start()
            print("HTTP Server started successfully on port 8080")
        } catch {
            print("Failed to start HTTP server: \(error)")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        httpServer?.stop()
    }
}