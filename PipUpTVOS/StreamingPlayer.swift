import AVFoundation
import AVKit
import UIKit

class StreamingPlayer {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerViewController: AVPlayerViewController?
    private weak var containerView: UIView?
    
    func setupPlayer(in containerView: UIView, with urlString: String) {
        self.containerView = containerView
        
        guard let url = URL(string: urlString) else {
            print("Invalid stream URL: \(urlString)")
            return
        }
        
        // Create player with error handling
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Set up player layer
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        
        playerLayer.frame = containerView.bounds
        playerLayer.videoGravity = .resizeAspect
        containerView.layer.addSublayer(playerLayer)
        
        // Add observers for player status
        addPlayerObservers()
        
        // Start playback
        player?.play()
        
        print("Starting stream playback for: \(urlString)")
    }
    
    func setupPlayerViewController(in containerView: UIView, with urlString: String) {
        self.containerView = containerView
        
        guard let url = URL(string: urlString) else {
            print("Invalid stream URL: \(urlString)")
            return
        }
        
        // Create player item and player
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Create player view controller
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.showsPlaybackControls = true
        
        // Add to container
        if let playerVC = playerViewController {
            playerVC.view.frame = containerView.bounds
            containerView.addSubview(playerVC.view)
        }
        
        // Add observers
        addPlayerObservers()
        
        // Start playback
        player?.play()
        
        print("Starting stream playback with controls for: \(urlString)")
    }
    
    private func addPlayerObservers() {
        guard let player = player else { return }
        
        // Observer for player status
        player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        // Observer for player item status
        if let playerItem = player.currentItem {
            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            
            // Observer for playback stall
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playbackStalled),
                name: .AVPlayerItemPlaybackStalled,
                object: playerItem
            )
            
            // Observer for playback failure
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playbackFailed),
                name: .AVPlayerItemFailedToPlayToEndTime,
                object: playerItem
            )
        }
    }
    
    private func removePlayerObservers() {
        player?.removeObserver(self, forKeyPath: "status")
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            if let player = object as? AVPlayer {
                handlePlayerStatusChange(player.status)
            } else if let playerItem = object as? AVPlayerItem {
                handlePlayerItemStatusChange(playerItem.status)
            }
        }
    }
    
    private func handlePlayerStatusChange(_ status: AVPlayer.Status) {
        switch status {
        case .unknown:
            print("Player status: Unknown")
        case .readyToPlay:
            print("Player status: Ready to play")
        case .failed:
            print("Player status: Failed - \(player?.error?.localizedDescription ?? "Unknown error")")
            handlePlaybackError("Player failed to initialize")
        @unknown default:
            print("Player status: Unknown default case")
        }
    }
    
    private func handlePlayerItemStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            print("Player item status: Unknown")
        case .readyToPlay:
            print("Player item status: Ready to play")
        case .failed:
            print("Player item status: Failed - \(player?.currentItem?.error?.localizedDescription ?? "Unknown error")")
            handlePlaybackError("Media failed to load")
        @unknown default:
            print("Player item status: Unknown default case")
        }
    }
    
    @objc private func playbackStalled() {
        print("Playback stalled - attempting to recover")
        // Attempt to recover by seeking to current time
        if let currentTime = player?.currentTime() {
            player?.seek(to: currentTime)
        }
    }
    
    @objc private func playbackFailed() {
        print("Playback failed to reach end")
        handlePlaybackError("Playback interrupted")
    }
    
    private func handlePlaybackError(_ message: String) {
        DispatchQueue.main.async {
            // You could show an error overlay here
            print("Streaming error: \(message)")
            
            // Attempt to restart playback after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.player?.play()
            }
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.pause()
        removePlayerObservers()
        playerLayer?.removeFromSuperlayer()
        playerViewController?.view.removeFromSuperview()
        player = nil
        playerLayer = nil
        playerViewController = nil
    }
    
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    var currentTime: CMTime? {
        return player?.currentTime()
    }
    
    var duration: CMTime? {
        return player?.currentItem?.duration
    }
}

// MARK: - StreamingPlayer Error Handling Extension

extension StreamingPlayer {
    
    func validateStreamURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        // Check if it's a supported streaming protocol
        let supportedSchemes = ["http", "https", "rtsp", "rtmp"]
        guard let scheme = url.scheme?.lowercased(),
              supportedSchemes.contains(scheme) else {
            return false
        }
        
        return true
    }
    
    func testStreamConnectivity(_ urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        // For HTTP/HTTPS URLs, we can test connectivity
        if url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https" {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10.0
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }.resume()
        } else {
            // For RTSP and other protocols, assume they're valid
            // In a production app, you might want to implement more sophisticated testing
            completion(true)
        }
    }
}