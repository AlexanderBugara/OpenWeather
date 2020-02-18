import XCTest
@testable import OpenWeather

final class RootViewNodelTests: XCTestCase {

    func testInitialOnlineState() {
        let coordinator = MockCoordinator()
        let onlineFetcher = OnlineFetcher(decoder: ForecastDecoder())
        let onlineDataProvider = DataProvider(fetcher: onlineFetcher)

        let rootViewModel = RootViewModel(coordinator: coordinator, state: MockStateOnline(dataProvider: onlineDataProvider))
        XCTAssertNotNil(rootViewModel.coordinator)
        XCTAssertNil(rootViewModel.delegate)
        XCTAssertFalse(rootViewModel.isLoading)
        XCTAssertFalse(rootViewModel.isWelcomeLabelHidden)
        XCTAssertNil(rootViewModel.city)
        XCTAssertNil(rootViewModel.error)
        XCTAssertTrue(rootViewModel.isCityButtonEnabled)
    }

    func testInitOfflineState() {
        let coordinator = MockCoordinator()
        let offlineFetcher = OfflineFetcher(decoder: ForecastDecoder(), file: Munich())
        let offlineDataProvider = DataProvider(fetcher: offlineFetcher)

        let rootViewModel = RootViewModel(coordinator: coordinator, state: MockStateOffline(dataProvider: offlineDataProvider))

        XCTAssertFalse(rootViewModel.isLoading)
        XCTAssertFalse(rootViewModel.isWelcomeLabelHidden)
        XCTAssertEqual(rootViewModel.city?.name, Consts.Offline.munich)
        XCTAssertNil(rootViewModel.error)
        XCTAssertFalse(rootViewModel.isCityButtonEnabled)
    }

    func testOnlineToOfflineState() {
        let coordinator = MockCoordinator()
        let rootViewModel = RootViewModel(coordinator: coordinator)

        rootViewModel.switchState()

        XCTAssertFalse(rootViewModel.isLoading)
        XCTAssertTrue(rootViewModel.isWelcomeLabelHidden)
        XCTAssertNotNil(rootViewModel.city)
        XCTAssertEqual(rootViewModel.city?.name, Consts.Offline.munich)
        XCTAssertNil(rootViewModel.error)
        XCTAssertFalse(rootViewModel.isCityButtonEnabled)
    }

    func testOfflineToOnlineState() {
        let coordinator = MockCoordinator()
        let offlineFetcher = OfflineFetcher(decoder: ForecastDecoder(), file: Munich())
        let offlineDataProvider = DataProvider(fetcher: offlineFetcher)

        let rootViewModel = RootViewModel(coordinator: coordinator, state: MockStateOffline(dataProvider: offlineDataProvider))

        rootViewModel.switchState()
        XCTAssertEqual(rootViewModel.state.city?.name, Consts.Offline.munich)
        XCTAssertNotNil(rootViewModel.coordinator)
        XCTAssertNil(rootViewModel.delegate)
        XCTAssertFalse(rootViewModel.isLoading)
        XCTAssertTrue(rootViewModel.isWelcomeLabelHidden)
        XCTAssertEqual(rootViewModel.city?.name, Consts.Offline.munich)
        XCTAssertNil(rootViewModel.error)
        XCTAssertTrue(rootViewModel.isCityButtonEnabled)
    }
}

struct MockStateOnline: RootViewModelState {
    var isCityButtonEnabled: Bool = true
    var city: City?
    var dataProvider: DataProvider

    func `switch`(stateContext: StateContext) {
        stateContext.set(state: MockStateOffline(dataProvider: DataProvider(fetcher: OfflineFetcher(decoder: ForecastDecoder(), file: Munich()))))
    }

    func fetch(city: City, completion: @escaping CompletionDataType) {
        completion(.success([]))
    }
}

struct MockStateOffline: RootViewModelState {
    var isCityButtonEnabled: Bool = false
    var city: City? = City(name: Consts.Offline.munich)
    var dataProvider: DataProvider

    func `switch`(stateContext: StateContext) {
        stateContext.set(state: MockStateOnline(city: city, dataProvider: DataProvider(fetcher: OnlineFetcher(api: WeatherAPI(), decoder: ForecastDecoder()))))
    }

    func fetch(city: City, completion: @escaping CompletionDataType) {
        completion(.success([]))
    }
}
