import XCTest
@testable import OpenWeather

final class OnlineFetchingTests: XCTestCase {
    private var session: URLSessionMock!
    private var forecastDecoder: ForecastDecoder!
    private var sessionManager: SessionManager!
    private var manager: OnlineFetcher<ForecastDecoder>!

    override func setUp() {
        session = URLSessionMock()
        forecastDecoder = ForecastDecoder()
        sessionManager = SessionManager(session: session)
        manager = OnlineFetcher(sessionManager: sessionManager, decoder: forecastDecoder)
    }

    override func tearDown() {
        session = nil
        forecastDecoder = nil
        sessionManager = nil
        manager = nil
    }

    func testSuccessfulResponse() {
        session.data = Munich().data
        manager.fetch(city: City(name: Consts.Offline.munich)) { result in
            switch result {
            case .success(let items):
                let verifier = ForecastVerifier(items: items)
                verifier.check()
            case .failure(_): break
            }
        }
    }

    func testFailureDecodingResponse() {
        let data = Data([0, 1, 0, 1])
        session.data = data
        manager.fetch(city: City(name: Consts.Offline.munich)) { result in
            switch result {
            case .success(_): XCTFail("Expected failure")
            case .failure(let error):
                switch error {
                case .decoderError: break
                default:
                    XCTFail("Expected decoded error")
                }
            }
        }
    }
}


final class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    override func resume() {
        closure()
    }
}

final class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    var data: Data?
    var error: Error?

    override func dataTask(with request: URLRequest,
                           completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        return URLSessionDataTaskMock {
            guard let url = URL(string: "http://google.com") else {
                completionHandler(data, nil, error)
                return
            }
            let mockResponse = MockHttpResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(data, mockResponse, error)
        }
    }

    override func dataTask(
        with url: URL,
        completionHandler: @escaping CompletionHandler
    ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        return URLSessionDataTaskMock {
            guard let url = URL(string: "http://google.com") else {
                completionHandler(data, nil, error)
                return
            }
            let mockResponse = MockHttpResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(data, mockResponse, error)
        }
    }
}

final class MockHttpResponse: HTTPURLResponse {
    override var mimeType: String? {
        "application/json"
    }
}
