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
            return "// ❌ Error: Unable to code as UTF-8"
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                       options: [.prettyPrinted, .sortedKeys])
            
            guard let prettyString = String( prettyData, encoding: .utf8) else {
                return "// ❌ Error: Unable to convert to String"
            }
            
            return generateResult(formattedJSON: prettyString, jsonObject: jsonObject)
            
        } catch {
            return "// ❌ Error JSON parsing: \(error.localizedDescription)"
        }
    }
    
    private func generateResult(formattedJSON: String, jsonObject: Any) -> String {
        var result = "// 📝 JSON Formatted:\n/*\n\(formattedJSON)\n*/\n\n"
        
        if let dict = jsonObject as? [String: Any] {
            result += generateSwiftModel(from: dict)
        } else if let array = jsonObject as? [Any],
                  let firstItem = array.first as? [String: Any] {
            result += "// 📋 Array with \(array.count) elements\n"
            result += generateSwiftModel(from: firstItem, name: "ArrayElement")
        }
        
        result += "\n// 💡 Use case example:\n"
        result += "// let decoder = JSONDecoder()\n"
        result += "// let model = try decoder.decode(JSONModel.self, from: jsonData)\n"
        
        return result
    }
    
    private func generateSwiftModel(from dict: [String: Any], name: String = "JSONModel") -> String {
        var result = "struct \(name): Codable {\n"
        
        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            let propertyName = makeValidPropertyName(key)
            let swiftType = getSwiftType(for: value)
            result += "    let \(propertyName): \(swiftType)\n"
        }
        
        result += "}\n"
        return result
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
    
    private func getSwiftType(for value: Any) -> String {
        switch value {
        case is String: return "String"
        case is Int: return "Int"
        case is Double, is Float: return "Double"
        case is Bool: return "Bool"
        case let array as [Any]:
            if let first = array.first {
                return "[\(getSwiftType(for: first))]"
            }
            return "[Any]"
        case is [String: Any]: return "[String: Any]"
        default: return "Any"
        }
    }
    
    private func replaceContent(in buffer: XCSourceTextBuffer, with newContent: String) {
        buffer.lines.removeAllObjects()
        let lines = newContent.components(separatedBy: .newlines)
        for line in lines {
            buffer.lines.add(line)
        }
    }
    
}
