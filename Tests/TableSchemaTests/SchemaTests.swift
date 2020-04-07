@testable import TableSchema
import XCTest

class SchemaTests: XCTestCase {

    func testMissingValues() {
        let stringField = Field("missingString")
        let integerField = Field("missingInteger")
        integerField.type = .integer
        let schema = Schema()
        schema.fields = [stringField, integerField]

        // Missing (1)
        var value = ""
        XCTAssertNil(schema.cast(value, by: stringField))
        XCTAssertTrue(schema.test(value, by: stringField))

        // Missing (2)
        value = "NaN"
        XCTAssertEqual(schema.cast(value, by: stringField) as! String, value)
        XCTAssertTrue(schema.test(value, by: stringField))
        XCTAssertNil(schema.cast(value, by: integerField))
        XCTAssertFalse(schema.test(value, by: integerField))

        // Missing (3)
        schema.missingValues.append(value)
        XCTAssertNil(schema.cast(value, by: stringField))
        XCTAssertTrue(schema.test(value, by: stringField))
        XCTAssertNil(schema.cast(value, by: integerField))
        XCTAssertTrue(schema.test(value, by: integerField))
    }

    // MARK: Support

    func schemas() -> [String: Schema] {
        // Quotation Entity
        let quotation = "quotation"

        let quotationID = Field("id")
        quotationID.type = .integer
        quotationID.constraints.unique = true
        let quote = Field("quote")
        let author = Field("author")

        var schemas = [String: Schema]()
        var schema = Schema()
        schema.fields = [quotationID, quote, author]
        schema.primaryKeys = [quotationID]
        schemas[quotation] = schema

        // Tag Entity
        let tag = "tag"

        let tagID = Field("id")
        tagID.type = .integer
        tagID.constraints.unique = true
        let name = Field("name")

        schema = Schema()
        schema.fields = [tagID, name]
        schema.primaryKeys = [tagID]
        schemas[tag] = (schema)

        // Many-to-Many Relationship between Quotation and Tag
        let relationship = "relationship"

        let relationshipQuotation = Field(quotation + "." + quotationID.name)
        relationshipQuotation.type = .integer
        relationshipQuotation.constraints.required = true

        let relationshipTag = Field(tag + "." + tagID.name)
        relationshipTag.type = .integer
        relationshipTag.constraints.required = true

        schema = Schema()
        schema.fields = [relationshipQuotation, relationshipTag]
        schema.primaryKeys = [relationshipQuotation, relationshipTag]
        schemas[relationship] = schema

        let quotationReference = ForeignKey.Reference(resource: quotation)
        quotationReference.fields = [quotationID]
        let quotationForeignKey = ForeignKey(fields: [relationshipQuotation], reference: quotationReference)

        let tagReference = ForeignKey.Reference(resource: quotation)
        tagReference.fields = [tagID]
        let tagForeignKey = ForeignKey(fields: [relationshipTag], reference: tagReference)

        schema.foreignKeys = [quotationForeignKey, tagForeignKey]

        return schemas
    }

    static var allTests = [
        ("testMissingValues", testMissingValues),
    ]

}
