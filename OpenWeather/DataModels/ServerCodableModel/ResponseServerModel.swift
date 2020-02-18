import Foundation

struct ResponseServerModel: Decodable {
    var list: [Item]
    private enum CodingKeys: String, CodingKey {
        case list
    }
}

extension ResponseServerModel {
    struct Item: Decodable {
        var dt: Double
        var main: Main
        var weather: [Weather]

        private enum CodingKeys: String, CodingKey {
            case weather
            case dt
            case main
        }
    }
}

extension ResponseServerModel.Item {
    struct Main: Decodable {
        var temp: Double

        private enum CodingKeys: String, CodingKey {
            case temp
        }
    }
}

extension ResponseServerModel.Item {
    struct Weather: Decodable {
        var icon: String
        private enum CodingKeys: String, CodingKey {
            case icon
        }
    }
}
