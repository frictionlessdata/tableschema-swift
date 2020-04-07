@testable import TableSchema
import XCTest
import Foundation

class FieldStringCastTests: XCTestCase {

    let field = Field("name")
    let firstName = "Simon"

    override func setUp() {
        XCTAssertEqual(field.type, Field.FieldType.string)
    }

    func testBinary() {
        // Base64 Encoded
        field.format = .binary
        let base64Encoded = "U2ltb24="
        XCTAssertEqual(field.cast(base64Encoded) as! String, firstName)
        XCTAssertTrue(field.test(base64Encoded))

        XCTAssertEqual(field.reverseCast(firstName), base64Encoded)
        XCTAssertTrue(field.reverseTest(firstName))

        // Base64 Encoded string without encoding format
        field.format = .default
        XCTAssertEqual(field.cast(base64Encoded) as! String, base64Encoded)
        XCTAssertTrue(field.test(base64Encoded))

        XCTAssertEqual(field.reverseCast(firstName), firstName)
        XCTAssertTrue(field.reverseTest(firstName))
    }

    func testDefault() {
        field.format = .default

        XCTAssertEqual(field.cast(firstName) as! String, firstName)
        XCTAssertTrue(field.test(firstName))

        XCTAssertEqual(field.reverseCast(firstName), firstName)
        XCTAssertTrue(field.reverseTest(firstName))
    }

    func testEmail() {
        field.format = .email

        let email = "name@example.com"
        XCTAssertNil(field.cast(email))
        XCTAssertFalse(field.test(email))

        XCTAssertNil(field.reverseCast(email))
        XCTAssertFalse(field.reverseTest(email))
    }

    func testURI() {
        field.format = .uri

        // Remote
        let remote = "http://example.com"
        XCTAssertEqual((field.cast(remote) as! URL).absoluteString, remote)
        XCTAssertTrue(field.test(remote))

        let remoteURL = URL(string: remote)!
        XCTAssertEqual(field.reverseCast(remoteURL), remote)
        XCTAssertTrue(field.reverseTest(remoteURL))

        // Local
        let local = "./file.txt"
        XCTAssertEqual((field.cast(local) as! URL).absoluteString, local)
        XCTAssertTrue(field.test(local))

        let localURL = URL(string: local)!
        XCTAssertEqual(field.reverseCast(localURL), local)
        XCTAssertTrue(field.reverseTest(localURL))

        // Invalid
        let invalidURI = "\"invalid\""
        XCTAssertNil(field.cast(invalidURI))
        XCTAssertFalse(field.test(invalidURI))

        XCTAssertNil(field.reverseCast(nil))
        XCTAssertTrue(field.reverseTest(nil))
    }

    func testUUID() {
        field.format = .uuid

        // Uppercase UUID
        let uppercase = "1AD5EEE4-ECA7-466C-A129-0FC0E406ECAE"
        XCTAssertEqual(field.cast(uppercase) as! String, uppercase)
        XCTAssertTrue(field.test(uppercase))

        let uuid = UUID(uuidString: uppercase)
        XCTAssertEqual(field.reverseCast(uuid), uppercase)
        XCTAssertTrue(field.reverseTest(uuid))

        // Lowercase UUID
        let lowercase = "1ad5eee4-eca7-466c-a129-0fc0e406ecae"
        XCTAssertEqual(field.cast(lowercase) as! String, uppercase)
        XCTAssertTrue(field.test(lowercase))

        XCTAssertEqual(field.reverseCast(uuid), uppercase)
        XCTAssertTrue(field.reverseTest(uuid))

        // Invalid UUID
        let invalid = "1AD5EEE4ECA7466CA1290FC0E406ECAE"
        XCTAssertNil(field.cast(invalid))
        XCTAssertFalse(field.test(invalid))

        XCTAssertNil(field.reverseCast(nil))
        XCTAssertTrue(field.reverseTest(nil))
    }

    static var allTests = [
        ("testBinary", testBinary),
        ("testDefault", testDefault),
        ("testEmail", testEmail),
        ("testURI", testURI),
        ("testUUID", testUUID),
    ]

}
