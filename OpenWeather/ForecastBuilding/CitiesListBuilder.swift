import UIKit

protocol CitiesListBuilding {
    func make(coordinator: ListControllerCoordinator, completion: @escaping (UINavigationController) -> Void)
}

final class CitiesListBuilder: CitiesListBuilding {
    func make(coordinator: ListControllerCoordinator, completion: @escaping (UINavigationController) -> Void) {
        DispatchQueue.main.async {
            let citiesListViewModel = CitiesListViewModel(coordinator: coordinator)
            let citiesListViewController = CitiesListViewController(viewModel: citiesListViewModel)
            citiesListViewModel.delegate = citiesListViewController
            let navigationViewController = UINavigationController(rootViewController: citiesListViewController)
            navigationViewController.modalTransitionStyle = .flipHorizontal
            navigationViewController.modalPresentationStyle = .fullScreen
            completion(navigationViewController)
        }
    }
}
