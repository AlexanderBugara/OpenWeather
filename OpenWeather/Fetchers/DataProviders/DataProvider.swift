import Foundation

struct DataProvider {
    private let dateTimeUtil = DateTimeUtil()
    var fetcher: Fetcher
    private func convert(result: Result<[ResponseServerModel.Item], FetcherError>) -> Result<[Day], FetcherError> {
        var sections = [Day]()
        let items: [Item]

        switch result {
        case .success(let responseItems): items = responseItems
        case .failure(let error): return .failure(error)
        }

        items.iterate(dateTimeUtil: dateTimeUtil) { item, dayIndex in
            var iconName: String?
            if let weather = item.weather.first { iconName = weather.icon }
            let dateString = dateTimeUtil.localDateString(timeInterval: item.dt)
            let timeString = dateTimeUtil.localTimeString(timeInterval: item.dt)
            let cellModel = CellModel(temperature: item.main.temp, time: timeString, date: dateString, iconName: iconName, dayIndex: dayIndex)

            if sections.count <= dayIndex {
                for _ in sections.count...dayIndex {
                    sections.append(Day())
                }
            }
            sections[dayIndex].append(cellModel)
        }
        return .success(sections)
    }

    func getData(city: City, completion: @escaping CompletionDataType) {
        fetcher.fetch(city: city) { result in
            completion(convert(result: result))
        }
    }
}

// MARK: Custom iterator with day index

private extension Sequence {
    func iterate(dateTimeUtil: DateTimeUtil,
        _ nextPartialResult: (_ element: Item, _ dateIndex: Int) -> Void
    ) -> Void
    {
        var i = makeIterator()
        guard let item = i.next() as? Item else { return }

        var index: Int = 0
        nextPartialResult(item, index)

        guard var oldDay = Date(timeIntervalSince1970: item.dt).day else { return }
        while let element = i.next() as? Item {
            if let newDay = Date(timeIntervalSince1970: element.dt).day, newDay != oldDay {
                index += 1
                oldDay = newDay
            }
            nextPartialResult(element, index)
        }
    }
}
