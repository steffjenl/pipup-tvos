import UIKit

class NotificationManager {
    private var currentNotificationView: NotificationView?
    private let imageCache = NSCache<NSString, UIImage>()
    
    func showNotification(_ notification: NotificationData) {
        DispatchQueue.main.async {
            self.dismissCurrentNotification()
            self.presentNotification(notification)
        }
    }
    
    private func dismissCurrentNotification() {
        currentNotificationView?.removeFromSuperview()
        currentNotificationView = nil
    }
    
    private func presentNotification(_ notification: NotificationData) {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            print("No key window found")
            return
        }
        
        let notificationView = NotificationView()
        notificationView.configure(with: notification)
        
        // Add to window
        keyWindow.addSubview(notificationView)
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            notificationView.topAnchor.constraint(equalTo: keyWindow.topAnchor),
            notificationView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor),
            notificationView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor),
            notificationView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor)
        ])
        
        currentNotificationView = notificationView
        
        // Load image if URL is provided
        if let imageURL = notification.imageURL {
            loadImage(from: imageURL) { [weak notificationView] image in
                DispatchQueue.main.async {
                    notificationView?.setImage(image)
                }
            }
        }
        
        // If there's a stream URL, prepare to show video
        if let streamURL = notification.streamURL {
            notificationView.prepareForStreaming(url: streamURL)
        }
        
        // Show with animation
        notificationView.show()
        
        // Auto-dismiss after delay unless it's a stream
        if notification.streamURL == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.dismissCurrentNotification()
            }
        }
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            completion(nil)
            return
        }
        
        // Async image loading
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to create image from data")
                completion(nil)
                return
            }
            
            // Cache the image
            self?.imageCache.setObject(image, forKey: urlString as NSString)
            completion(image)
            
        }.resume()
    }
}

// MARK: - NotificationData

struct NotificationData {
    let title: String
    let message: String
    let imageURL: String?
    let streamURL: String?
    
    init(title: String, message: String, imageURL: String? = nil, streamURL: String? = nil) {
        self.title = title
        self.message = message
        self.imageURL = imageURL
        self.streamURL = streamURL
    }
    
    init(from json: [String: Any]) {
        self.title = json["title"] as? String ?? "Notification"
        self.message = json["message"] as? String ?? ""
        self.imageURL = json["imageURL"] as? String
        self.streamURL = json["streamURL"] as? String
    }
}

// MARK: - NotificationView

class NotificationView: UIView {
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let imageView = UIImageView()
    private let playerContainer = UIView()
    private var streamingPlayer: StreamingPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        alpha = 0
        
        // Background setup
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Content stack setup
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentView.addSubview(contentStackView)
        
        // Title label setup
        titleLabel.font = UIFont.systemFont(ofSize: 56, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(titleLabel)
        
        // Message label setup
        messageLabel.font = UIFont.systemFont(ofSize: 38, weight: .medium)
        messageLabel.textColor = .lightGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(messageLabel)
        
        // Image view setup
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        contentStackView.addArrangedSubview(imageView)
        
        // Player container setup
        playerContainer.backgroundColor = .black
        playerContainer.isHidden = true
        contentStackView.addArrangedSubview(playerContainer)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            contentStackView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 100),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -100),
            
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 800),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 600),
            
            playerContainer.widthAnchor.constraint(equalToConstant: 1280),
            playerContainer.heightAnchor.constraint(equalToConstant: 720)
        ])
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tapGesture)
    }
    
    func configure(with notification: NotificationData) {
        titleLabel.text = notification.title
        messageLabel.text = notification.message
    }
    
    func setImage(_ image: UIImage?) {
        guard let image = image else { return }
        imageView.image = image
        imageView.isHidden = false
    }
    
    func prepareForStreaming(url: String) {
        streamingPlayer = StreamingPlayer()
        streamingPlayer?.setupPlayer(in: playerContainer, with: url)
        playerContainer.isHidden = false
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1.0
        }
    }
    
    @objc private func dismiss() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.alpha = 0.0
        } completion: { _ in
            self.streamingPlayer?.stop()
            self.removeFromSuperview()
        }
    }
}