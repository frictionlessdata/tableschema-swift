@testable import TableSchema
import XCTest
import Foundation

class FieldBooleanCastTests: XCTestCase {

    var field = Field("valid")
    let firstName = "Simon"

    override func setUp() {
        field.type = .boolean
    }

    func testBoolean() {
        // Happy true
        var value = "true"
        XCTAssertTrue(field.cast(value) as! Bool)
        XCTAssertTrue(field.test(value))

        let trueValues = Set<String>(field.trueValues)
        guard let trueValue = field.reverseCast(true) else {
            XCTFail()
            return
        }
        XCTAssertTrue(trueValues.contains(trueValue))
        XCTAssertTrue(field.reverseTest(true))

        // Happy false
        value = "false"
        XCTAssertFalse(field.cast(value) as! Bool)
        XCTAssertTrue(field.test(value))

        let falseValues = Set<String>(field.falseValues)
        guard let falseValue = field.reverseCast(false) else {
            XCTFail()
            return
        }
        XCTAssertTrue(falseValues.contains(falseValue))
        XCTAssertTrue(field.reverseTest(false))

        // trueValues (1)
        var string = "True"
        XCTAssertTrue(field.cast(string) as! Bool)
        XCTAssertTrue(field.test(string))

        // trueValues (2)
        string = "tRue"
        XCTAssertNil(field.cast(string))
        XCTAssertFalse(field.test(string))

        // falseValues (1)
        string = "0"
        XCTAssertFalse(field.cast(string) as! Bool)
        XCTAssertTrue(field.test(string))

        // Invalid
        let invalid = "asd"
        XCTAssertNil(field.cast(invalid))
        XCTAssertFalse(field.test(invalid))

        XCTAssertNil(field.reverseCast(invalid))
        XCTAssertFalse(field.reverseTest(invalid))
    }

    func testMissingValues() {
        // Missing true/false values
        let voidField = Field("void")
        voidField.type = .boolean
        voidField.trueValues = [String]()
        voidField.falseValues = [String]()

        var value = true
        XCTAssertNil(voidField.cast(String(value)))
        XCTAssertFalse(voidField.test(String(value)))

        XCTAssertNil(voidField.reverseCast(value))
        XCTAssertFalse(voidField.reverseTest(value))

        value = false
        XCTAssertNil(voidField.cast(String(value)))
        XCTAssertFalse(voidField.test(String(value)))

        XCTAssertNil(voidField.reverseCast(value))
        XCTAssertFalse(voidField.reverseTest(value))
    }

    static var allTests = [
        ("testBoolean", testBoolean),
        ("testMissingValues", testMissingValues),
    ]

}
