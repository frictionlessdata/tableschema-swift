@testable import TableSchema
import XCTest
import Foundation

class FieldForwardCastTests: XCTestCase {

    func testObjectValues() {
        let field = Field("object")
        field.type = .object

        // Happy (JSON Dictionary of [String: Any])
        let jsonDictionary = "{\"a\":1,\"b\":\"B\"}"
        let jsonDictionaryCast = field.cast(jsonDictionary) as! [String: Any]
        XCTAssertEqual(jsonDictionaryCast.count, 2)
        XCTAssertEqual(jsonDictionaryCast["a"] as! Int, 1)
        XCTAssertEqual(jsonDictionaryCast["b"] as! String, "B")
        XCTAssertTrue(field.test(jsonDictionary))

        // Happy (Empty JSON Dictionary)
        let jsonDictionaryEmpty = "{}"
        XCTAssertEqual((field.cast(jsonDictionaryEmpty) as! [String: Any]).count, 0)
        XCTAssertTrue(field.test(jsonDictionary))

        // Invalid (JSON Array of String)
        let jsonArray = "[\"a\",\"b\"]"
        XCTAssertNil(field.cast(jsonArray))
        XCTAssertFalse(field.test(jsonArray))

        // Invalid (JSON String)
        let jsonString = "\"a\""
        XCTAssertNil(field.cast(jsonString))
        XCTAssertFalse(field.test(jsonString))

        // Invalid (JSON null)
        let jsonNull = "null"
        XCTAssertNil(field.cast(jsonNull))
        XCTAssertFalse(field.test(jsonNull))

        // Invalid (JSON true)
        let jsonBool = "true"
        XCTAssertNil(field.cast(jsonBool))
        XCTAssertFalse(field.test(jsonBool))

        /// Invalid (String)
        let string = "a"
        XCTAssertNil(field.cast(string))
        XCTAssertFalse(field.test(string))
    }

