import Combine

protocol Task: Publisher {
    var publisher: AnyPublisher<Output, Failure> { get }
}

extension Task {
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
}
