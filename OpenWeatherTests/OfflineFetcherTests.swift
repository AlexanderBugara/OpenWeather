//
//  OfflineFetcherTests.swift
//  OpenWeatherTests
//
import XCTest
@testable import OpenWeather

final class OfflineFetcherTests: XCTestCase {
    func testDecoderWasCall() {
        let decoder = MockDecoder()
        let offlineFetcher = OfflineFetcher(decoder: decoder, file: Munich())
        offlineFetcher.fetch(city: City(name: Consts.Offline.munich)) { result in
            XCTAssertTrue(decoder.didExecuteCall)
        }
    }

    func testFetchedData() {
        let decoder = ForecastDecoder()
        let offlineFetcher = OfflineFetcher(decoder: decoder, file: Munich())
        offlineFetcher.fetch(city: City(name: Consts.Offline.munich)) { result in
            switch result {
            case .success(let items):
                let verifier = ForecastVerifier(items: items)
                verifier.check()
            case .failure(_): break
            }
        }
    }
}

final class MockDecoder: ForecastDecoding {
    var didExecuteCall: Bool = false
    func execute(data: Data?, completion: (Result<[Item], FetcherError>) -> Void) {
        didExecuteCall = true
    }
}
