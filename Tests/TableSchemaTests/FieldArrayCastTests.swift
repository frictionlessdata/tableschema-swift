@testable import TableSchema
import XCTest
import Foundation

class FieldArrayCastTests: XCTestCase {

    let field = Field("array")

    override func setUp() {
        field.type = .array
    }

    func testInvalid() {
        // Invalid (JSON Dictionary of [String: Any])
        let jsonDictionary = "{\"a\":1,\"b\":\"B\"}"
        XCTAssertNil(field.cast(jsonDictionary))
        XCTAssertFalse(field.test(jsonDictionary))

        let dictionary = ["a" : 1, "b" : 2]
        XCTAssertNil(field.reverseCast(dictionary))
        XCTAssertFalse(field.reverseTest(dictionary))

        // Invalid (String)
        let string = "a"
        XCTAssertNil(field.cast(string))
        XCTAssertFalse(field.test(string))

        XCTAssertNil(field.reverseCast(string))
        XCTAssertFalse(field.reverseTest(string))
    }

    func testJSON() {
        // Happy (JSON Array of String)
        let jsonArray = "[\"a\",\"b\"]"
        let jsonArrayCast = field.cast(jsonArray) as! [String]
        let array = ["a", "b"]
        XCTAssertEqual(jsonArrayCast.count, array.count)
        XCTAssertEqual(jsonArrayCast[0], array[0])
        XCTAssertEqual(jsonArrayCast[1], array[1])
        XCTAssertTrue(field.test(jsonArray))

        XCTAssertEqual(field.reverseCast(array), jsonArray)
        XCTAssertTrue(field.reverseTest(array))

        // Happy (JSON Array of Any)
        let jsonArrayAny = "[\"a\",1]"
        let jsonArrayAnyCast = field.cast(jsonArrayAny) as! [Any]
        let arrayAny: [Any] = ["a", 1]
        XCTAssertEqual(jsonArrayAnyCast.count, arrayAny.count)
        XCTAssertEqual(jsonArrayAnyCast[0] as! String, arrayAny[0] as! String)
        XCTAssertEqual(jsonArrayAnyCast[1] as! Int, arrayAny[1] as! Int)
        XCTAssertTrue(field.test(jsonArrayAny))

        XCTAssertEqual(field.reverseCast(arrayAny), jsonArrayAny)
        XCTAssertTrue(field.reverseTest(arrayAny))
    }

    static var allTests = [
        ("testInvalid", testInvalid),
        ("testJSON", testJSON),
    ]

}
