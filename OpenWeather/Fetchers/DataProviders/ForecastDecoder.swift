import Foundation

protocol ForecastDecoding {
    func execute(data: Data?, completion: (Result<[Item], FetcherError>) -> Void)
}

struct ForecastDecoder: ForecastDecoding {
    let decoder = JSONDecoder()
    func execute(data: Data?, completion: (Result<[Item], FetcherError>) -> Void) {
        guard let data = data else {
            completion(.failure(.decoderError))
            return }
        do {
            let response = try decoder.decode(ResponseServerModel.self, from: data)
            completion(.success(response.list))
        } catch {
            guard let error = error as? FetcherError else {
                completion(.failure(.decoderError))
                return
            }
            completion(.failure(error))
        }
    }
}
