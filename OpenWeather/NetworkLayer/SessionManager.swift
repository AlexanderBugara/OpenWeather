import Foundation

protocol CustomError: LocalizedError {

    var title: String? { get }
    var code: Int { get }
}

struct SessionError: CustomError {

    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }

    private var _description: String

    init(title: String?, description: String, code: Int) {
        self.title = title ?? Consts.Error
        self._description = description
        self.code = code
    }
}

protocol SessionManaging {
    func startLoading(url: URL, method: HTTPMethod, completion: @escaping (Swift.Result<Data, Error>) -> Void)
}

final class SessionManager {
    static let `default`: SessionManager = SessionManager()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension SessionManager: SessionManaging {
    func startLoading(url: URL, method: HTTPMethod = .get, completion: @escaping (Swift.Result<Data, Error>) -> Void) {

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) == false {

                let error: SessionError = SessionError(title: NSLocalizedString(Consts.Error, comment: ""), description: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), code:  httpResponse.statusCode)
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, let mimeType = httpResponse.mimeType, mimeType == "application/json",
                let data = data {
                completion(.success(data))
            }
        }
        task.resume()
    }
}
