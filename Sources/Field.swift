import Foundation

public class Field {

    public struct Constraints {
        public var `required`: Bool?
        public var unique: Bool?
        public var minLength: Int?
        public var maxLength: Int?
        public var minimum: Any?
        public var maximum: Any?
        public var pattern: String?
        public var `enum`: Set<AnyHashable>?
    }

    public enum FieldType: String {
        case string
        case number
        case integer
        case boolean
        case object
        case array
        case date
        case time
        case dateTime = "datetime"
        case year
        case yearMonth = "yearmonth"
        case duration
        case geoPoint = "geopoint"
        case geoJson = "geojson"
        case any
    }

    // - Note: We can't both have enum associated values and raw values
    public enum Format: CustomStringConvertible, Equatable {
        case `default`
        case email
        case uri
        case binary
        case uuid
        case any
        case array
        case object
        case pattern(String)

        public init?(description: String) {
            switch description {
            case "default":
                self = .default
            case "email":
                self = .email
            case "uri":
                self = .uri
            case "binary":
                self = .binary
            case "uuid":
                self = .uuid
            case "any":
                self = .any
            case "array":
                self = .array
            case "object":
                self = .object
            default:
                self = .pattern(description)
            }
        }

        public var description: String {
            switch self {
            case .default:
                return "default"
            case .email:
                return "email"
            case .uri:
                return "uri"
            case .binary:
                return "binary"
            case .uuid:
                return "uuid"
            case .any:
                return "any"
            case .array:
                return "array"
            case .object:
                return "object"
            case .pattern(let value):
                return value
            }
        }

        public static func == (lhs: Format, rhs: Format) -> Bool {
            return lhs.description == rhs.description
        }
    }

    public var name: String
    public var title: String?
    public var description: String?
    public var type = FieldType.string
    public var format = Format.default
    public var rdfType: URL?
    public var constraints = Constraints()

    // Additional properties
    public var trueValues = ["true", "True", "TRUE", "1"]
    public var falseValues = ["false", "False", "FALSE", "0"]
    public var bareNumber = true

    internal enum CastError: Error {
    case badCast
    case unavailableCast
    }

    public init(_ name: String, type: FieldType = .string) {
        self.name = name
        self.type = type
    }

    // MARK: - Methods

    public var uniqueName: String {
        return self.name.lowercased()
    }

}

extension Field {

    // MARK: - Reverse Casting (Logical to Physical)

    public func reverseCast(_ value: Any?) -> String? {
        do {
            return try self.internalReverseCast(value)
        } catch {
            return nil
        }
    }

    public func reverseTest(_ value: Any?) -> Bool {
        do {
            _ = try self.internalReverseCast(value)
        } catch {
            return false
        }
        return true
    }

    internal func internalReverseCast(_ value: Any?) throws -> String? {
        guard let value = value else {
            return nil
        }
        switch self.type {
        case .string:
            return try reverseStringCast(value)
        case .number:
            throw CastError.unavailableCast
        case .integer:
            return try reverseIntegerCast(value)
        case .boolean:
            return try reverseBooleanCast(value)
        case .object:
            throw CastError.unavailableCast
        case .array:
            return try reverseArrayCast(value)
        case .date:
            throw CastError.unavailableCast
        case .time:
            throw CastError.unavailableCast
        case .dateTime:
            return try reverseDateTimeCast(value)
        case .year:
            throw CastError.unavailableCast
        case .yearMonth:
            throw CastError.unavailableCast
        case .duration:
            throw CastError.unavailableCast
        case .geoPoint:
            throw CastError.unavailableCast
        default:
            throw CastError.unavailableCast
        }
    }

    internal func reverseStringCast(_ value: Any) throws -> String {
        switch self.format {
        case .default:
            guard let string = value as? String else {
                throw CastError.badCast
            }
            return string
        case .email:
            throw CastError.unavailableCast
        case .uri:
            guard let url = value as? URL else {
                throw CastError.badCast
            }
            return url.absoluteString
        case .binary:
            guard let string = value as? String else {
                throw CastError.badCast
            }
            guard let data = string.data(using: .utf8) else {
                throw CastError.badCast
            }
            return data.base64EncodedString()
        case .uuid:
            guard let uuid = value as? UUID else {
                throw CastError.badCast
            }
            return uuid.uuidString
        default:
            break
        }
        throw CastError.badCast
    }

