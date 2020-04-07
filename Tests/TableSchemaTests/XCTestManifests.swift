import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SchemaTests.allTests),
        testCase(TableTests.allTests),
        // Field Cast Tests
        testCase(FieldForwardCastTests.allTests),
        testCase(FieldArrayCastTests.allTests),
        testCase(FieldBooleanCastTests.allTests),
        testCase(FieldDateTimeCastTests.allTests),
        testCase(FieldIntegerCastTests.allTests),
        testCase(FieldStringCastTests.allTests),
    ]
}
#endif