    func testDateValues() {
        let field = Field("created")
        field.type = .date

        // Happy (ISO8601)
        var value = "2017-06-14"
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.year, .month, .day, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.year, 2017)
            XCTAssertEqual(dateComponents.month, 06)
            XCTAssertEqual(dateComponents.day, 14)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))
        } else {
            XCTAssertNil(field.cast(value))
            XCTAssertFalse(field.test(value))
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Invalid (Partial)
        value = "2017-06"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Invalid (Word)
        value = "Yesterday"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Any
        value = "2017-06-14"
        field.format = .any
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
    }

    func testTimeValues() {
        let field = Field("created")
        field.type = .time

        // Happy (ISO8601)
        var value = "21:19:18"
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.hour, .minute, .second, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.hour, 21)
            XCTAssertEqual(dateComponents.minute, 19)
            XCTAssertEqual(dateComponents.second, 18)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))
        } else {
            XCTAssertNil(field.cast(value))
            XCTAssertFalse(field.test(value))
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Invalid (Partial)
        value = "21:19"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Invalid (Word)
        value = "Yesterday"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Any
        value = "21:19:18"
        field.format = .any
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
    }

    func testYearValues() {
        let field = Field("created")
        field.type = .year

        // Happy (ISO8601)
        var value = "2017"
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.year, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.year, 2017)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))
        } else {
            XCTAssertNil(field.cast(value))
            XCTAssertFalse(field.test(value))
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Additional (Year Month)
        value = "2017-06"
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.year, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.year, 2017)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))
        } else {
            XCTAssertNil(field.cast(value))
            XCTAssertFalse(field.test(value))
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Partial Year
        value = "17"
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.year, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.year, 17)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))
        } else {
            XCTAssertNil(field.cast(value))
            XCTAssertFalse(field.test(value))
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Invalid (Word)
        value = "Two Thousand And Seventeen"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
    }

    func testYearMonthValues() {
        let field = Field("created")
        field.type = .yearMonth

        // Happy (ISO8601)
        var value = "2017-06"
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.year, .month, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.year, 2017)
            XCTAssertEqual(dateComponents.month, 06)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))
        } else {
            XCTAssertNil(field.cast(value))
            XCTAssertFalse(field.test(value))
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Additional (Year Month Day)
        value = "2017-06-14"
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.year, .month, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.year, 2017)
            XCTAssertEqual(dateComponents.month, 06)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))
        } else {
            XCTAssertNil(field.cast(value))
            XCTAssertFalse(field.test(value))
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Invalid (Year)
        value = "2017"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Invalid (Word)
        value = "Last Month"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
    }

    func testDurationValues() {
        let field = Field("length")
        field.type = .duration

        var value = "P1990Y1M1DT1H1M1S"
        #if os(iOS) || os(macOS)
        if let duration = field.cast(value) as? DateComponents {
            XCTAssertEqual(duration.year, 1990)
            XCTAssertEqual(duration.month, 1)
            XCTAssertEqual(duration.day, 1)
            XCTAssertEqual(duration.hour, 1)
            XCTAssertEqual(duration.minute, 1)
            XCTAssertEqual(duration.second, 1)
            XCTAssertTrue(field.test(value))
        } else {
            XCTFail()
            return
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Negative
        value = "-P1Y1M1DT1H1M1S"
        #if os(iOS) || os(macOS)
        if let duration = field.cast(value) as? DateComponents {
            XCTAssertEqual(duration.year, -1)
            XCTAssertEqual(duration.month, -1)
            XCTAssertEqual(duration.day, -1)
            XCTAssertEqual(duration.hour, -1)
            XCTAssertEqual(duration.minute, -1)
            XCTAssertEqual(duration.second, -1)
            XCTAssertTrue(field.test(value))
        } else {
            XCTFail()
            return
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Invalid (Negative Sign Placement)
        value = "P-1Y1M1DT1H1M1S"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Zero'd Designators
        value = "P1DT1S"
        #if os(iOS) || os(macOS)
        if let duration = field.cast(value) as? DateComponents {
            XCTAssertEqual(duration.day, 1)
            XCTAssertEqual(duration.second, 1)
            XCTAssertTrue(field.test(value))
        } else {
            XCTFail()
            return
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Missing Time
        value = "P1Y1M1D"
        #if os(iOS) || os(macOS)
        if let duration = field.cast(value) as? DateComponents {
            XCTAssertEqual(duration.year, 1)
            XCTAssertEqual(duration.month, 1)
            XCTAssertEqual(duration.day, 1)
            XCTAssertTrue(field.test(value))
        } else {
            XCTFail()
            return
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Missing Date
        value = "PT1H1M1S"
        #if os(iOS) || os(macOS)
        if let duration = field.cast(value) as? DateComponents {
            XCTAssertEqual(duration.hour, 1)
            XCTAssertEqual(duration.minute, 1)
            XCTAssertEqual(duration.second, 1)
            XCTAssertTrue(field.test(value))
        } else {
            XCTFail()
            return
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Invalid (Time Designator with Time)
        value = "P1Y1M1DT"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Invalid (Missing "P" Designator)
        value = "1Y1M1DT1H1M1S"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // No Numbered Designators
        value = "P"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Decimal Seconds
        value = "P1Y1M1DT1H1M1.125S"
        #if os(iOS) || os(macOS)
        if let duration = field.cast(value) as? DateComponents {
            XCTAssertEqual(duration.year, 1)
            XCTAssertEqual(duration.month, 1)
            XCTAssertEqual(duration.day, 1)
            XCTAssertEqual(duration.hour, 1)
            XCTAssertEqual(duration.minute, 1)
            XCTAssertEqual(duration.second, 1)
            XCTAssertEqual(duration.nanosecond, 125000000)
            XCTAssertTrue(field.test(value))
        } else {
            XCTFail()
            return
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Large Decimal Seconds
        value = "PT1.123456789987654321S"
        #if os(iOS) || os(macOS)
        if let duration = field.cast(value) as? DateComponents {
            XCTAssertEqual(duration.nanosecond, 123456789)
            XCTAssertTrue(field.test(value))
        } else {
            XCTFail()
            return
        }
        #else
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
        #endif

        // Invalid (Decimal Seconds without Decimals)
        value = "P1Y1M1DT1H1M1.S"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Empty (No Designators)
        value = ""
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
    }

    func testGeoPointValues() {
        let field = Field("point")
        field.type = .geoPoint

        // String
        field.format = .default
        var value = "90,45.0001"
        var results = field.cast(value)
        XCTAssertNotNil(results)
        XCTAssertTrue(field.test(value))
        if let (lon, lat) = results as? (Double, Double) {
            XCTAssertEqual(lon, 90.0)
            XCTAssertEqual(lat, 45.0001)
        }

        // String with whitespace
        value = "90 , 45.0001"
        results = field.cast(value)
        XCTAssertNotNil(results)
        XCTAssertTrue(field.test(value))
        if let (lon, lat) = results as? (Double, Double) {
            XCTAssertEqual(lon, 90.0)
            XCTAssertEqual(lat, 45.0001)
        }

        // Invalid (Bad Coordinates)
        value = "90,45.0001,73"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Invalid (Not Enough Coordinates)
        value = "90"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Array of Numbers
        field.format = .array
        value = "[90, 45.0001]"
        results = field.cast(value)
        XCTAssertNotNil(results)
        XCTAssertTrue(field.test(value))
        if let (lon, lat) = results as? (Double, Double) {
            XCTAssertEqual(lon, 90.0)
            XCTAssertEqual(lat, 45.0001)
        }

        // Array of Strings
        value = "[\"90\", \"45.0001\"]"
        results = field.cast(value)
        XCTAssertNotNil(results)
        XCTAssertTrue(field.test(value))
        if let (lon, lat) = results as? (Double, Double) {
            XCTAssertEqual(lon, 90.0)
            XCTAssertEqual(lat, 45.0001)
        }

        // Dictionary of Numbers
        field.format = .object
        value = "{\"lon\": 90, \"lat\": 45.0001}"
        results = field.cast(value)
        XCTAssertNotNil(results)
        XCTAssertTrue(field.test(value))
        if let (lon, lat) = results as? (Double, Double) {
            XCTAssertEqual(lon, 90.0)
            XCTAssertEqual(lat, 45.0001)
        }

        // Dictionary of Strings
        value = "{\"lon\": \"90\", \"lat\": \"45.0001\"}"
        results = field.cast(value)
        XCTAssertNotNil(results)
        XCTAssertTrue(field.test(value))
        if let (lon, lat) = results as? (Double, Double) {
            XCTAssertEqual(lon, 90.0)
            XCTAssertEqual(lat, 45.0001)
        }
    }

    static var allTests = [
        ("testObjectValues", testObjectValues),
        ("testDateValues", testDateValues),
        ("testTimeValues", testTimeValues),
        ("testYearValues", testYearValues),
        ("testYearMonthValues", testYearMonthValues),
        ("testDurationValues", testDurationValues),
        ("testGeographicPointValues", testGeoPointValues),
    ]

}
