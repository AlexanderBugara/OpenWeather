import UIKit

enum Action {
    case showCitiesList
    case forecast(City)
    case error(Error)
}

typealias Completion = (UIViewController) -> Void

protocol ForecastNavigation: AnyObject {
    func execute(action: Action)
}

enum TransferData {
    case city(City)
}

protocol Coordinating: AnyObject {
    var nextCoordinator: Coordinating? { get set }
    var previousCoordinator: Coordinating? { get set }
    func setup()
    func next()
    func back(data: TransferData?)
}

protocol RootCoordinating: Coordinating {
    var rootViewModel: RootViewModeling? { get set }
    func update(data: TransferData?)
}

final class RootControllerCoordinator {
    private weak var navigationController: UINavigationController?
    private let rootBuilder: RootViewControllerBuilding
    private let window: UIWindow?
    var nextCoordinator: Coordinating?
    weak var previousCoordinator: Coordinating?
    weak var rootViewModel: RootViewModeling?

    init(window: UIWindow?, rootBuilder: RootViewControllerBuilding = RootViewControllerBuilder(), citiesListBuilder: CitiesListBuilding = CitiesListBuilder()) {
        self.rootBuilder = rootBuilder
        self.window = window
    }
}

extension RootControllerCoordinator: RootCoordinating {
    func setup() {
        rootBuilder.make(coordinator: self) { [unowned self] navigationController in
            self.navigationController = navigationController
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
    }

    func next() {
        self.nextCoordinator = ListControllerCoordinator(navigationController: navigationController)
        self.nextCoordinator?.previousCoordinator = self
        self.nextCoordinator?.setup()
    }

    func update(data: TransferData?) {
        switch data {
        case .city(let city):
            rootViewModel?.fetch(city: city)
            break
        case .none:
            break
        }
    }

    func back(data: TransferData?) {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            self?.nextCoordinator = nil
            self?.update(data: data)
        })
    }
}


final class ListControllerCoordinator {
    private let citiesListBuilder: CitiesListBuilding
    private weak var navigationController: UINavigationController?
    var nextCoordinator: Coordinating?
    weak var previousCoordinator: Coordinating?

    init(citiesListBuilder: CitiesListBuilding = CitiesListBuilder(), navigationController: UINavigationController?) {
        self.citiesListBuilder = citiesListBuilder
        self.navigationController = navigationController
    }
}

extension ListControllerCoordinator: Coordinating {
    func setup() {
        citiesListBuilder.make(coordinator: self) { [unowned self] navigationController in
            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }

    func next() {
    }

    func back(data: TransferData?) {
        previousCoordinator?.back(data: data)
    }
}
