import Combine
import UIKit

struct Session {
    let anonId: String = UUID().uuidString
}

final class SetupSessionTask: Task {
    typealias Output = Session
    typealias Failure = Error

    private(set) lazy var publisher = Future<Output, Failure> { completion in completion(.success(Session())) }.eraseToAnyPublisher()
}

