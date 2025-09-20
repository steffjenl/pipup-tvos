import UIKit

class ContentViewController: UIViewController {
    
    private let statusLabel = UILabel()
    private let logoImageView = UIImageView()
    private let instructionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        
        // Logo setup
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(systemName: "tv.circle.fill")
        logoImageView.tintColor = UIColor.white
        view.addSubview(logoImageView)
        
        // Status label setup
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "PipUp tvOS Server Ready"
        statusLabel.textColor = UIColor.white
        statusLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        // Instruction label setup
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.text = "Send notifications via HTTP API\nListening on port 8080"
        instructionLabel.textColor = UIColor.lightGray
        instructionLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        view.addSubview(instructionLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Logo constraints
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Status label constraints
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 50),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 50),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -50),
            
            // Instruction label constraints
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            instructionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 50),
            instructionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -50)
        ])
    }
    
    func updateStatus(_ status: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = status
        }
    }
}