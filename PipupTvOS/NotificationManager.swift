import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func showImageNotification(title: String, body: String, imageUrl: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Unable to get main window")
            return
        }
        
        let notificationView = ImageNotificationView(title: title, body: body, imageUrl: imageUrl)
        notificationView.show(in: window)
    }
    
    func showVideoNotification(title: String, body: String, rtspUrl: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Unable to get main window")
            return
        }
        
        let notificationView = VideoNotificationView(title: title, body: body, rtspUrl: rtspUrl)
        notificationView.show(in: window)
    }
}

class ImageNotificationView: UIView {
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let imageView = UIImageView()
    private let containerView = UIView()
    private let closeButton = UIButton()
    
    init(title: String, body: String, imageUrl: String) {
        super.init(frame: .zero)
        setupUI(title: title, body: body)
        loadImage(from: imageUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, body: String) {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Container view
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 20
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title label
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Body label
        bodyLabel.text = body
        bodyLabel.font = UIFont.systemFont(ofSize: 24)
        bodyLabel.textColor = .darkGray
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bodyLabel)
        
        // Image view
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        // Close button
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.layer.cornerRadius = 10
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .primaryActionTriggered)
        containerView.addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 600),
            containerView.heightAnchor.constraint(equalToConstant: 500),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            
            // Body label
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            bodyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            bodyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            
            // Image view
            imageView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Unable to create image from data")
                    return
                }
                
                self?.imageView.image = image
            }
        }.resume()
    }
    
    @objc private func closeButtonTapped() {
        dismiss()
    }
    
    func show(in window: UIWindow) {
        frame = window.bounds
        window.addSubview(self)
        
        // Animation
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
            self.alpha = 1
        }
        
        // Auto dismiss after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.dismiss()
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

class VideoNotificationView: UIView {
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let containerView = UIView()
    private let playButton = UIButton()
    private let closeButton = UIButton()
    private let rtspUrl: String
    
    init(title: String, body: String, rtspUrl: String) {
        self.rtspUrl = rtspUrl
        super.init(frame: .zero)
        setupUI(title: title, body: body)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, body: String) {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Container view
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 20
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title label
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Body label
        bodyLabel.text = body
        bodyLabel.font = UIFont.systemFont(ofSize: 24)
        bodyLabel.textColor = .darkGray
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bodyLabel)
        
        // Play button
        playButton.setTitle("▶ Play Video", for: .normal)
        playButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        playButton.setTitleColor(.white, for: .normal)
        playButton.backgroundColor = .systemGreen
        playButton.layer.cornerRadius = 15
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .primaryActionTriggered)
        containerView.addSubview(playButton)
        
        // Close button
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.layer.cornerRadius = 10
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .primaryActionTriggered)
        containerView.addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 600),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            
            // Body label
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            bodyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            bodyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            
            // Play button
            playButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 40),
            playButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 200),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func playButtonTapped() {
        VideoPlayerManager.shared.playVideo(from: rtspUrl)
        dismiss()
    }
    
    @objc private func closeButtonTapped() {
        dismiss()
    }
    
    func show(in window: UIWindow) {
        frame = window.bounds
        window.addSubview(self)
        
        // Animation
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
            self.alpha = 1
        }
        
        // Auto dismiss after 15 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.dismiss()
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}