    internal func reverseIntegerCast(_ value: Any) throws -> String {
        guard let integer = value as? Int else {
            throw CastError.badCast
        }
        return String(integer)
    }

    internal func reverseBooleanCast(_ value: Any) throws -> String {
        guard let boolean = value as? Bool else {
            throw CastError.badCast
        }
        if boolean {
            guard let trueValue = trueValues.first else {
                throw CastError.badCast
            }
            return trueValue
        }
        guard let falseValue = falseValues.first else {
            throw CastError.badCast
        }
        return falseValue
    }

    internal func reverseArrayCast(_ value: Any) throws -> String {
        guard let array = value as? [Any] else {
            throw CastError.badCast
        }
        guard let data = try? JSONSerialization.data(withJSONObject: array) else {
            throw CastError.badCast
        }
        guard let json = String(data: data, encoding: .utf8) else {
            throw CastError.badCast
        }
        return json
    }

    internal func reverseDateTimeCast(_ value: Any) throws -> String {
        switch self.format {
        case .default:
            guard let date = value as? Date else {
                throw CastError.badCast
            }
            #if os(iOS) || os(macOS)
            if #available(iOS 10, macOS 10.12, *) {
                let dateFormatter = ISO8601DateFormatter()
                return dateFormatter.string(from: date)
            } else {
                throw CastError.unavailableCast
            }
            #else
            throw CastError.unavailableCast
            #endif
        case .any:
            throw CastError.unavailableCast
        case .pattern:
            throw CastError.unavailableCast
        default:
            break
        }
        throw CastError.badCast
    }

}

extension Field {

    // MARK: - Forward Casting (Physical to Logical)

    public func cast(_ value: String?) -> Any? {
        do {
            return try self.internalCast(value)
        } catch {
            return nil
        }
    }

    public func test(_ value: String?) -> Bool {
        do {
            _ = try self.internalCast(value)
        } catch {
            return false
        }
        return true
    }

    internal func internalCast(_ value: String?) throws -> Any? {
        guard let value = value else {
            return nil
        }
        switch self.type {
        case .string:
            return try stringCast(value)
        case .number:
            throw CastError.unavailableCast
        case .integer:
            return try integerCast(value)
        case .boolean:
            return try booleanCast(value)
        case .object:
            return try objectCast(value)
        case .array:
            return try arrayCast(value)
        case .date:
            return try dateCast(value)
        case .time:
            return try timeCast(value)
        case .dateTime:
            return try dateTimeCast(value)
        case .year:
            return try yearCast(value)
        case .yearMonth:
            return try yearMonthCast(value)
        case .duration:
            return try durationCast(value)
        case .geoPoint:
            return try geoPointCast(value)
        case .geoJson:
            throw CastError.unavailableCast
        case .any:
            throw CastError.unavailableCast
        }
    }

    private func digits(using scanner: Scanner, _ isNegative: Bool) -> Int? {
        #if os(iOS) || os(macOS)
        var valueString: NSString?
        guard scanner.scanCharacters(from: CharacterSet.decimalDigits, into: &valueString) else {
            return nil
        }
        guard let string = valueString as String? else {
            return nil
        }
        if isNegative, let integer = Int("-" + string) {
            return integer
        } else if let integer = Int(string) {
            return integer
        }
        #endif
        return nil
    }

    internal func stringCast(_ value: String) throws -> Any {
        switch self.format {
        case .default:
            return value
        case .email:
            throw CastError.unavailableCast
        case .uri:
            if let url = URL(string: value) {
                return url
            }
        case .binary:
            if let data = Data(base64Encoded: value), let decoded = String(data: data, encoding: .utf8) {
                return decoded
            }
        case .uuid:
            if let uuid = UUID(uuidString: value) {
                return uuid.uuidString
            }
        default:
            break
        }
        throw CastError.badCast
    }

