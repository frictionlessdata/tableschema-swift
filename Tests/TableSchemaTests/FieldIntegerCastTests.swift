@testable import TableSchema
import XCTest
import Foundation

class FieldIntegerCastTests: XCTestCase {

    let field = Field("id", type: .integer)
    let clothedField = Field("id", type: .integer)

    override func setUp() {
        clothedField.bareNumber = false
    }

    func testBare() {
        // Happy (Bare Integer)
        let value = "10"
        XCTAssertEqual(field.cast(value) as? Int, 10)
        XCTAssertTrue(field.test(value))
        #if os(iOS) || os(macOS)
        XCTAssertEqual(clothedField.cast(value) as? Int, 10)
        XCTAssertTrue(clothedField.test(value))
        #endif

        XCTAssertEqual(field.reverseCast(10), value)
        XCTAssertTrue(field.reverseTest(10))

        // Invalid (Overflow)
        var overflow = String(Int.max) + "99"
        XCTAssertNil(field.cast(overflow))
        XCTAssertFalse(field.test(overflow))
        XCTAssertNil(clothedField.cast(overflow))
        XCTAssertFalse(clothedField.test(overflow))

        overflow = String(Int.min) + "99"
        XCTAssertNil(field.cast(overflow))
        XCTAssertFalse(field.test(overflow))
        XCTAssertNil(clothedField.cast(overflow))
        XCTAssertFalse(clothedField.test(overflow))

        // Invalid (String)
        let invalid = "asd"
        XCTAssertNil(field.cast(invalid))
        XCTAssertFalse(field.test(invalid))
        XCTAssertNil(clothedField.cast(invalid))
        XCTAssertFalse(clothedField.test(invalid))

        XCTAssertNil(field.reverseCast(invalid))
        XCTAssertFalse(field.reverseTest(invalid))
    }

    func testNonBare() {
        // Non-Bare Integer
        var clothed = "asd10asd"
        XCTAssertNil(field.cast(clothed))
        XCTAssertFalse(field.test(clothed))
        #if os(iOS) || os(macOS)
        XCTAssertEqual(clothedField.cast(clothed) as? Int, 10)
        XCTAssertTrue(clothedField.test(clothed))
        #endif

        XCTAssertEqual(clothedField.reverseCast(10), "10")
        XCTAssertTrue(clothedField.reverseTest(10))

        clothed = "10asd"
        #if os(iOS) || os(macOS)
        XCTAssertEqual(clothedField.cast(clothed) as? Int, 10)
        XCTAssertTrue(clothedField.test(clothed))
        #endif

        clothed = "asd10"
        #if os(iOS) || os(macOS)
        XCTAssertEqual(clothedField.cast(clothed) as? Int, 10)
        XCTAssertTrue(clothedField.test(clothed))
        #endif

        clothed = "asd10asd88"
        #if os(iOS) || os(macOS)
        XCTAssertEqual(clothedField.cast(clothed) as? Int, 10)
        XCTAssertTrue(clothedField.test(clothed))
        #endif
    }

    static var allTests = [
        ("testBare", testBare),
        ("testNonBare", testNonBare),
    ]

}
