import XCTest
@testable import OpenWeather

struct ForecastVerifier {
    var items: [Item]

    func check() {
        XCTAssertEqual(items.count, 40)
        guard let first = items.first else {
            XCTFail("first is nil")
            return
        }
        XCTAssertEqual(first.dt, 1582167600.0)
        XCTAssertEqual(first.main.temp, 0.1)
        XCTAssertEqual(first.weather.first?.icon ?? "", "04n")

        guard let last = items.last else {
            XCTFail("last is nil")
            return
        }

        XCTAssertEqual(last.dt, 1582588800.0)
        XCTAssertEqual(last.main.temp, 4.29)
        XCTAssertEqual(last.weather.first?.icon ?? "", "04n")
        return 
    }
}
