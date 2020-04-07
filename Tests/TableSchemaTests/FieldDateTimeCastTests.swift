@testable import TableSchema
import XCTest
import Foundation

class FieldDateTimeCastTests: XCTestCase {

    let field = Field("created")

    override func setUp() {
        field.type = .dateTime
    }

    func testAny() {
        field.format = .any

        // Any
        let value = "2017-06-14T21:19:18Z"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        let date = Date()
        XCTAssertNil(field.reverseCast(date))
        XCTAssertFalse(field.reverseTest(date))
    }

    func testInvalid() {
        field.format = .default

        // Invalid (Partial)
        var value = "2017-06-14"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))

        // Invalid (Word)
        value = "Yesterday"
        XCTAssertNil(field.cast(value))
        XCTAssertFalse(field.test(value))
    }

    func testISO8601() {
        field.format = .default

        // Happy (ISO8601)
        let value = "2017-06-14T21:19:18Z"
        let unsupportedTests = {
            XCTAssertNil(self.field.cast(value))
            XCTAssertFalse(self.field.test(value))

            let date = Date()
            XCTAssertNil(self.field.reverseCast(date))
            XCTAssertFalse(self.field.reverseTest(date))
        }
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            guard let date = field.cast(value) as? Date else {
                XCTFail()
                return
            }
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let calendarComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .timeZone]
            let dateComponents = calendar.dateComponents(calendarComponents, from: date)
            XCTAssertEqual(dateComponents.year, 2017)
            XCTAssertEqual(dateComponents.month, 06)
            XCTAssertEqual(dateComponents.day, 14)
            XCTAssertEqual(dateComponents.hour, 21)
            XCTAssertEqual(dateComponents.minute, 19)
            XCTAssertEqual(dateComponents.second, 18)
            XCTAssertEqual(dateComponents.timeZone?.identifier, calendar.timeZone.identifier)
            XCTAssertTrue(field.test(value))

            XCTAssertEqual(field.reverseCast(date), value)
            XCTAssertTrue(field.reverseTest(date))
        } else {
            unsupportedTests()
        }
        #else
        unsupportedTests()
        #endif
    }

    static var allTests = [
        ("testAny", testAny),
        ("testInvalid", testInvalid),
        ("testISO8601", testISO8601),
    ]

}
