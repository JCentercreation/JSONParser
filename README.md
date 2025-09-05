# JSON Parser Xcode Extension

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-12.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

*A powerful Xcode Source Editor Extension that transforms JSON into Swift `Codable` structures*

[Installation](#-installation) • [Usage](#-usage) • [Features](#-features) • [Contributing](#-contributing)

</div>

## 🎯 Overview

**JSON Parser Xcode Extension** is a productivity tool for iOS developers that automatically converts JSON data into properly typed Swift `Codable` structures. Simply paste your JSON, run the extension, and get production-ready Swift code with nested structs, proper type detection, and clean formatting.

## ✨ Features

- 🎨 **Pretty Print JSON** - Formats JSON with proper indentation and key sorting
- 🏗️ **Auto-Generate Swift Structs** - Creates nested `Codable` structures automatically
- 🔍 **Smart Type Detection** - Correctly identifies `Bool`, `Int`, `Double`, `String`, and `Array` types
- 📦 **Nested Object Support** - Handles complex nested objects and arrays seamlessly
- 🛡️ **Null Value Handling** - Converts null values to appropriate optional types
- 🚫 **Duplicate Prevention** - Avoids generating duplicate struct definitions
- 🔄 **Array Processing** - Intelligently handles arrays of primitives and complex objects
- ⚡ **Fast Processing** - Near-instant conversion for any JSON size

## 📋 Requirements

- **macOS 10.15** (Catalina) or later
- **Xcode 12.0** or later
- **Swift 5.0** or later

## 🚀 Installation

### Method 1: Clone and Build

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/JSONParserExtension.git cd JSONParserExtension
```

2. **Open in Xcode**
- Double-click `JSONParser.xcodeproj`
- Select the **Extension target** (not the main app)

3. **Build and run**
- Press `⌘ + R` or click the Run button
- When prompted, choose **Xcode** as the target application
- A new Xcode instance will launch (recognizable by its darker dock icon)

4. **Enable the extension**
- Go to **System Settings** → **Privacy & Security** → **Extensions**
- Select **Xcode Source Editor Extensions**
- Toggle **JSON Parser Extension** to enabled

### Method 2: Download Release

1. Download the latest release from [Releases](https://github.com/jcentercreation/JSONParser/releases)
2. Unzip and follow steps 2-4 from Method 1

## 📖 Usage

### Basic Usage

1. **In Xcode**, open any Swift file or create a new one
2. **Paste your JSON** content into the file
3. **Select the JSON text** (optional - if nothing is selected, the entire file will be processed)
4. **Navigate to menu**: **Editor** → **JSON Parser Extension** → **Parse JSON**
5. **Enjoy your generated Swift code!** ✨

### Example Transformation

**Input JSON:**
```
{ “user”: { “id”: 123, “name”: “John Doe”, “email”: “john@example.com”, “isActive”: true, “preferences”: { “theme”: “dark”, “notifications”: true, “language”: “en” }, “skills”: “Swift”, “iOS”, “UIKit”, “SwiftUI”, “projects”:  { “name”: “MyApp”, “language”: “Swift”, “completed”: true, “contributors”: 5 }, { “name”: “WebService”, “language”: “Python”, “completed”: false, “contributors”: 3 }  }, “timestamp”: “2025-09-05T19:33:00Z” }
```

**Generated Swift Code:**

```swift
// 📝 Formatted JSON:
/*
{
“timestamp” : “2025-09-05T19:33:00Z”,
“user” : {
“email” : “john@example.com”,
“id” : 123,
“isActive” : true,
“name” : “John Doe”,
“preferences” : {
“language” : “en”,
“notifications” : true,
“theme” : “dark”
},
“projects” : 
{
“completed” : true,
“contributors” : 5,
“language” : “Swift”,
“name” : “MyApp”
},
{
“completed” : false,
“contributors” : 3,
“language” : “Python”,
“name” : “WebService”
}
,
“skills” : “Swift”,“iOS”,“UIKit”,“SwiftUI”
}
}
*/
struct Preferences: Codable {
    let language: String
    let notifications: Bool
    let theme: String
    }

struct ProjectElement: Codable {
    let completed: Bool
    let contributors: Int
    let language: String
    let name: String
    }

struct User: Codable {
    let email: String
    let id: Int
    let isActive: Bool
    let name: String
    let preferences: Preferences
    let projects: ProjectElement
    let skills: String
    }

struct JSONModel: Codable {
    let timestamp: String
    let user: User 
    }

// 💡 Usage example:
// let decoder = JSONDecoder()
// let model = try decoder.decode(JSONModel.self, from: jsonData)
```

## 🎯 Advanced Features

### Keyboard Shortcut Setup

For faster access, assign a custom keyboard shortcut:

1. **Xcode** → **Preferences** → **Key Bindings**
2. Search for **"Parse JSON"**
3. Assign your preferred combination (e.g., `⌘ + Shift + J`)

### Handling Edge Cases

The extension gracefully handles:

- **Empty arrays** → `[Any]`
- **Null values** → Optional types (`String?`)
- **Mixed number types** → Intelligent Int/Double detection
- **Boolean detection** → Distinguishes `true`/`false` from `1`/`0`
- **Nested complexity** → Unlimited nesting levels
- **Invalid JSON** → Clear error messages

## 🛠️ Development

### Building from Source

1. **Fork** this repository
2. **Clone** your fork locally
3. **Open** `JSONParser.xcodeproj` in Xcode
4. **Make** your changes
5. **Test** thoroughly with various JSON structures
6. **Submit** a pull request

### Testing

Test the extension with various JSON structures:

- Simple objects
- Deeply nested structures  
- Arrays of different types
- Edge cases (nulls, empty arrays, mixed types)

## 🐛 Troubleshooting

### Extension Not Appearing in Menu

1. ✅ Verify extension is **enabled** in System Settings
2. ✅ **Restart Xcode** completely (quit and reopen)
3. ✅ Check that **XcodeKit.framework** is set to "Embed & Sign"
4. ✅ Ensure you're running from the **extension target**, not main app

### Build Errors

1. ✅ Verify **Xcode 12.0+** is installed
2. ✅ Enable **"Automatically manage signing"** in project settings
3. ✅ Ensure **Bundle Identifier** is unique
4. ✅ Check **Deployment Target** matches your macOS version

### JSON Parsing Issues

1. ✅ **Validate JSON** using an online JSON validator
2. ✅ Check for **encoding issues** (ensure UTF-8)
3. ✅ Try with **simpler JSON** first to isolate problems
4. ✅ Review **Xcode console** for error messages

### Common Solutions
```bash
# Reset Xcode preferences if extension isn’t working
defaults delete com.apple.dt.Xcode
# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
# Re-enable extension in System Settings
System Settings → Privacy & Security → Extensions → Xcode Source Editor
```

## 🤝 Contributing

Contributions make the open source community amazing! Any contributions are **greatly appreciated**.

### How to Contribute

1. **Fork** the project
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Contribution Guidelines

- **Code Style**: Follow Swift best practices
- **Testing**: Test with various JSON structures
- **Documentation**: Update README for new features
- **Compatibility**: Ensure Xcode 12.0+ compatibility

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Apple's XcodeKit** framework and comprehensive documentation
- **iOS/macOS development community** for inspiration and feedback
- **Contributors** who help improve this tool
- **Users** who provide valuable feedback and bug reports

## 📞 Support

Need help? Here's how to get support:

1. **Check** the [Issues](https://github.com/yourusername/JSONParserExtension/issues) section
2. **Search** existing issues before creating a new one
3. **Create** a detailed issue with:
   - Sample JSON input
   - Expected vs actual output
   - Xcode version and macOS version
   - Steps to reproduce

## 🌟 Show Your Support

If this tool helps your development workflow, please:

- ⭐ **Star** this repository
- 🐛 **Report** any bugs you find
- 💡 **Suggest** new features
- 🔄 **Share** with fellow iOS developers

---

<div align="center">

**Made with ❤️ for the iOS development community**

[⬆ Back to Top](#json-parser-xcode-extension)

</div>

