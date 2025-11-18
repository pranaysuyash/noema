# Contributing to Noema

Thank you for your interest in contributing to Noema! This document provides guidelines for contributing to the project.

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and considerate in all interactions.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/pranaysuyash/noema/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Device and iOS version

### Suggesting Features

1. Check existing [Issues](https://github.com/pranaysuyash/noema/issues) and [Discussions](https://github.com/pranaysuyash/noema/discussions)
2. Create a new discussion or issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Possible implementation approach

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the code style guidelines below
   - Write clear, descriptive commit messages
   - Add tests for new functionality
   - Update documentation as needed

4. **Test your changes**
   ```bash
   # Run tests
   xcodebuild test -scheme Noema -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
   ```

5. **Commit with descriptive messages**
   ```bash
   git commit -m "feat: Add voice emotion analysis"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Provide a clear description of changes
   - Reference any related issues
   - Include screenshots for UI changes

## Code Style Guidelines

### Swift Code Style

- **Indentation**: 4 spaces (no tabs)
- **Line Length**: 120 characters max
- **Naming**:
  - Classes, Structs, Enums: `PascalCase`
  - Functions, Variables: `camelCase`
  - Constants: `camelCase` or `UPPER_SNAKE_CASE` for global constants
  - Protocols: Use `-able`, `-ing` suffixes where appropriate (e.g., `Identifiable`, `Combining`)

- **Organization**:
  ```swift
  // MARK: - TypeName

  class ExampleClass {
      // MARK: - Properties

      // MARK: - Initialization

      // MARK: - Public Methods

      // MARK: - Private Methods
  }
  ```

- **Documentation**:
  ```swift
  /// Brief description of function
  ///
  /// - Parameters:
  ///   - param1: Description
  ///   - param2: Description
  /// - Returns: Description of return value
  /// - Throws: Description of errors
  public func exampleFunction(param1: String, param2: Int) throws -> Bool {
      // Implementation
  }
  ```

### SwiftUI Views

- Use `@State` for view-local state
- Use `@StateObject` for view-owned objects
- Use `@ObservedObject` for passed-in objects
- Use `@EnvironmentObject` for app-wide state
- Extract subviews for better readability:
  ```swift
  struct ComplexView: View {
      var body: some View {
          VStack {
              HeaderView()
              ContentView()
              FooterView()
          }
      }
  }
  ```

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, tooling

**Examples**:
```
feat(notes): Add voice note transcription
fix(mood): Correct emotion detection accuracy
docs(readme): Update installation instructions
```

## Development Setup

1. **Prerequisites**:
   - macOS 14+ (Sonoma)
   - Xcode 15+
   - iOS 17+ SDK

2. **Clone the repository**:
   ```bash
   git clone https://github.com/pranaysuyash/noema.git
   cd noema
   ```

3. **Install dependencies** (if any):
   ```bash
   # Currently no external dependencies
   ```

4. **Open in Xcode**:
   ```bash
   open Noema.xcodeproj
   ```

5. **Run the app**:
   - Select a simulator or device
   - Press `Cmd+R` to build and run

## Testing

### Unit Tests

- Write tests for all new functionality
- Aim for >80% code coverage
- Use XCTest framework
- Mock external dependencies

```swift
import XCTest
@testable import Noema

final class NoteServiceTests: XCTestCase {
    func testCreateTextNote() async throws {
        // Test implementation
    }
}
```

### UI Tests

- Test critical user flows
- Use accessibility identifiers
- Keep tests maintainable

```swift
import XCTest

final class NoteFlowUITests: XCTestCase {
    func testCreateNote() throws {
        let app = XCUIApplication()
        app.launch()

        // Test implementation
    }
}
```

## Project Structure

```
Noema/
├── Sources/
│   ├── App/                    # App entry point
│   ├── Features/               # Feature modules
│   │   ├── Notes/
│   │   ├── Mood/
│   │   ├── KnowledgeGraph/
│   │   ├── Gamification/
│   │   └── Settings/
│   ├── Core/
│   │   ├── Models/             # Core Data models
│   │   ├── Services/           # Business logic
│   │   ├── Utilities/          # Helpers & extensions
│   │   └── Networking/         # API client
│   └── Resources/              # Assets, localization
├── Tests/
│   ├── UnitTests/
│   └── UITests/
└── docs/                       # Documentation
```

## Areas for Contribution

### High Priority

1. **AI Model Integration**
   - Integrate Whisper model for transcription
   - Fine-tune DistilBERT for sentiment analysis
   - Implement BERT-NER for entity recognition

2. **UI/UX Implementation**
   - Complete SwiftUI views for all features
   - Implement animations and transitions
   - Add haptic feedback

3. **Testing**
   - Write unit tests for services
   - Add UI tests for critical flows
   - Performance testing

### Medium Priority

4. **Features**
   - Apple Watch companion app
   - Widgets (home screen, lock screen)
   - Shortcuts integration
   - Share extension

5. **Accessibility**
   - VoiceOver support
   - Dynamic text sizing
   - High contrast modes
   - Reduce motion options

### Low Priority

6. **Localization**
   - Spanish, French, German translations
   - RTL language support
   - Locale-specific formatting

7. **Documentation**
   - API documentation
   - User guides
   - Video tutorials

## Questions?

- Open a [Discussion](https://github.com/pranaysuyash/noema/discussions)
- Join our Discord: [coming soon]
- Email: hello@noema.app

## License

By contributing to Noema, you agree that your contributions will be licensed under the project's license (to be announced upon public launch).

---

**Thank you for contributing to Noema! Together, we're building the future of self-awareness. 🌱**
