import Foundation

//MARK: Base API

protocol API {
    func apiComponents(city: City) -> URLComponents
    var host: String { get }
    var schema: String { get }
    var queryItems: [URLQueryItem] { get }
}

protocol Resource {
    var queryItems: [URLQueryItem] { get }
    var path: String { get }
}

extension API {
    func apiComponents(city: City) -> URLComponents {
        var components = URLComponents()
        components.scheme = schema
        components.host = host
        components.path = Consts.Network.forecastPath

        let queries = city.id == nil ? [URLQueryItem(name:Consts.Network.q, value: city.name)] : [URLQueryItem(name:Consts.Network.id, value: city.id)]

        components.queryItems = queryItems + queries
        return components
    }
}

struct WeatherAPI: API {
    var host = Consts.Network.host
    var schema = Consts.Network.schema
    var queryItems = Consts.Network.queryItems
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
}
