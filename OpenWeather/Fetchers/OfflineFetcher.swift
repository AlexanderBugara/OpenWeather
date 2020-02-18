import Foundation

struct OfflineFetcher: Fetcher {
    private let decoder: ForecastDecoding
    private let file: FileReading

    init(decoder: ForecastDecoding, file: FileReading) {
        self.decoder = decoder
        self.file = file
    }

    func fetch(city: City, completetion: @escaping CompletionFetchType) {
        decoder.execute(data: file.data) { result in
            completetion(result)
        }
    }
}

protocol FileReading  {
    var cityNameFile: String { get }
    var fileType: String { get }
}

extension FileReading {
    var data: Data? {
        guard let urlPath = Bundle.main.url(forResource: cityNameFile, withExtension: fileType) else {
            return nil
        }

        do {
            let data: Data = try Data(contentsOf: urlPath)
            return data
        } catch {
            return nil
        }
    }
}

struct Munich: FileReading {
    var cityNameFile = Consts.Offline.munich
    var fileType = Consts.Offline.json
}
