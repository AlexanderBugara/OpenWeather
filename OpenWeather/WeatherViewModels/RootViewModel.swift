import Foundation

typealias CellModel = RootViewModel.CellModel
typealias Item = ResponseServerModel.Item
typealias CompletionFetchType = (Result<[Item], FetcherError>) -> Void
typealias CompletionDataType = (Result<[Day], FetcherError>) -> Void

protocol RootViewModeling: AnyObject {
    func switchState()
    func fetch(city: City?)
    func presentCityPicker()
}

protocol RootViewModelDelegate: AnyObject {
    func forecastDidLoad(items: [Day])
    func welcomeLabel(isHidden: Bool)
    func loading(isPresented: Bool)
    func updateCityButton(city: City?)
    func show(error: FetcherError)
    func cityButton(isEnabled: Bool)
    var isCollectionEmpty: Bool { get }
}

final class RootViewModel {
    private(set) var state: RootViewModelState
    weak var coordinator: Coordinating?
    weak var delegate: RootViewModelDelegate?

    // MARK: UI Bindings
    var isLoading: Bool = false {
        didSet {
            delegate?.loading(isPresented: isLoading)
        }
    }
    var isWelcomeLabelHidden: Bool = false {
        didSet {
            delegate?.welcomeLabel(isHidden: isWelcomeLabelHidden)
        }
    }
    var error: FetcherError? {
        didSet {
            guard let error = error else {
                return
            }
            delegate?.show(error: error)
        }
    }
    var isCityButtonEnabled: Bool = true {
        didSet {
            delegate?.cityButton(isEnabled: isCityButtonEnabled)
        }
    }
    var city: City? {
        didSet {
            delegate?.updateCityButton(city: city)
        }
    }

    // MARK: Init
    /// Initialization RootViewModel
    /// - Parameter coordinator: uses for UI navigation to Cities list 
    /// - Parameter state: Initial state for online / offline mode default is Online state
    init(coordinator: Coordinating, state: RootViewModelState = OnlineState()) {
        self.state = state
        self.coordinator = coordinator
        self.city = state.city
        isCityButtonEnabled = state.isCityButtonEnabled
    }
}

extension RootViewModel: RootViewModeling {
    // MARK: RootViewModeling
    /// Switching RootViewModel state from online to offline and vice versa
    /// After switching state expected fetching forecast for current city if city was assigned
    /// - Warning : Default city for offline stae is Munich
    /// - Returns : N/A
    func switchState() {
        state.switch(stateContext: self)
        isCityButtonEnabled = state.isCityButtonEnabled
        city = state.city
        fetch(city: state.city)
    }

    // MARK: Fetch
    /// Fetching forecast for requested city
    ///- Parameter city: City? It is optional because Online state before city selection is nil but after switching from offline state Online automatically assigns default Offline mode state
    /// - Returns : N/A
    func fetch(city: City?) {
        guard let city = city else {
            return
        }
        isWelcomeLabelHidden = true
        isLoading = true
        state.fetch(city: city) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let cellsModels):
                self?.delegate?.forecastDidLoad(items: cellsModels)
                self?.city = city
            case .failure(let error):
                if let isEmpty = self?.delegate?.isCollectionEmpty, isEmpty == true {
                    self?.isWelcomeLabelHidden = false
                }
                self?.error = error
            }
        }
    }

    // MARK: Present cities list modal view controller
    func presentCityPicker() {
        coordinator?.next()
    }
}

extension RootViewModel {
    struct CellModel: Hashable {
       // the temperature, time, date and weather icon
        var temperature: Double
        var time: String
        var date: String
        var iconName: String?
        var dayIndex: Int

        var temperatureCelsiumString: String {
            let celsius = UnitTemperature.celsius
            let measurement = Measurement(value: round(temperature), unit: celsius)
            let formatter = MeasurementFormatter()
            formatter.locale = Locale(identifier: Consts.kUnitCelsiusLocale)
            return formatter.string(from: measurement)
        }
    }
}

extension RootViewModel: StateContext {

    // MARK: StateContext switching
    /// StateContext switching,  this is part of implementation standart switching state design pattern
    /// - Parameter state: online / offline state that is conformes to RootViewModelState protocol
    /// - Returns : N/A

    func set(state: RootViewModelState) {
        self.state = state
    }
}
