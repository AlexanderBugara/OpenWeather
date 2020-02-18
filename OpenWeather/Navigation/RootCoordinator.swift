//
//  RootCoordinator.swift
//  OpenWeather
//
//  Created by Oleksandr Buhara on 2/20/20.
//  Copyright © 2020 Oleksandr Buhara. All rights reserved.
//

import UIKit

enum Navigation<NextData, BackData> {
    case next(NextData)
    case back(BackData)
}

protocol Coordinator {
    associatedtype N
    associatedtype M
    func execute(navigation: Navigation<N, M>)
}

struct AnyCoordinator<I, J>: Coordinator {
    private let executeClosure: (Navigation<I, J>) -> Void

    init<T: Coordinator>(_ coordinator: T) where T.N == I, T.M == J {
        executeClosure = coordinator.execute
    }

    func execute(navigation: Navigation<I, J>) {
        executeClosure(navigation)
    }
}

protocol SelectCityDelegate: UIViewController {
    func didSelect(city: City)
}

final class RootCoordintor: Coordinator {
    enum Next {
        case startSearch(SelectCityDelegate)
        case startInfo
    }

    enum Back {
        case backFromSearch(UIViewController, City?)
        case backInfo
    }

    private weak var selectCityDelegate: SelectCityDelegate?

    func execute(navigation: Navigation<Next, Back>) {
        switch navigation {
        case .next(let next): handle(next: next)
        case .back(let back): handle(back: back)
        }
    }

    private func handle(next: Next) {
        switch next {
        case .startInfo: break
        case .startSearch(let sender):
            selectCityDelegate = sender
            let citySearchViewController = CitySearchViewController(coordinator: AnyCoordinator(self))
            let navigationController = UINavigationController(rootViewController: citySearchViewController)
            navigationController.modalPresentationStyle = .fullScreen
            sender.present(navigationController, animated: true)
        }
    }

    private func handle(back: Back) {
        switch back {
        case .backInfo: break
        case .backFromSearch(let sender, let city):
            sender.dismiss(animated: true) { [weak self] in
                guard let city = city else { return }
                self?.selectCityDelegate?.didSelect(city: city)
            }
        }
    }
}