    internal func integerCast(_ value: String) throws -> Any {
        if !self.bareNumber {
            #if os(iOS) || os(macOS)
            let scanner = Scanner(string: value)
            scanner.charactersToBeSkipped = nil

            var characters = CharacterSet.decimalDigits
            characters.insert("-")
            scanner.scanUpToCharacters(from: characters, into: nil)
            let isNegative = scanner.scanCharacters(from: CharacterSet(charactersIn: "-"), into: nil)

            if let integer = digits(using: scanner, isNegative) {
                return integer
            }
            #else
            throw CastError.unavailableCast
            #endif
        } else if let integer = Int(value) {
            return integer
        }
        throw CastError.badCast
    }

    internal func booleanCast(_ value: String) throws -> Any {
        if self.trueValues.contains(value) {
            return true
        } else if self.falseValues.contains(value) {
            return false
        }
        throw CastError.badCast
    }

    internal func objectCast(_ value: String) throws -> Any {
        guard let data = value.data(using: .utf8) else {
            throw CastError.badCast
        }
        guard let object = try? JSONSerialization.jsonObject(with: data) else {
            throw CastError.badCast
        }
        guard let dictionary = object as? [String: Any] else {
            throw CastError.badCast
        }
        return dictionary
    }

    internal func arrayCast(_ value: String) throws -> Any {
        guard let data = value.data(using: .utf8) else {
            throw CastError.badCast
        }
        guard let object = try? JSONSerialization.jsonObject(with: data) else {
            throw CastError.badCast
        }
        guard let array = object as? [Any] else {
            throw CastError.badCast
        }
        return array
    }

