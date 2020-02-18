import Foundation

enum FetcherError: Error {
    case URLWasNotBuild
    case decoderError
    case sessionError(SessionError)
}

protocol Fetcher {
    func fetch(city: City, completetion: @escaping CompletionFetchType)
}
