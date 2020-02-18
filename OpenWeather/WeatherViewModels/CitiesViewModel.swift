import Foundation

protocol CitiesListViewModeling {
    func select(city: City)
    func search(cityName: String)
    func done()
    func close()
}

protocol CitiesListViewModelDelegate: AnyObject {
    func disableDoneButton(flag: Bool)
    func clean()
    func update(cities: [City])
    func show(error: Error)
}

final class CitiesListViewModel {
    private let coordinator: Coordinating
    private let citiesListProvider: CitiesListProviding
    private var city: City?

    weak var delegate: CitiesListViewModelDelegate?

    // MARK: Init
    /// Initialization CitiesListViewModel
    /// - Parameter coordinator: uses for UI navigation back to weather screen and transfering selected city to RootViewModel
    /// - Parameter citiesListProvider: CitiesDataProvider fetched cities from cities.db
    init(coordinator: Coordinating, citiesListProvider: CitiesListProviding = CitiesDataProvider()) {
        self.coordinator = coordinator
        self.citiesListProvider = citiesListProvider
    }
}

// MARK: CitiesListViewModeling
extension CitiesListViewModel: CitiesListViewModeling {

    // MARK: Picked city on table cell selection
    func select(city: City) {
        self.city = city
    }

    func done() {
        if let city = city {
            coordinator.back(data: .city(city))
        }
    }

    func close() {
        coordinator.back(data: nil)
    }

    // MARK: Search cityName
    /// Clean already existing search result
    /// Searching already existing city in local databas, on each new character
    /// Disable / Anable done button state
    /// - Parameter cityName: String that is input from search field
    /// - Returns : N/A
    func search(cityName: String) {
        delegate?.clean()

        guard !cityName.isEmpty else {
            delegate?.disableDoneButton(flag: true)
            return
        }

        select(city: City(name: cityName))

        delegate?.disableDoneButton(flag: false)

        citiesListProvider.fetch(city: cityName) { [weak self] result in
            switch result {
            case .success(let cities):
                self?.delegate?.update(cities: cities)
            case .failure(let error):
                self?.delegate?.show(error: error)
            }
        }
    }
}
