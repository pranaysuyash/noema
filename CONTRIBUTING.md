# Contributing to noema

First off, thank you for considering contributing to noema! 🙏

**noema** is currently in **stealth development mode** with an internal team. However, we welcome feedback, bug reports, and suggestions from our beta testers.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
3. [Development Setup](#development-setup)
4. [Coding Standards](#coding-standards)
5. [Commit Guidelines](#commit-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Testing](#testing)
8. [Documentation](#documentation)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of:
- Experience level
- Gender identity and expression
- Sexual orientation
- Disability
- Personal appearance
- Race, ethnicity, or religion
- Age

### Our Standards

**Examples of behavior that contributes to a positive environment:**

✅ Using welcoming and inclusive language
✅ Being respectful of differing viewpoints and experiences
✅ Gracefully accepting constructive criticism
✅ Focusing on what is best for the community
✅ Showing empathy towards other community members

**Examples of unacceptable behavior:**

❌ The use of sexualized language or imagery
❌ Trolling, insulting/derogatory comments, and personal or political attacks
❌ Public or private harassment
❌ Publishing others' private information without explicit permission
❌ Other conduct which could reasonably be considered inappropriate

### Enforcement

Violations of the Code of Conduct should be reported to [email protected]. All complaints will be reviewed and investigated promptly and fairly.

---

## How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
- Check the [existing issues](https://github.com/your-org/noema/issues) to avoid duplicates
- Collect information about the bug:
  - iOS version
  - noema app version
  - Steps to reproduce
  - Expected vs. actual behavior
  - Screenshots or screen recordings (if applicable)

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Tap on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment (please complete the following information):**
 - Device: [e.g. iPhone 15 Pro]
 - iOS Version: [e.g. 17.2]
 - App Version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

We love hearing your ideas! Enhancement suggestions are tracked as GitHub issues.

**Enhancement Suggestion Template:**
```markdown
**Is your feature request related to a problem?**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

### Beta Testing

Want to be a beta tester?
1. Join our [TestFlight program](https://testflight.apple.com/join/noema)
2. Join our [Discord community](https://discord.gg/noema)
3. Provide regular feedback through in-app feedback or Discord

---

## Development Setup

### Prerequisites

- **macOS 14+** (Sonoma or later)
- **Xcode 15.2+**
- **Swift 6.0+**
- **Git**

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/noema.git
   cd noema
   ```

2. **Navigate to iOS project**
   ```bash
   cd noema-ios
   ```

3. **Resolve dependencies**
   ```bash
   swift package resolve
   ```

4. **Open in Xcode**
   ```bash
   open Package.swift
   ```

5. **Build and run**
   - Select your target device/simulator
   - Press `⌘R` to build and run

### Troubleshooting

**Issue: Dependencies won't resolve**
```bash
# Clear package cache
rm -rf .build
swift package clean
swift package resolve
```

**Issue: Xcode won't build**
```bash
# Clean build folder
Product → Clean Build Folder (⇧⌘K)
```

---

## Coding Standards

### Swift Style Guide

We follow the [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide) with some modifications:

#### Naming

```swift
// ✅ Good
class UserProfileViewModel { }
func fetchUserData() async throws -> User
let maximumNumberOfRetries = 5

// ❌ Bad
class usrPrflVM { }
func getData() { }
let max_retries = 5
```

#### Organization

```swift
// MARK: - Properties
private let repository: NoteRepositoryProtocol
private var cachedNotes: [Note] = []

// MARK: - Initialization
init(repository: NoteRepositoryProtocol) {
    self.repository = repository
}

// MARK: - Public Methods
func loadNotes() async throws { }

// MARK: - Private Methods
private func processNotes() { }
```

#### Access Control

```swift
// Default to private, expose only what's necessary
private func helperMethod() { } // Private by default
public func publicAPI() { }      // Explicit public
```

#### Modern Concurrency

```swift
// ✅ Use async/await
func fetchData() async throws -> Data {
    try await repository.fetch()
}

// ❌ Avoid completion handlers for new code
func fetchData(completion: @escaping (Result<Data, Error>) -> Void) { }
```

### SwiftLint

We use SwiftLint to enforce style. Run before committing:

```bash
swiftlint
```

Auto-fix violations:

```bash
swiftlint --fix
```

---

## Commit Guidelines

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (white-space, formatting)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvements
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to build process or auxiliary tools

### Examples

```bash
feat(notes): add voice recording functionality

Implemented AVFoundation-based voice recording with real-time
waveform visualization. Includes pause/resume and background recording.

Closes #123
```

```bash
fix(mood): correct emotion detection confidence calculation

The confidence score was being calculated incorrectly, leading to
low confidence scores even for high-quality detections.

Fixes #456
```

### Best Practices

✅ Use present tense ("add feature" not "added feature")
✅ Use imperative mood ("move cursor to..." not "moves cursor to...")
✅ Limit first line to 72 characters
✅ Reference issues and PRs in the footer

---

## Pull Request Process

### Before Creating a PR

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, documented code
   - Add tests for new functionality
   - Update documentation

3. **Run tests**
   ```bash
   swift test
   ```

4. **Run SwiftLint**
   ```bash
   swiftlint
   ```

5. **Commit your changes**
   ```bash
   git commit -m "feat(scope): description"
   ```

### Creating a PR

1. **Push to GitHub**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a Pull Request** on GitHub

3. **Fill out the PR template**

**PR Template:**
```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing on device/simulator

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published
```

### Code Review Process

1. **Automated Checks**: CI must pass (tests, linting)
2. **Peer Review**: At least 2 approvals from core team
3. **Address Feedback**: Make requested changes
4. **Final Approval**: Maintainer approves and merges

### Merging

- **Squash and merge** for feature branches
- **Rebase and merge** for hotfixes
- **Delete branch** after merging

---

## Testing

### Running Tests

```bash
# All tests
swift test

# Specific test suite
swift test --filter DomainTests

# With code coverage
swift test --enable-code-coverage
```

### Writing Tests

**Test Naming:**
```swift
func test_createNote_withValidContent_succeeds() throws {
    // Given
    let content = "Test note"

    // When
    let note = try createNote(content: content)

    // Then
    XCTAssertEqual(note.content, content)
}
```

**Use Quick/Nimble for BDD-style tests:**
```swift
describe("NoteCreation") {
    context("when content is valid") {
        it("creates note successfully") {
            let note = try createNote(content: "Test")
            expect(note.content) == "Test"
        }
    }
}
```

### Coverage Goals

- **Domain Layer**: >90%
- **Data Layer**: >85%
- **Application Layer**: >80%
- **Presentation Layer**: >70%

---

## Documentation

### Code Documentation

Use Swift DocC format:

```swift
/// Creates a new note with AI-generated metadata
///
/// This method analyzes the note content using on-device AI models to detect
/// mood, extract entities, and generate a summary. The note is then saved
/// to the repository and user statistics are updated.
///
/// - Parameter note: The note to create
/// - Returns: The created note with AI-generated metadata
/// - Throws: `NoteError.emptyContent` if content is empty
///           `RepositoryError` if save fails
func createNote(_ note: Note) async throws -> Note {
    // Implementation
}
```

### README Updates

If your PR adds new functionality, update the relevant README or docs:
- `README.md`: High-level project overview
- `docs/technical/`: Technical documentation
- `docs/product/`: Product documentation

---

## Questions?

- **Technical Questions**: [email protected]
- **General Inquiries**: [email protected]
- **Discord**: [discord.gg/noema](https://discord.gg/noema)

---

Thank you for contributing to noema! Together, we're building the future of emotionally intelligent note-taking. ✨

---

**Last Updated:** 2025-11-17
