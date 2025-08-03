# Marhaba - Voice Assistant for Refugees 🌍

A Flutter-based voice assistant application designed to help refugees, migrants, and displaced people navigate life in a new country. Marhaba provides helpful information about essential services like healthcare, education, housing, and emergency shelters - all while running completely offline for privacy and accessibility.

## 🚀 Key Features

- **🎤 Voice Recognition**: Ask questions using speech-to-text in multiple languages
- **🔊 Text-to-Speech**: Get responses read aloud 
- **🤖 AI-Powered**: Uses Gemma 3 model for intelligent responses
- **🔒 Fully Offline**: Complete privacy - no data leaves your device
- **📍 Location Services**: Find nearby hospitals, shelters, schools, and food banks
- **🗺️ Offline Maps**: Navigate to essential services without internet
- **🌐 Multilingual Support**: Designed with international users in mind
- **📱 Cross-Platform**: Works on Android, iOS, and desktop

## 🏥 Offline Location Services

Marhaba includes comprehensive offline databases for essential services:

- **🏥 Hospitals & Medical Centers**: Emergency and routine healthcare facilities
- **🏠 Emergency Shelters**: Safe accommodation options
- **🏫 Schools & Education**: Educational institutions and language learning centers
- **🍽️ Food Banks**: Food assistance and meal programs

### Supported Countries
- **🇹🇷 Turkey**: Complete dataset with 40,000+ service locations
- **🇩🇪 Germany**: Major cities and regions (expanding)

## 🧠 AI Integration

Marhaba integrates with **Gemma 3** running locally via Ollama:

- **Primary Mode**: Uses Gemma 3 for intelligent, contextual responses
- **Fallback Mode**: Comprehensive offline responses when AI is unavailable
- **Privacy First**: All AI processing happens locally on your device
- **No Internet Required**: Once set up, works completely offline

## 🛠️ Setup & Installation

### Prerequisites

1. **Flutter SDK** (3.3.0 or higher)
2. **Ollama** (for AI functionality)
3. **Gemma 3 Model** (automatically downloaded)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd marhaba
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up Gemma 3 (for AI features):**
   - See [setup_gemma3.md](setup_gemma3.md) for detailed instructions
   - Or let the app auto-download the model on first run

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📋 System Requirements

### Minimum Requirements:
- **RAM**: 4GB (8GB recommended for AI features)
- **Storage**: 4GB free space
- **OS**: Android 6.0+ / iOS 12.0+ / Windows 10+ / macOS 10.14+

### For Optimal AI Performance:
- **RAM**: 16GB or more
- **Storage**: SSD recommended
- **Processor**: Modern multi-core CPU

## 🎯 Target Audience

Marhaba is designed for:
- Refugees and asylum seekers
- Recent immigrants and migrants
- International students
- Displaced persons
- Social workers and volunteers
- Community organizations

## 🛡️ Privacy & Security

- ✅ **100% Offline AI**: All processing happens locally
- ✅ **No Data Collection**: No personal information stored or transmitted
- ✅ **No Internet Required**: Works without network connection
- ✅ **Local Storage Only**: All data stays on your device
- ✅ **Open Source**: Transparent and auditable code

## 🗣️ Supported Topics

Marhaba provides guidance on:

- **Healthcare**: Emergency services, clinics, health insurance
- **Education**: School enrollment, ESL classes, language learning
- **Housing**: Emergency shelter, housing assistance, tenant rights
- **Employment**: Job search, work authorization, career training
- **Legal**: Document assistance, immigration help, legal aid
- **Transportation**: Public transit, driver's licenses, mobility options
- **General Resources**: Community centers, 211 services, local organizations

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── services/
│   ├── voice_assistant_service.dart   # Core voice AI logic
│   └── ollama_service.dart            # Gemma 3 integration
└── ...
```

## 🔧 Development

### Building for Production

```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🤝 Contributing & Team Collaboration

We welcome contributions from developers, translators, and humanitarian organizations! This project is designed for team collaboration to help refugees worldwide.

### How to Contribute

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/marhaba.git
   cd marhaba
   ```
3. **Set up Flutter** (see prerequisites above)
4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
5. **Make your changes** and test thoroughly
6. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add your descriptive commit message"
   ```
7. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
8. **Create a Pull Request** on GitHub

### Areas We Need Help With

- **🌍 Data Collection**: Adding service locations for more countries
- **🗣️ Translation**: Supporting more languages
- **🎨 UI/UX**: Improving accessibility and user experience
- **📱 Platform Support**: iOS and desktop optimizations
- **📊 Testing**: Unit tests and integration tests
- **📝 Documentation**: User guides and technical documentation

### Data Contribution

To add service locations for a new country:

1. Create a new folder: `data/CountryName/`
2. Add JSON files for each service type:
   - `countryname_hospitals.json`
   - `countryname_schools.json`
   - `countryname_shelters.json`
3. Follow the existing data format (see `data/Turkey/` for examples)
4. Update the `Country` enum in `lib/models/service_location.dart`

### Code Style

- Follow [Flutter's style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful commit messages
- Add comments for complex logic
- Include tests for new features

## 📞 Support & Contact

- **Issues**: Report bugs or request features on GitHub Issues
- **Discussions**: Join our GitHub Discussions for questions and ideas
- **Security**: For security issues, please email privately (contact info in SECURITY.md)

## 🎯 Roadmap

- [ ] **Offline Route Navigation**: Turn-by-turn directions without internet
- [ ] **Emergency Features**: Quick access to emergency services
- [ ] **Community Updates**: User-contributed service information
- [ ] **Multi-language Voice**: Voice recognition in Arabic, Farsi, and other languages
- [ ] **Integration APIs**: Connect with local government services
- [ ] **Mobile Optimization**: Better performance on low-end devices

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Google Gemma**: For providing the AI model
- **Ollama**: For local AI infrastructure
- **Flutter Team**: For the amazing framework
- **Refugee Communities**: For inspiring this project

---

**Marhaba** (مرحبا) means "welcome" in Arabic - embodying our mission to welcome and support those starting new lives in unfamiliar places.
