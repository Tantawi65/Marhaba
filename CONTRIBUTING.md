# Contributing to Marhaba

Thank you for considering contributing to Marhaba! This project aims to help refugees and displaced people access essential services, and every contribution makes a real difference.

## 🌟 Ways to Contribute

### 🐛 Bug Reports
- Check existing issues before creating new ones
- Include clear steps to reproduce the bug
- Provide device/platform information
- Include screenshots or logs when helpful

### 💡 Feature Requests
- Explain the problem you're trying to solve
- Describe your proposed solution
- Consider the impact on our target users (refugees/displaced people)
- Think about offline-first functionality

### 🔧 Code Contributions
- Follow our coding standards (see below)
- Include tests for new features
- Update documentation as needed
- Ensure accessibility considerations

### 🌍 Data Contributions
- Add service locations for new countries/regions
- Verify accuracy of existing data
- Follow our data format standards
- Include reliable sources for your data

### 🗣️ Translation
- Help translate the app into more languages
- Review existing translations for accuracy
- Consider cultural context and local terminology

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Git
- A GitHub account
- Code editor (VS Code recommended)

### Setting Up Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/yourusername/marhaba.git
   cd marhaba
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Setup**
   ```bash
   flutter doctor
   flutter test
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## 📝 Coding Standards

### Dart/Flutter Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter format` before committing
- Run `flutter analyze` to check for issues

### File Organization
```
lib/
├── models/          # Data models
├── services/        # Business logic
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/           # Utility functions
```

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`

### Documentation
- Document public APIs with dartdoc comments
- Include examples for complex functions
- Update README for new features

## 🗃️ Data Format Standards

When adding service location data, follow this JSON structure:

```json
{
  "id": "unique_identifier",
  "name": "Service Name",
  "type": "hospital|school|shelter|food_bank",
  "city": "City Name",
  "district": "District/Area",
  "street": "Street Name",
  "number": "Street Number",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "raw": {
    "original_data": "from_source"
  }
}
```

### Data Sources
- Use official government databases when available
- NGO and humanitarian organization data
- OpenStreetMap for geographic data
- Always cite your sources in commit messages

### Data Verification
- Cross-reference with multiple sources
- Verify coordinates are accurate
- Ensure services are currently active
- Include contact information when available

## 🧪 Testing

### Writing Tests
- Write unit tests for new functions
- Include widget tests for UI components
- Test offline functionality thoroughly
- Consider edge cases and error handling

### Running Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/location_service_test.dart

# With coverage
flutter test --coverage
```

## 📋 Pull Request Process

### Before Submitting
- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No merge conflicts

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Data update
- [ ] Documentation
- [ ] Translation

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Works offline

## Screenshots (if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

### Review Process
1. Automated checks must pass
2. At least one maintainer review required
3. Consider accessibility impact
4. Test on multiple platforms when possible

## 🚨 Important Guidelines

### Privacy & Security
- Never include personal information in commits
- Be cautious with location data accuracy
- Consider user privacy in all features
- Follow security best practices

### Accessibility
- Design for users with varying technical skills
- Support multiple languages and cultures
- Consider low-bandwidth scenarios
- Test with screen readers when possible

### Humanitarian Focus
- Prioritize features that help our target users
- Consider crisis scenarios (emergency needs)
- Think about language barriers
- Design for stress and urgency

## 🆘 Getting Help

- **GitHub Discussions**: Ask questions and discuss ideas
- **Issues**: Check existing issues or create new ones
- **Discord/Slack**: Join our community chat (link in README)
- **Email**: Contact maintainers for sensitive issues

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for helping make essential services more accessible to those who need them most! 🙏
