import Foundation
import Combine

extension Publisher {
    var anyPublisher: AnyPublisher<Output, Failure> {
        AnyPublisher<Output, Failure>(self)
    }
}

final class Barrier<Output, Failure: Error>: Task {
    private let group = DispatchGroup()
    private var cancellable: Cancellable?
    private let upstream: AnyPublisher<Output, Failure>
    
    private(set) lazy var publisher: AnyPublisher<Output, Failure> = { [weak self] in
        Future<Output, Failure> { completion in
            self?.group.notify(queue: .global()) {
                self?.group.enter()
           
                self?.cancellable = self?.upstream.sink(
                    receiveCompletion: { result in
                        if case .failure(let error) = result {
                            completion(.failure(error))
                            self?.group.leave()
                        }
                    },
                    receiveValue: { value in
                        completion(.success(value))
                        self?.group.leave()
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }()
    
    init(_ publisher: AnyPublisher<Output, Failure>) {
        self.upstream = publisher
    }
}

extension Publisher {
    var withBarier: Barrier<Output, Failure> {
        Barrier<Output, Failure>(self.eraseToAnyPublisher())
    }
}