    internal func dateCast(_ value: String) throws -> Any {
        switch self.format {
        case .default:
        #if os(iOS) || os(macOS)
            if #available(iOS 10, macOS 10.12, *) {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
                if let date = dateFormatter.date(from: value) {
                    return date
                }
            } else {
                throw CastError.unavailableCast
            }
        #else
        throw CastError.unavailableCast
        #endif
        case .any:
            throw CastError.unavailableCast
        case .pattern:
            throw CastError.unavailableCast
        default:
            break
        }
        throw CastError.badCast
    }

    internal func timeCast(_ value: String) throws -> Any {
        switch self.format {
        case .default:
        #if os(iOS) || os(macOS)
            if #available(iOS 10, macOS 10.12, *) {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withTime, .withColonSeparatorInTime]
                if let date = dateFormatter.date(from: value) {
                    return date
                }
            } else {
                throw CastError.unavailableCast
            }
        #else
        throw CastError.unavailableCast
        #endif
        case .any:
            throw CastError.unavailableCast
        case .pattern:
            throw CastError.unavailableCast
        default:
            break
        }
        throw CastError.badCast
    }

    internal func dateTimeCast(_ value: String) throws -> Any {
        switch self.format {
        case .default:
        #if os(iOS) || os(macOS)
            if #available(iOS 10, macOS 10.12, *) {
                let dateFormatter = ISO8601DateFormatter()
                if let date = dateFormatter.date(from: value) {
                    return date
                }
            } else {
                throw CastError.unavailableCast
            }
        #else
        throw CastError.unavailableCast
        #endif
        case .any:
            throw CastError.unavailableCast
        default:
            break
        }
        throw CastError.badCast
    }

    internal func yearCast(_ value: String) throws -> Any {
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withYear, .withDashSeparatorInDate]
            if let date = dateFormatter.date(from: value) {
                return date
            }
        } else {
            throw CastError.unavailableCast
        }
        #else
        throw CastError.unavailableCast
        #endif
        throw CastError.badCast
    }

    internal func yearMonthCast(_ value: String) throws -> Any {
        #if os(iOS) || os(macOS)
        if #available(iOS 10, macOS 10.12, *) {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withYear, .withMonth, .withDashSeparatorInDate]
            if let date = dateFormatter.date(from: value) {
                return date
            }
        } else {
            throw CastError.unavailableCast
        }
        #else
        throw CastError.unavailableCast
        #endif
        throw CastError.badCast
    }

    internal func durationCast(_ value: String) throws -> Any {
        #if os(iOS) || os(macOS)
        let scanner = Scanner(string: value)
        scanner.charactersToBeSkipped = nil

        var characters = CharacterSet.uppercaseLetters
        characters.insert("-")
        scanner.scanUpToCharacters(from: characters, into: nil)
        let isNegative = scanner.scanCharacters(from: CharacterSet(charactersIn: "-"), into: nil)

        var components = DateComponents()

        var hasDate = false
        guard scanner.scanCharacters(from: CharacterSet(charactersIn: "P"), into: nil) else {
            throw CastError.badCast
        }

        var value = digits(using: scanner, isNegative)

        if scanner.scanCharacters(from: CharacterSet(charactersIn: "Y"), into: nil) {
            components.year = value
            hasDate = true
            value = digits(using: scanner, isNegative)
        }

        if scanner.scanCharacters(from: CharacterSet(charactersIn: "M"), into: nil) {
            components.month = value
            hasDate = true
            value = digits(using: scanner, isNegative)
        }

        if scanner.scanCharacters(from: CharacterSet(charactersIn: "D"), into: nil) {
            components.day = value
            hasDate = true
        }

        var hasTime = false
        let hasTimeDesignator = scanner.scanCharacters(from: CharacterSet(charactersIn: "T"), into: nil)

        value = digits(using: scanner, isNegative)

        if scanner.scanCharacters(from: CharacterSet(charactersIn: "H"), into: nil) {
            components.hour = value
            hasTime = true
            value = digits(using: scanner, isNegative)
        }

        if scanner.scanCharacters(from: CharacterSet(charactersIn: "M"), into: nil) {
            components.minute = value
            hasTime = true
            value = digits(using: scanner, isNegative)
        }

        if scanner.scanCharacters(from: CharacterSet(charactersIn: "."), into: nil) {
            guard let decimals = digits(using: scanner, isNegative) else {
                throw CastError.badCast
            }
            var reduced = decimals
            var length = 0
            while reduced != 0 {
                length += 1
                reduced /= 10
            }
            components.nanosecond = Int(Double(decimals) * pow(10, Double(9 - length)))
        }

        if scanner.scanCharacters(from: CharacterSet(charactersIn: "S"), into: nil) {
            components.second = value
            hasTime = true
        }

        if hasTimeDesignator != hasTime {
            throw CastError.badCast
        }

        if !hasDate && !hasTime {
            throw CastError.badCast
        }

        return components
        #else
        throw CastError.unavailableCast
        #endif
    }

    internal func geoPointCast(_ value: String) throws -> Any {
        switch self.format {
        case .default:
            let array = value.split(separator: ",")
            guard array.count == 2 else {
                throw CastError.badCast
            }
            guard let lon = Double(array.first!.trimmingCharacters(in: .whitespaces)) else {
                throw CastError.badCast
            }
            guard let lat = Double(array.last!.trimmingCharacters(in: .whitespaces)) else {
                throw CastError.badCast
            }
            return (lon, lat)
        case .array:
            guard let array = (try? arrayCast(value)) as? [Any], array.count == 2 else {
                throw CastError.badCast
            }
            return (array.first!, array.last!)
        case .object:
            guard let object = try objectCast(value) as? [String: Any] else {
                throw CastError.badCast
            }
            guard let lon = object["lon"] else {
                throw CastError.badCast
            }
            guard let lat = object["lat"] else {
                throw CastError.badCast
            }
            return (lon, lat)
        default:
            break
        }
        throw CastError.badCast
    }

}

extension Field: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uniqueName.hashValue)
    }

    public static func == (lhs: Field, rhs: Field) -> Bool {
        return lhs.uniqueName == rhs.uniqueName
    }

}
