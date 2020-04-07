import Foundation

public class Table: Sequence {

    public let provider: AnyTableProvider
    public let schema: Schema?

    public var header: [String]? {
        return self.provider.header
    }

    // MARK: - Setup & Teardown

    /**
        `Table` is a convenience for casting data from a physical representation to a logical one.

         - Parameter provider: An object that conforms to `TableProvider` for providing header and record data from some physical representation.
         optionally providing a stream of data.
         - Parameter schema: Schema for which to cast data.
    */
    public init(provider: AnyTableProvider, schema: Schema? = nil) {
        self.provider = provider
        self.schema = schema
    }

    // MARK: - Sequence

    /**
        Provides for iteration by record with optional casting when a schema is given.
    */
    public class CastIterator: IteratorProtocol {

        let provider: AnyTableProvider
        let iterator: AnyIterator<[String?]>
        let schema: Schema?
        let orderedFields: [Field]?

        let limit: Int
        var count: Int = 0

        public init(provider: AnyTableProvider, schema: Schema?, keyed: Bool = true, limit: Int = NSNotFound) {
            self.provider = provider
            self.iterator = provider.makeIterator()
            self.schema = schema
            if keyed, let fields = schema?.fields, let header = provider.header {
                var orderedFields = [Field]()
                let uniqueFields = fields.uniqueByName
                for name in header {
                    let uniqueName = Field(name).uniqueName
                    if let field = uniqueFields[uniqueName] {
                        orderedFields.append(field)
                    }
                }
                self.orderedFields = orderedFields
            } else {
                self.orderedFields = nil
            }
            self.limit = limit
        }

        public func next() -> [Any?]? {
            guard count < limit, let next = self.iterator.next() else {
                return nil
            }
            defer {
                count += 1
            }
            guard let schema = self.schema else {
                return next
            }
            guard let fields = self.orderedFields else {
                return schema.cast(record: next)
            }
            return schema.cast(record: next, by: fields)
        }
    }

    public func makeIterator() -> CastIterator {
        return CastIterator(provider: self.provider, schema: self.schema)
    }

}

/**
    Implement `TableProvider` to provide tabular data from a data source.

    This protocol enables implementations to provide a stream of data if they choose so long as data is streamed by record. If data streaming is a forward-only operation, the implementation should recreate data streaming by returning a new iterator each time `makeIterator()` is called.
*/
public protocol TableProvider: Sequence where Element == [String?] {

    var header: [String]? { get }

    func makeIterator() -> AnyIterator<Element>

}

public final class AnyTableProvider: TableProvider {

    private let _header: [String]?
    private let _makeIterator: () -> AnyIterator<[String?]>

    public init<Concrete: TableProvider>(_ concrete: Concrete) {
        _header = concrete.header
        _makeIterator = concrete.makeIterator
    }

    public var header: [String]? {
        return _header
    }

    public func makeIterator() -> AnyIterator<[String?]> {
        return _makeIterator()
    }

}
