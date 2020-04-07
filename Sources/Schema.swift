public class Schema {

    public var fields = [Field]()
    public var missingValues = [String]([""])
    public var primaryKeys = [Field]()
    public var foreignKeys = [ForeignKey]()

    /**
        A schema models a record, or entity, with field descriptors, establishes relationships through foreign key fields, signifies important fields through primary keys, and provides higher-level field casting that respects the schema's properties like missing value conversions.

        To enable serialization and deserialization, cast operate from a "physical" representation (`String`s) to a "logical" representation (Swift Standard Library types) with reverse casts operate the other direction.
    */
    public init(_ fields: [Field] = []) {
        self.fields = fields
    }

    /**
        Casts a record from a physical representation to logical with the specified field ordering.

        - Parameter record: A record, or entity, to be cast according to the provided fields
        - Parameter by: Desired field ordering. Fields are presumed to be part of this schema. Uses the schema's field ordering if unspecified.
    */
    public func cast(record: [String?], by fieldOrdering: [Field]? = nil) -> [Any?] {
        let fields = fieldOrdering ?? self.fields
        return zip(record, fields).map { self.cast($0, by: $1) }
    }

    /**
        Casts a single field from a physical representation to logical.
    */
    public func cast(_ value: String?, by field: Field) -> Any? {
        return (try? self.internalCast(value, by: field)) ?? nil
    }

    /**
        - Returns: Whether a cast would succeed.
    */
    public func test(_ value: String?, by field: Field) -> Bool {
        do {
            _ = try self.internalCast(value, by: field)
        } catch {
            return false
        }
        return true
    }

    internal func internalCast(_ value: String?, by field: Field) throws -> Any? {
        var value = value
        if let unwrappedValue = value, self.missingValues.contains(unwrappedValue) {
            value = nil
        }

        return try field.internalCast(value)
    }

    /**
        Casts a record from the logical representation to a physical one with the specified field ordering.

        - Parameter record: A record, or entity, to be cast according to the provided fields
        - Parameter by: Desired field ordering. Fields are presumed to be part of this schema. Uses the schema's field ordering if unspecified.
    */
    public func reverseCast(record: [Any?], by fieldOrdering: [Field]? = nil) -> [String?] {
        let fields = fieldOrdering ?? self.fields
        return zip(record, fields).map { self.reverseCast($0, by: $1) }
    }

    /**
        Casts a single field from the logical representation to a physical one.
    */
    public func reverseCast(_ value: Any?, by field: Field) -> String? {
        return (try? self.internalReverseCast(value, by: field)) ?? nil
    }

    /**
        - Returns: Whether a reverse cast would succeed.
    */
    public func reverseTest(_ value: Any?, by field: Field) -> Bool {
        do {
            _ = try self.internalReverseCast(value, by: field)
        } catch {
            return false
        }
        return true
    }

    internal func internalReverseCast(_ value: Any?, by field: Field) throws -> String? {
        guard let result = try field.internalReverseCast(value) else {
            return self.missingValues.first ?? nil
        }
        return result
    }

}

public extension Array where Element == Field {

    var unique: Set<Field> {
        return Set<Field>(self)
    }

    var uniqueByName: [String: Field] {
        var fields = [String: Field]()
        self.forEach { field in
            let uniqueName = field.uniqueName
            if fields[uniqueName] == nil {
                fields[uniqueName] = field
            }
        }
        return fields
    }

    var groupByName: [String: [Field]] {
        return Dictionary(grouping: self, by: { $0.name })
    }

}
