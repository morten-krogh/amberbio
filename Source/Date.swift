import Foundation

func date_from_sqlite_timestamp(timestamp timestamp: String) -> NSDate {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.timeZone = NSTimeZone(abbreviation: "GMT")
        return dateformatter.dateFromString(timestamp)!
}

func date_formatted_string(date date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(date)
}

func date_formatted_string(timestamp timestamp: String) -> String {
        return date_formatted_string(date: date_from_sqlite_timestamp(timestamp: timestamp))
}

func date_formatted_yyyy_string(date date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        return formatter.stringFromDate(date)
}