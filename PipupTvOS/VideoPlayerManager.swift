import UIKit
import AVFoundation
import AVKit

class VideoPlayerManager {
    static let shared = VideoPlayerManager()
    
    private init() {}
    
    func playVideo(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid video URL: \(urlString)")
            showError(message: "Invalid video URL")
            return
        }
        
        // Validate URL scheme for RTSP
        if url.scheme?.lowercased() != "rtsp" && url.scheme?.lowercased() != "http" && url.scheme?.lowercased() != "https" {
            print("Unsupported URL scheme: \(url.scheme ?? "nil")")
            showError(message: "Unsupported video URL scheme")
            return
        }
        
        // Create AVPlayer with the URL
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // Get the current view controller to present from
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Unable to get root view controller")
            return
        }
        
        // Present the video player
        rootViewController.present(playerViewController, animated: true) {
            // Start playing automatically
            player.play()
        }
        
        // Add error handling for player
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { notification in
            if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                print("Video playback failed: \(error)")
                self.showError(message: "Failed to play video: \(error.localizedDescription)")
                playerViewController.dismiss(animated: true)
            }
        }
        
        // Add observer for when playback ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            print("Video playback completed")
            playerViewController.dismiss(animated: true)
        }
        
        // Monitor player status
        player.currentItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return
            }
            
            let alert = UIAlertController(title: "Video Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            rootViewController.present(alert, animated: true)
        }
    }
}

// MARK: - KVO Observer
extension VideoPlayerManager {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .readyToPlay:
                    print("Video is ready to play")
                case .failed:
                    if let error = playerItem.error {
                        print("Video failed to load: \(error)")
                        showError(message: "Failed to load video: \(error.localizedDescription)")
                    }
                case .unknown:
                    print("Video status unknown")
                @unknown default:
                    print("Video status unknown (new case)")
                }
            }
        }
    }
}