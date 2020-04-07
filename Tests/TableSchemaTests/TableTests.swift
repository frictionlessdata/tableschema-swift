@testable import TableSchema
import XCTest

class TableTests: XCTestCase {

    func testBadCast() {
        let header = ["id", "first"]
        let rows = [["12", "Simon"]]
        let provider = MockTableProvider(header: header, rows: rows)
        let schema = Schema([Field("id", type: .boolean), Field("first")])
        let table = Table(provider: AnyTableProvider(provider), schema: schema)
        let castedRows = table.map { $0 }
        XCTAssertEqual(castedRows.count, 1)
        XCTAssertEqual(castedRows[0].count, 2)
        XCTAssertNil(castedRows[0][0])
        XCTAssertEqual(castedRows[0][1] as? String, rows[0][1])
    }

    func testDuplicateCaseInsensitiveFields() {
        let firstName = Field("first")
        let isFirst = Field("First")
        isFirst.type = .boolean
        let header = [firstName.name, isFirst.name]
        let rows = [["River", "true"]]
        let provider = MockTableProvider(header: header, rows: rows)
        let schema = Schema([firstName, isFirst])
        let table = Table(provider: AnyTableProvider(provider), schema: schema)
        let castedRows = table.map { $0 }
        XCTAssertEqual(castedRows.count, 1)
        XCTAssertEqual(castedRows[0].count, 2)
        XCTAssertEqual(castedRows[0][0] as? String, rows[0][0])
        // Note: Case insensitive duplicates are cast using the first field
        XCTAssertNotNil(castedRows[0][1])
        XCTAssertEqual(castedRows[0][1] as? String, rows[0][1])
    }

    func testDuplicateCaseSensitiveFields() {
        let firstName = Field("first")
        let isFirst = Field("first")
        isFirst.type = .boolean
        let header = [firstName.name, isFirst.name]
        let rows = [["River", "true"]]
        let provider = MockTableProvider(header: header, rows: rows)
        let schema = Schema([firstName, isFirst])
        let table = Table(provider: AnyTableProvider(provider), schema: schema)
        let castedRows = table.map { $0 }
        XCTAssertEqual(castedRows.count, 1)
        XCTAssertEqual(castedRows[0].count, 2)
        XCTAssertEqual(castedRows[0][0] as? String, rows[0][0])
        // Note: Duplicates are cast using the first field
        XCTAssertNotNil(castedRows[0][1])
        XCTAssertEqual(castedRows[0][1] as? String, rows[0][1])
    }

    func testMisorderedFields() {
        // Note: This is an exercise left to the user of this library
    }

    func testMissingSchema() {
        let header = ["id", "first", "last"]
        let rows = [["1", "Malcom", "Reynolds"]]
        let provider = MockTableProvider(header: header, rows: rows)
        let table = Table(provider: AnyTableProvider(provider))
        let rawRows = table.map { $0 }
        XCTAssertEqual(rawRows.count, 1)
        XCTAssertEqual(rawRows[0].count, 3)
        XCTAssertEqual(rawRows[0][0] as? String, rows[0][0])
        XCTAssertEqual(rawRows[0][1] as? String, rows[0][1])
        XCTAssertEqual(rawRows[0][2] as? String, rows[0][2])
    }

    func testMissingHeader() {
        let header = ["id", "first", "last"]
        let rows = [["1", "Malcom", "Reynolds"]]
        let provider = MockTableProvider(header: nil, rows: rows)
        let schema = Schema(header.map { Field($0) })
        let table = Table(provider: AnyTableProvider(provider), schema: schema)
        let rawRows = table.map { $0 }
        XCTAssertEqual(rawRows.count, 1)
        XCTAssertEqual(rawRows[0].count, 3)
        XCTAssertEqual(rawRows[0][0] as? String, rows[0][0])
        XCTAssertEqual(rawRows[0][1] as? String, rows[0][1])
        XCTAssertEqual(rawRows[0][2] as? String, rows[0][2])
    }

    func testRowCast() {
        let header = ["name", "nickname"]
        let rows = [
            ["Malcom Reynolds", "Mal"],
            ["Simon Tam", "Simon"],
            ["Horban Washburne", "Wash"]
        ]
        let provider = MockTableProvider(header: header, rows: rows)
        let schema = Schema(header.map { Field($0) })
        let table = Table(provider: AnyTableProvider(provider), schema: schema)
        let castedRows = table.map { $0 }
        XCTAssertEqual(castedRows.count, 3)
    }

    func testUnevenFields() {
        // Note: Fields ought to be even. If they aren't, this implementation clips the longer of the schema fields and the row values to match one another
        let header = ["full", "nickname"]
        let rows = [
            ["Malcom Reynolds", "Mal", "Malcom"],
            ["Simon Tam"],
            ["Horban Washburne", "Wash"]
        ]
        let provider = MockTableProvider(header: nil, rows: rows)
        let schema = Schema(header.map { Field($0) })
        let table = Table(provider: AnyTableProvider(provider), schema: schema)
        let castedRows = table.map { $0 }
        XCTAssertEqual(castedRows.count, 3)
        XCTAssertEqual(castedRows[0].count, 2)
        XCTAssertEqual(castedRows[1].count, 1)
        XCTAssertEqual(castedRows[2].count, 2)

    }

    static var allTests = [
        ("testBadCast", testBadCast),
        ("testDuplicateCaseInsensitiveFields", testDuplicateCaseInsensitiveFields),
        ("testDuplicateCaseSensitiveFields", testDuplicateCaseSensitiveFields),
        ("testMisorderedFields", testMisorderedFields),
        ("testMissingSchema", testMissingSchema),
        ("testMissingHeader", testMissingHeader),
        ("testRowCast", testRowCast),
        ("testUnevenFields", testUnevenFields),
    ]

}

class MockTableProvider: TableProvider {

    let rows: [[String?]]

    init(header: [String]?, rows: [[String?]]) {
        self.header = header
        self.rows = rows
    }

    // MARK: - TableProvider

    let header: [String]?

    // MARK: - Sequence

    func makeIterator() -> AnyIterator<[String?]> {
        var currentIndex = 0
        return AnyIterator {
            guard currentIndex < self.rows.count else {
                return nil
            }
            defer {
                currentIndex += 1
            }
            return self.rows[currentIndex]
        }
    }

}
