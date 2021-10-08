import Combine
import UIKit

struct App {
    let session: Session
    let window: UIWindow
}

final class LaunchTask: Task {
    typealias Output = App
    typealias Failure = Error
    
    private let windowTask: AnyPublisher<UIWindow, Error>
    private let sessionTask: AnyPublisher<Session, Error>
    private let userConsentTask: AnyPublisher<Void, Error>
    private let termsAndConditionsTask: AnyPublisher<Void, Error>
    
    private(set) lazy var publisher: AnyPublisher<Output, Failure> = windowTask
            .zip(sessionTask)
            .zip(userConsentTask)
            .zip(termsAndConditionsTask)
            .map { App(session: $0.0.0.1, window: $0.0.0.0) }
            .eraseToAnyPublisher()
    
    init(windowTask: AnyPublisher<UIWindow, Error>,
         sessionTask: AnyPublisher<Session, Error>,
         userConsentTask: AnyPublisher<Void, Error>,
         termsAndConditionsTask: AnyPublisher<Void, Error>) {
        self.windowTask = windowTask
        self.sessionTask = sessionTask
        self.userConsentTask = userConsentTask
        self.termsAndConditionsTask = termsAndConditionsTask
    }
}
