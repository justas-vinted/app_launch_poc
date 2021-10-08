import Combine
import UIKit

final class GetWindowTask: Task {
    typealias Output = UIWindow
    typealias Failure = Error
    struct WindowIsNotAwailableError: Error {}
    
    private let scene: UIWindowScene
    
    private(set) lazy var publisher = Future<Output, Failure> { [weak self] completion in
        guard let window = self?.scene.windows.first else {
            completion(.failure(WindowIsNotAwailableError()))
            return
        }
        completion(.success(window))
    }
    .eraseToAnyPublisher()
    
    init(_ scene: UIWindowScene) {
        self.scene = scene
    }
}
