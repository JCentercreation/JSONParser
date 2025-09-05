//
//  SourceEditorExtension.swift
//  JSONParserExtension
//
//  Created by Javier Carrillo Gallego on 5/9/25.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    func extensionDidFinishLaunching() {
            print("JSON Parser Extension has loaded")
        }
    
    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return []
    }
    */
    
}
