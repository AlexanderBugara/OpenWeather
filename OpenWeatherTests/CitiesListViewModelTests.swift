import XCTest
@testable import OpenWeather

final class CitiesListViewModelTests: XCTestCase {

    private var citiesListViewModel: CitiesListViewModel!
    private var delegate: MockCitiesListViewModelDelegate!
    private var coordinator: MockCoordinator!

    override func setUp() {
        coordinator = MockCoordinator()
        citiesListViewModel = CitiesListViewModel(coordinator: coordinator)
        delegate = MockCitiesListViewModelDelegate()
        citiesListViewModel.delegate = delegate
    }

    func testCleanDidCall() {
        citiesListViewModel.search(cityName: Consts.Offline.munich)
        XCTAssertTrue(delegate.isCleanDidCall)
    }

    func testDisableDoneButtonCall() {
        citiesListViewModel.search(cityName: "")
        XCTAssertTrue(delegate.isDisableDoneButton)
        citiesListViewModel.search(cityName: Consts.Offline.munich)
        XCTAssertFalse(delegate.isDisableDoneButton)
    }

    func testCities() {
        citiesListViewModel.search(cityName: Consts.Offline.munich)
        guard let cities = delegate.cities else {
            XCTFail("cities array is nil")
            return
        }
        XCTAssertFalse(cities.isEmpty)
    }

    func testDoneAction() {
        citiesListViewModel.done()
        XCTAssertFalse(coordinator.isBack)
        citiesListViewModel.select(city: City(name: Consts.Offline.munich))
        citiesListViewModel.done()
        XCTAssertTrue(coordinator.isBack)
    }

    override func tearDown() {
        citiesListViewModel = nil
        delegate = nil
        coordinator = nil
    }
}

final class MockCitiesListViewModelDelegate: CitiesListViewModelDelegate {
    var isDisableDoneButton: Bool = false
    var isCleanDidCall: Bool = false
    var error: Error?
    var cities: [City]?

    func disableDoneButton(flag: Bool) {
        isDisableDoneButton = flag
    }

    func clean() {
        isCleanDidCall = true
    }

    func update(cities: [City]) {
        self.cities = cities
    }

    func show(error: Error) {
        self.error = error
    }
}
