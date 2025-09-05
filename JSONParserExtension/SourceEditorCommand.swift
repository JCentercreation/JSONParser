//
//  SourceEditorCommand.swift
//  JSONParserExtension
//
//  Created by Javier Carrillo Gallego on 5/9/25.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation,
                completionHandler: @escaping (Error?) -> Void) {

        let buffer = invocation.buffer
        let textToProcess = getTextToProcess(from: buffer)

        if let result = parseJSON(textToProcess) {
            replaceContent(in: buffer, with: result)
        }

        completionHandler(nil)
    }

    private func getTextToProcess(from buffer: XCSourceTextBuffer) -> String {
        return buffer.lines.compactMap { $0 as? String }.joined(separator: "\n")
    }

    private func parseJSON(_ jsonString: String) -> String? {
        let cleaned = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            return "// Error: Unable UTF-8 encoding"
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                       options: [.prettyPrinted, .sortedKeys])

            guard let prettyString = String(data: prettyData, encoding: .utf8) else {
                return "// Error: Unable String conversion"
            }

            return generateResult(formattedJSON: prettyString, jsonObject: jsonObject)

        } catch {
            return "// Error JSON parsing: \(error.localizedDescription)"
        }
    }

    private func generateResult(formattedJSON: String, jsonObject: Any) -> String {
        var result = "// 📝 Formatted JSON:\n/*\n\(formattedJSON)\n*/\n\n"

        if let dict = jsonObject as? [String: Any] {
            result += generateAllStructs(from: dict, rootName: "JSONModel")
        } else if let array = jsonObject as? [Any],
                  let firstItem = array.first as? [String: Any] {
            result += "// 📋 Array with \(array.count) elements\n"
            result += generateAllStructs(from: firstItem, rootName: "ArrayElement")
        }

        result += "\n// USE CASE Example:\n"
        result += "// let decoder = JSONDecoder()\n"
        result += "// let model = try decoder.decode(JSONModel.self, from: jsonData)\n"

        return result
    }

    private func generateAllStructs(from dict: [String: Any], rootName: String) -> String {
        var allStructs: [String] = []
        var processedTypes: Set<String> = []

        collectNestedStructs(from: dict,
                            currentName: rootName,
                            allStructs: &allStructs,
                            processedTypes: &processedTypes)

        return allStructs.joined(separator: "\n")
    }

    private func collectNestedStructs(from dict: [String: Any],
                                    currentName: String,
                                    allStructs: inout [String],
                                    processedTypes: inout Set<String>) {

        guard !processedTypes.contains(currentName) else { return }
        processedTypes.insert(currentName)

        var structCode = "struct \(currentName): Codable {\n"
        var nestedStructsToProcess: [(dict: [String: Any], name: String)] = []

        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            let propertyName = makeValidPropertyName(key)

            if let nestedDict = value as? [String: Any] {
                let nestedStructName = propertyName.capitalized
                structCode += "    let \(propertyName): \(nestedStructName)\n"
                nestedStructsToProcess.append((dict: nestedDict, name: nestedStructName))

            } else if let array = value as? [Any] {
                let arrayType = getArrayType(for: array, propertyName: propertyName,
                                           nestedStructsToProcess: &nestedStructsToProcess)
                structCode += "    let \(propertyName): \(arrayType)\n"

            } else {
                let swiftType = getSwiftType(for: value)
                structCode += "    let \(propertyName): \(swiftType)\n"
            }
        }

        structCode += "}\n"

        for (nestedDict, nestedName) in nestedStructsToProcess {
            collectNestedStructs(from: nestedDict,
                               currentName: nestedName,
                               allStructs: &allStructs,
                               processedTypes: &processedTypes)
        }

        allStructs.append(structCode)
    }

    private func getArrayType(for array: [Any],
                             propertyName: String,
                             nestedStructsToProcess: inout [(dict: [String: Any], name: String)]) -> String {

        guard !array.isEmpty else { return "[Any]" }

        let firstElement = array.first!

        if let dictElement = firstElement as? [String: Any] {
            let elementStructName = propertyName.capitalized.replacingOccurrences(of: "s$", with: "") + "Element"
            nestedStructsToProcess.append((dict: dictElement, name: elementStructName))
            return "[\(elementStructName)]"

        } else {
            let elementType = getSwiftType(for: firstElement)
            return "[\(elementType)]"
        }
    }

    private func getSwiftType(for value: Any) -> String {
        switch value {
        case is String:
            return "String"
        case is Bool:
            return "Bool"
        case let number as NSNumber:
            let objCType = String(cString: number.objCType)
            if objCType == "c" || objCType == "B" {
                return "Bool"
            }
            if number.stringValue.contains(".") {
                return "Double"
            } else {
                return "Int"
            }
        case is Int:
            return "Int"
        case is Double, is Float:
            return "Double"
        case let array as [Any]:
            if let first = array.first {
                return "[\(getSwiftType(for: first))]"
            }
            return "[Any]"
        case is [String: Any]:
            return "[String: Any]"
        default:
            if value is NSNull {
                return "String?"
            }
            return "Any"
        }
    }

    private func makeValidPropertyName(_ name: String) -> String {
        let cleaned = name
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        if cleaned.first?.isNumber == true {
            return "_\(cleaned)"
        }

        return cleaned
    }

    private func replaceContent(in buffer: XCSourceTextBuffer, with newContent: String) {
        buffer.lines.removeAllObjects()
        let lines = newContent.components(separatedBy: .newlines)
        for line in lines {
            buffer.lines.add(line)
        }
    }
}
