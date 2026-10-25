import UIKit
import UserNotifications
import UserNotificationsUI

final class ProbeNotification: UIViewController, UNNotificationContentExtension {
    let pet = UIImageView()
    let copy = UILabel()
    let post = UIImageView(image: UIImage(named: "post"))
    var character = 1
    var reduceObserver: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1, green: 0.988, blue: 0.961, alpha: 1)
        pet.contentMode = .scaleAspectFit; pet.widthAnchor.constraint(equalToConstant: 48).isActive = true
        pet.heightAnchor.constraint(equalToConstant: 48).isActive = true
        copy.text = ProbeData.copy; copy.numberOfLines = 0; copy.font = .systemFont(ofSize: 12)
        let heading = UIStackView(arrangedSubviews: [pet, copy]); heading.spacing = 8; heading.alignment = .center
        post.contentMode = .scaleAspectFit; post.heightAnchor.constraint(equalToConstant: 170).isActive = true
        let stack = UIStackView(arrangedSubviews: [heading, post]); stack.axis = .vertical; stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10), stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10), stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10), stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)])
        preferredContentSize = CGSize(width: 340, height: 246)
        reduceObserver = NotificationCenter.default.addObserver(forName: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil, queue: .main) { [weak self] _ in self?.animateIfAllowed() }
    }
    func didReceive(_ notification: UNNotification) {
        character = min(4, max(1, notification.request.content.userInfo["character"] as? Int ?? 1))
        animateIfAllowed()
    }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); animateIfAllowed() }
    override func viewDidDisappear(_ animated: Bool) { super.viewDidDisappear(animated); pet.stopAnimating() }
    func animateIfAllowed() {
        pet.stopAnimating(); pet.image = UIImage(named: "pet_\(character)_a")
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        pet.animationImages = ["a", "b"].compactMap { UIImage(named: "pet_\(character)_\($0)") }
        pet.animationDuration = 5; pet.animationRepeatCount = 0; pet.startAnimating()
    }
    deinit { if let observer = reduceObserver { NotificationCenter.default.removeObserver(observer) } }
}
