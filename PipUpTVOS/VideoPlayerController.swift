import UIKit
import AVKit
import AVFoundation

class VideoPlayerController: AVPlayerViewController {
    
    private var rtspUrl: String?
    
    convenience init(rtspUrl: String) {
        self.init()
        self.rtspUrl = rtspUrl
        setupPlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure player view controller
        showsPlaybackControls = true
        allowsPictureInPicturePlayback = true
        
        // Add error handling
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFailToPlay(_:)),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidReachEnd(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    private func setupPlayer() {
        guard let urlString = rtspUrl,
              let url = URL(string: urlString) else {
            showErrorAlert(message: "Invalid RTSP URL")
            return
        }
        
        print("🎬 Setting up video player for: \(urlString)")
        
        // Create player item with RTSP URL
        let playerItem = AVPlayerItem(url: url)
        
        // Create player
        let player = AVPlayer(playerItem: playerItem)
        
        // Configure audio session for tvOS
        configureAudioSession()
        
        // Set player
        self.player = player
        
        // Add observer for player status
        playerItem.addObserver(
            self,
            forKeyPath: "status",
            options: [.new, .initial],
            context: nil
        )
        
        // Add observer for loading state
        playerItem.addObserver(
            self,
            forKeyPath: "loadedTimeRanges",
            options: .new,
            context: nil
        )
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .readyToPlay:
                    print("✅ Video ready to play")
                    DispatchQueue.main.async {
                        self.player?.play()
                    }
                case .failed:
                    print("❌ Video failed to load: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to load video stream")
                    }
                case .unknown:
                    print("⏳ Video loading...")
                @unknown default:
                    break
                }
            }
        } else if keyPath == "loadedTimeRanges" {
            // You can add buffering progress updates here if needed
        }
    }
    
    @objc private func playerDidFailToPlay(_ notification: Notification) {
        print("❌ Player failed to play to end time")
        showErrorAlert(message: "Video playback failed")
    }
    
    @objc private func playerDidReachEnd(_ notification: Notification) {
        print("✅ Video playback completed")
        // Optionally auto-dismiss or loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Video Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.setupPlayer()
        })
        
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        // Remove KVO observers
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
}