import XCTest
@testable import OpenWeather

final class RootCoordinatorTests: XCTestCase {

    private var coordinator: RootControllerCoordinator!
    private var rootBuilder: MockRootControllerBuilder!
    private var rootViewModel: MockRootViewModel!

    override func setUp() {
        rootBuilder = MockRootControllerBuilder()
        coordinator = RootControllerCoordinator(window: nil, rootBuilder: rootBuilder)
        rootViewModel = MockRootViewModel()
        coordinator.rootViewModel = rootViewModel
    }

    override func tearDown() {
        coordinator = nil
        rootBuilder = nil
        rootViewModel = nil
    }

    func testSetup() {
        coordinator.setup()
        XCTAssertTrue(rootBuilder.didMakeCall)
    }

    func testBack() {
        coordinator.update(data: nil)
        XCTAssertFalse(rootViewModel.fetchCityDidCall)
        coordinator.update(data: .city(City(name: Consts.Offline.munich)))
        XCTAssertTrue(rootViewModel.fetchCityDidCall)
    }

    func testNext() {
        coordinator.next()
        XCTAssertNotNil(coordinator.nextCoordinator)
    }
}

final class MockRootControllerBuilder: RootViewControllerBuilding {
    var didMakeCall: Bool = false

    func make(coordinator: RootCoordinating, completion: @escaping (UINavigationController) -> Void) {
        didMakeCall = true
    }
}

final class MockRootViewModel: RootViewModeling {

    var fetchCityDidCall: Bool = false

    func switchState() {

    }

    func fetch(city: City?) {
        fetchCityDidCall = true
    }

    func presentCityPicker() {

    }

    func update() {

    }
}


