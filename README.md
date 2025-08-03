# Marhaba - Voice Assistant for Refugees 🌍

A Flutter-based voice assistant application designed to help refugees, migrants, and displaced people navigate life in a new country. Marhaba provides helpful information about essential services like healthcare, education, housing, and employment - all while running completely offline for privacy and accessibility.

## 🚀 Features

- **🎤 Voice Recognition**: Ask questions using speech-to-text
- **🔊 Text-to-Speech**: Get responses read aloud 
- **🤖 AI-Powered**: Uses Gemma 3 model for intelligent responses
- **🔒 Fully Offline**: Complete privacy - no data leaves your device
- **🌐 Multilingual Support**: Designed with international users in mind
- **📱 Cross-Platform**: Works on Android, iOS, and desktop

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

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines and feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Google Gemma**: For providing the AI model
- **Ollama**: For local AI infrastructure
- **Flutter Team**: For the amazing framework
- **Refugee Communities**: For inspiring this project

---

**Marhaba** (مرحبا) means "welcome" in Arabic - embodying our mission to welcome and support those starting new lives in unfamiliar places.
