import XCTest
@testable import OpenWeather

final class CityListCoordinatorTests: XCTestCase {
    private var listCoordinator: ListControllerCoordinator!
    private var citiesListBuilder: MockCitiesListBuilder!
    override func setUp() {
        citiesListBuilder = MockCitiesListBuilder()
        listCoordinator = ListControllerCoordinator(citiesListBuilder: citiesListBuilder, navigationController: nil)
    }

    override func tearDown() {
        citiesListBuilder = nil
        listCoordinator = nil
    }

    func testSetup() {
        listCoordinator.setup()
        XCTAssertTrue(citiesListBuilder.makeDidCall)
    }

    func testBack() {
        let mockCoordinator = MockCoordinator()
        listCoordinator.previousCoordinator = mockCoordinator
        listCoordinator.back(data: .city(City(name: Consts.Offline.munich)))

        guard let transferedData = mockCoordinator.data else {
            XCTFail("TransferedData is nil")
            return
        }
        switch transferedData {
        case .city(let city):
            XCTAssertTrue(mockCoordinator.isBack)
            XCTAssertEqual(city, City(name: Consts.Offline.munich))
            break
        }
    }
}

final class MockCitiesListBuilder: CitiesListBuilding {
    var makeDidCall: Bool = false
    func make(coordinator: ListControllerCoordinator, completion: @escaping (UINavigationController) -> Void) {
        makeDidCall = true
    }
}
