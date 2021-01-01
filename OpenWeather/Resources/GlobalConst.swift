import Foundation

enum Consts {
    struct Network {
        static let host = "api.openweathermap.org"
        static let schema = "http"
        static let queryItems = [URLQueryItem(name: "units", value: "metric"), URLQueryItem(name:"appid", value:"53a10d2de5e621321e059e4f4a4ef0f2")]
        static let forecastPath = "/data/2.5/forecast"
        static let q = "q"
        static let id = "id"
    }
    struct UserDefaults {
        static let kSavedOnlineCityName: String = "saved.online.city.name"
    }

    struct Offline {
        static let munich = "Munich"
        static let json = "json"
    }

    struct Alert {
        static let Ok = "Ok"
        static let URLErrorMessage = "Request could not send. Bad URL"
        static let decoderErrorMessage = "Data decoding error. Please repeat later."
    }
    static let kCitiesPage = 50
    static let Error = "Error"
    // localization keys

    static let kSelectYourCity = "Select / Enter Your City"
    static let kOnline = "Online"
    static let kOffline = "Offline"
    static let kCity = "City"
    static let kUnitCelsiusLocale = "fr-FR"
}
