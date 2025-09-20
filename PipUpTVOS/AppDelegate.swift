import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var httpServer: HTTPServer?
    private var notificationManager: NotificationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize the main window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create and set the root view controller
        let contentViewController = ContentViewController()
        window?.rootViewController = contentViewController
        window?.makeKeyAndVisible()
        
        // Initialize notification manager
        notificationManager = NotificationManager()
        
        // Initialize and start HTTP server
        setupHTTPServer()
        
        return true
    }
    
    private func setupHTTPServer() {
        httpServer = HTTPServer()
        httpServer?.notificationManager = notificationManager
        
        do {
            try httpServer?.start()
            print("HTTP Server started successfully")
        } catch {
            print("Failed to start HTTP Server: \(error)")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Keep the server running in background if possible
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Refresh any necessary components
    }

    func applicationWillTerminate(_ application: UIApplication) {
        httpServer?.stop()
    }
}