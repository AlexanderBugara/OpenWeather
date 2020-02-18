import Foundation
import SQLite3

typealias CompletionHandler = (Result<[City], Error>) -> Void

protocol CitiesListProviding {
    func fetch(city name: String, completetion: @escaping CompletionHandler)
}

struct CitiesDataProvider: CitiesListProviding {
    func fetch(city name: String, completetion: @escaping CompletionHandler) {

        guard let fileURL = Bundle.main.url(forResource: "cities", withExtension: "db") else { return }

        // open database

        var db: OpaquePointer?
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("error opening database")
            sqlite3_close(db)
            db = nil
            return
        }

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, "select distinct id, name, country from City where name like \'\(name)%\' ORDER BY name limit \(Consts.kCitiesPage)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }

        var cities = [City]()

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            if let cityNameCString = sqlite3_column_text(statement, 1),
                let countryNameCString = sqlite3_column_text(statement, 2)  {
                let cityName = String(cString: cityNameCString)
                let countryName = String(cString: countryNameCString)
                let city = City(name: cityName, country: countryName, id: String(id))
                cities.append(city)
            }
        }
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        statement = nil

        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }

        db = nil

        completetion(.success(cities))
    }
}
