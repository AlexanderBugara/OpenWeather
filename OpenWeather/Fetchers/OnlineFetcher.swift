import Foundation

struct OnlineFetcher<D: ForecastDecoding>: Fetcher {
    private let api: API
    private let decoder: D
    private let sessionManager: SessionManager

    init(api: API = WeatherAPI(), sessionManager: SessionManager = SessionManager.default, decoder: D) {
        self.api = api
        self.decoder = decoder
        self.sessionManager = sessionManager
    }

    func fetch(city: City, completetion: @escaping CompletionFetchType) {
        guard let url = api.apiComponents(city: city).url else {
            completetion(.failure(.URLWasNotBuild))
            return
        }

        sessionManager.startLoading(url: url) { result in
            switch result {
            case .success(let data):
                self.decoder.execute(data: data) { result in
                    DispatchQueue.main.async {
                        completetion(result)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    guard let error = error as? SessionError else {
                        return
                    }
                    completetion(.failure(.sessionError(error)))
                }
            }
        }
    }
}
