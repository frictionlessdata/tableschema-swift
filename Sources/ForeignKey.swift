public class ForeignKey {

    public class Reference {
        public static let selfReferencing = ""

        public var resource: String
        public var fields = [Field]()

        /**
            Fields may reference (as a source) other fields from a resource. Referenced resources may be self-referencing meaning that fields are referenced within the same resource instead of an external resource.
        */
        public init(resource: String = selfReferencing) {
            self.resource = resource
        }
    }

    public var fields = [Field]()
    public var reference: Reference

    /**
        Represents a dependency relationship from one or more fields to referencing fields from which to source from.

        - Parameter fields: One or more fields that reference (depend on) others.
        - Parameter reference: Relationship between these fields to others in a resource.
    */
    public init(fields: [Field], reference: Reference) {
        self.fields = fields
        self.reference = reference
    }

}
