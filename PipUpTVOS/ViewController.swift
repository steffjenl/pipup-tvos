import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var serverInfoLabel: UILabel!
    
    private var notificationOverlay: NotificationOverlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotificationHandlers()
    }
    
    private func setupUI() {
        statusLabel.text = "PipUp Server Status: Running"
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        serverInfoLabel.text = "HTTP Server running on port 8080\n\nEndpoints:\n• POST /notify/image\n• POST /notify/video"
        serverInfoLabel.textColor = .lightGray
        serverInfoLabel.font = UIFont.systemFont(ofSize: 18)
        serverInfoLabel.numberOfLines = 0
        serverInfoLabel.textAlignment = .center
        
        view.backgroundColor = .black
    }
    
    private func setupNotificationHandlers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleImageNotification(_:)),
            name: NSNotification.Name("ShowImageNotification"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVideoNotification(_:)),
            name: NSNotification.Name("ShowVideoNotification"),
            object: nil
        )
    }
    
    @objc private func handleImageNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let title = userInfo["title"] as? String,
              let body = userInfo["body"] as? String,
              let imageUrl = userInfo["imageUrl"] as? String else {
            return
        }
        
        DispatchQueue.main.async {
            self.showImageNotification(title: title, body: body, imageUrl: imageUrl)
        }
    }
    
    @objc private func handleVideoNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let title = userInfo["title"] as? String,
              let body = userInfo["body"] as? String,
              let rtspUrl = userInfo["rtspUrl"] as? String else {
            return
        }
        
        DispatchQueue.main.async {
            self.showVideoNotification(title: title, body: body, rtspUrl: rtspUrl)
        }
    }
    
    private func showImageNotification(title: String, body: String, imageUrl: String) {
        // Remove any existing overlay
        notificationOverlay?.removeFromSuperview()
        
        // Create and show new overlay
        notificationOverlay = NotificationOverlay()
        notificationOverlay?.showImageNotification(
            title: title,
            body: body,
            imageUrl: imageUrl,
            in: self.view
        )
    }
    
    private func showVideoNotification(title: String, body: String, rtspUrl: String) {
        // Remove any existing overlay
        notificationOverlay?.removeFromSuperview()
        
        // Show notification first
        notificationOverlay = NotificationOverlay()
        notificationOverlay?.showTextNotification(
            title: title,
            body: body,
            in: self.view
        )
        
        // Launch video player after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.presentVideoPlayer(rtspUrl: rtspUrl)
        }
    }
    
    private func presentVideoPlayer(rtspUrl: String) {
        guard let url = URL(string: rtspUrl) else {
            print("Invalid RTSP URL: \(rtspUrl)")
            return
        }
        
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}