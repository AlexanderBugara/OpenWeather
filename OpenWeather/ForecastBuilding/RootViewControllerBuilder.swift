import UIKit

protocol RootViewControllerBuilding {
    func make(coordinator: RootCoordinating, completion: @escaping (UINavigationController) -> Void)
}

final class RootViewControllerBuilder: RootViewControllerBuilding {
    func make(coordinator: RootCoordinating, completion: @escaping (UINavigationController) -> Void) {
        DispatchQueue.main.async {
            let rootViewModel = RootViewModel(coordinator: coordinator)
            coordinator.rootViewModel = rootViewModel
            let rootViewController = RootViewController(viewModel: rootViewModel)
            let navigationController = UINavigationController(rootViewController: rootViewController)
            rootViewModel.delegate = rootViewController
            completion(navigationController)
        }
    }
}

