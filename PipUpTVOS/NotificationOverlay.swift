import UIKit
import Foundation

class NotificationOverlay: UIView {
    
    private var titleLabel: UILabel!
    private var bodyLabel: UILabel!
    private var imageView: UIImageView!
    private var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }
    
    private func setupOverlay() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Container view for the notification content
        containerView = UIView()
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOpacity = 0.3
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title label
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Body label
        bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bodyLabel)
        
        // Image view
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 800),
            containerView.heightAnchor.constraint(lessThanOrEqualToConstant: 600),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 100),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -100),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            
            // Body label constraints
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            bodyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            bodyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            
            // Image view constraints
            imageView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])
    }
    
    func showImageNotification(title: String, body: String, imageUrl: String, in parentView: UIView) {
        titleLabel.text = title
        bodyLabel.text = body
        
        // Set frame to parent view
        frame = parentView.bounds
        parentView.addSubview(self)
        
        // Load image asynchronously
        loadImage(from: imageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.imageView.isHidden = (image == nil)
            }
        }
        
        // Animate in
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, scaleY: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
        
        // Auto-dismiss after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.dismiss()
        }
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tapGesture)
    }
    
    func showTextNotification(title: String, body: String, in parentView: UIView) {
        titleLabel.text = title
        bodyLabel.text = body
        imageView.isHidden = true
        
        // Set frame to parent view
        frame = parentView.bounds
        parentView.addSubview(self)
        
        // Animate in
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, scaleY: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
        
        // Auto-dismiss after 3 seconds for text-only notifications
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismiss()
        }
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismiss() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, scaleY: 0.8)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}