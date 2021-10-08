import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private(set) var launchTask: LaunchTask!
    private var launching: Cancellable?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let windowTask = GetWindowTask(windowScene)
        let sessionTask = SetupSessionTask()
        let consentTask = GetUserTrackingConsentTask(
            windowTask: windowTask.eraseToAnyPublisher(),
            anonIdTask: sessionTask.map(\.anonId).eraseToAnyPublisher()
        )
    
        let termsTask = AcceptTermsAndConditionsTask(
            windowTask: windowTask.eraseToAnyPublisher(),
            anonIdTask: sessionTask.map(\.anonId).eraseToAnyPublisher(),
            consentTask: consentTask.eraseToAnyPublisher()
        )
        
        launchTask = LaunchTask(
            windowTask: windowTask.eraseToAnyPublisher(),
            sessionTask: sessionTask.eraseToAnyPublisher(),
            userConsentTask: consentTask.eraseToAnyPublisher(),
            termsAndConditionsTask: termsTask.eraseToAnyPublisher()
        )
        launching = launchTask
            .sink(
                receiveCompletion: { completion in
                    dump(completion)
                },
                receiveValue: { app in
                    dump(app)
                }
            )
    }
}

