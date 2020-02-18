import Foundation

struct DateTimeUtil {
    let timezoneOffset =  TimeZone.current.secondsFromGMT()
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()

    let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        timeFormatter.timeZone = TimeZone.current
        return timeFormatter
    }()

    func localDateString(timeInterval: Double) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
    }

    func localTimeString(timeInterval: Double) -> String {
        return timeFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
    }
}

extension Date {
    var day: Int? {
        Calendar.current.dateComponents([.day], from: self).day
    }
}
