import Foundation

protocol RootViewModelState {
    var dataProvider: DataProvider { get }
    var isCityButtonEnabled: Bool { get }
    var city: City? { get }
    func `switch`(stateContext: StateContext)
    func fetch(city: City, completion: @escaping CompletionDataType)
}

protocol StateContext: AnyObject {
    func set(state: RootViewModelState)
}

struct OnlineState: RootViewModelState {
    var city: City?
    var isCityButtonEnabled: Bool = true
    var dataProvider: DataProvider

    /// Switch state
    /// - Parameter stateContext: StateContext uses for switching from current state to Offline state with predefined city
    /// - Returns : N/A
    func `switch`(stateContext: StateContext) {
        stateContext.set(state: OfflineState())
    }

    /// Fetching online forecast
    /// - Parameter city: City - selected from cities list
    /// - Parameter completion: @escaping CompletionDataType is alias (Result<[Day], FetcherError>) -> Void uses for resalt callback
    /// - Returns: N/A
    func fetch(city: City, completion: @escaping CompletionDataType) {
        dataProvider.getData(city: city, completion: completion)
    }

    // MARK: Init
    /// Initialization OnlineState
    /// - Parameter city: City? = nil uses for switching from offline state and transfering default city
    /// - Parameter dataProvider: DataProvider  is initaliing with OnlineFetcher which is initialize with ForecastDecoder
    init(city: City? = nil, dataProvider: DataProvider = DataProvider(fetcher: OnlineFetcher(decoder: ForecastDecoder()))) {
        self.city = city
        self.dataProvider = dataProvider
    }
}

struct OfflineState: RootViewModelState {
    var city: City? = City(name: Consts.Offline.munich)
    var isCityButtonEnabled: Bool = false
    var dataProvider: DataProvider

    /// Switch state
    /// - Parameter stateContext: StateContext uses for switching from current state to Online state with predefined current offline city
    /// - Returns : N/A
    func `switch`(stateContext: StateContext) {
        stateContext.set(state: OnlineState(city: city))
    }

    /// Fetching online forecast
    /// - Parameter city: City - selected from cities list
    /// - Parameter completion: @escaping CompletionDataType is alias (Result<[Day], FetcherError>) -> Void uses for resalt callback
    /// - Returns: N/A
    func fetch(city: City, completion: @escaping CompletionDataType) {
        dataProvider.getData(city: city, completion: completion)
    }

    // MARK: Init
    /// Initialization Offline state
    /// - Parameter dataProvider: DataProvider uses for parsing forecast from Offline fetcher for file Munich()
    /// - Parameter file: Munich is Struct which is conferms  FileReading protocol conteins file name and file extension, for reading local file
    init(dataProvider: DataProvider = DataProvider(fetcher: OfflineFetcher(decoder: ForecastDecoder(), file: Munich()))) {
        self.dataProvider = dataProvider
    }
}
