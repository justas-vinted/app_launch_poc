import Combine
import UIKit

final class AcceptTermsAndConditionsTask: Publisher {
    struct TermsAndConditionsDeclinedError: Error {}
    typealias Output = Void
    typealias Failure = Error
    
    private let windowTask: AnyPublisher<UIWindow, Error>
    private let anonIdTask: AnyPublisher<String, Error>
    private let consentTask: AnyPublisher<Void, Error>
    
    private lazy var publisher = windowTask
        .zip(anonIdTask)
        .zip(consentTask)
        .map { (window: $0.0.0, anonId: $0.0.1) }
        .receive(on: DispatchQueue.main, options: nil)
        .flatMap { [weak self] result in
            Future<Void, Failure> { completion in
                self?.presentDialog(from: result.window, for: result.anonId, completion: completion)
            }
        }
        .map { _ in Void() }
        .withBarier
    
    init(windowTask: AnyPublisher<UIWindow, Error>,
         anonIdTask: AnyPublisher<String, Error>,
         consentTask: AnyPublisher<Void, Error>) {
        self.anonIdTask = anonIdTask
        self.windowTask = windowTask
        self.consentTask = consentTask
    }
    
    private func presentDialog(from window: UIWindow, for user: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let alert = UIAlertController(
            title: "Accept T&C?",
            message: "user: \(user)",
            preferredStyle: .actionSheet
        )
        alert.addAction(.init(title: "Yes", style: .default) { _ in completion(.success(Void())) })
        alert.addAction(.init(title: "No", style: .default) { _ in completion(.failure(TermsAndConditionsDeclinedError())) })
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
}
