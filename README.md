# 📱 Journal Intime - Personal Journal App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A beautiful, feature-rich personal journal application built with Flutter. Document your daily thoughts, emotions, and memories with mood tracking, photo galleries, and more.

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 📝 Core Features
- **Journal Entries** - Create, edit, and delete daily journal entries
- **Mood Tracking** - Track your emotions with 5 different moods (Happy, Content, Neutral, Sad, Angry)
- **Photo Gallery** - Add 1-5 photos per entry from camera or gallery
- **Search & Filter** - Search by title, content, or date; filter by mood
- **Calendar View** - Visual calendar with mood indicators for each day
- **Password Protection** - Secure individual entries with passwords

### 🔐 Authentication
- **Email/Password** authentication
- **Google Sign-In** integration
- Secure user profile management

### 📊 Analytics & Stats
- **Mood Statistics** - Visualize your emotional patterns
- **Happy Days Counter** - Track your positive moments
- **Weekly Evolution** - See mood trends over time
- **Beautiful Charts** - Professional data visualization with fl_chart

### 🎨 Design
- **Material Design 3** - Modern, beautiful UI
- **Dark Mode** - Full dark theme support
- **Smooth Animations** - Delightful user experience
- **Responsive Layout** - Works on all screen sizes

### 🔔 Additional Features
- **Daily Reminders** - Get notified to write your daily entry
- **Export/Import** - Backup and restore your journal data (JSON)
- **Offline First** - All data stored locally with SQLite
- **Photo Carousel** - Swipe through your memories

---

## 📸 Screenshots

<div align="center">

| Onboarding | Login | Home |
|------------|-------|------|
| ![Onboarding](screenshots/onboarding.png) | ![Login](screenshots/login.png) | ![Home](screenshots/home.png) |

| Add Entry | Entry Details | Calendar |
|-----------|---------------|----------|
| ![Add Entry](screenshots/add_entry.png) | ![Entry Details](screenshots/entry_details.png) | ![Calendar](screenshots/calendar.png) |

| Gallery | Statistics | Settings |
|---------|-----------|----------|
| ![Gallery](screenshots/gallery.png) | ![Statistics](screenshots/stats.png) | ![Settings](screenshots/settings.png) |

</div>

---

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase account (for authentication)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/journal_intime.git
   cd journal_intime
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   **For Android:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add an Android app with package name: `com.example.journal_intime`
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

   **For iOS:**
   - Add an iOS app in Firebase Console
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/GoogleService-Info.plist`

   **Enable Authentication:**
   - Go to Firebase Console → Authentication
   - Enable Email/Password provider
   - Enable Google Sign-In provider

4. **Add SHA-1 fingerprint (for Google Sign-In)**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 and add it to your Firebase Android app settings.

5. **Create assets folders**
   ```bash
   mkdir -p assets/images assets/intro
   ```
   Add intro images (intro1.png, intro2.png, intro3.png) to `assets/intro/`

6. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/              # Data models
│   ├── user.dart
│   ├── journal_entry.dart
│   └── photo.dart
│
├── services/            # Backend services
│   ├── db_service.dart          # SQLite database
│   ├── image_service.dart       # Image picker & storage
│   ├── notification_service.dart # Local notifications
│   └── export_service.dart      # JSON export/import
│
├── providers/           # State management (Provider)
│   ├── auth_provider.dart       # Authentication state
│   ├── entry_provider.dart      # Journal entries state
│   ├── mood_provider.dart       # Mood tracking state
│   └── theme_provider.dart      # Theme state
│
├── views/              # UI screens
│   ├── initiale_page.dart       # Onboarding
│   ├── conexion_page.dart       # Login
│   ├── registre_page.dart       # Registration
│   ├── home_page.dart           # Main timeline
│   ├── add_entry_page.dart      # Create/Edit entry
│   ├── entry_details_page.dart  # View entry
│   ├── calendrier_page.dart     # Calendar view
│   ├── gallery_page.dart        # Photo gallery
│   ├── stats_page.dart          # Statistics
│   └── settings_page.dart       # Settings
│
└── main.dart           # App entry point
```

### Tech Stack
- **Framework:** Flutter 3.0+
- **Language:** Dart 3.0+
- **State Management:** Provider
- **Local Database:** SQLite (sqflite)
- **Authentication:** Firebase Auth
- **Image Handling:** image_picker, path_provider
- **Charts:** fl_chart
- **Calendar:** table_calendar
- **Carousel:** flutter_carousel_widget
- **Notifications:** flutter_local_notifications

---

## 🎨 Mood Color System

The app uses a sophisticated color system to represent different moods:

| Mood | Color | Emoji |
|------|-------|-------|
| **Joyeux (Happy)** | Yellow/Gold (#FFD700) | 😁 |
| **Content (Content)** | Orange (#FF8C00) | 😊 |
| **Neutre (Neutral)** | Gray (#808080) | 😐 |
| **Triste (Sad)** | Blue (#4169E1) | 😢 |
| **Énervé (Angry)** | Red (#DC143C) | 😡 |

---

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  
  # Images
  image_picker: ^1.0.7
  
  # Authentication
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  google_sign_in: ^6.2.1
  crypto: ^3.0.3
  
  # UI Components
  flutter_carousel_widget: ^2.0.3
  fl_chart: ^0.66.0
  table_calendar: ^3.0.9
  smooth_page_indicator: ^1.1.0
  
  # Utilities
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^16.3.2
  timezone: ^0.9.2
  share_plus: ^7.2.1
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Coding Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Comment complex logic
- Write clean, readable code
- Test your changes thoroughly

---

## 🐛 Known Issues

- [ ] Export/Import feature requires manual file selection
- [ ] Photo carousel may lag with 10+ images
- [ ] Dark mode needs refinement in some screens

See the [issues page](https://github.com/yourusername/journal_intime/issues) for a full list.

---

## 📝 Roadmap

- [ ] Cloud sync (Firebase Firestore)
- [ ] Voice notes
- [ ] Rich text formatting
- [ ] Tags and categories
- [ ] Multi-language support
- [ ] AI-powered mood insights
- [ ] Social features (optional sharing)
- [ ] Widget for home screen
- [ ] Wear OS support

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Journal Intime

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👥 Authors

**Development Team:**
- BOUAKKA Issam
- ELKEBDANI Hicham  
- EN-NAQQACH Mohssine

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Firebase](https://firebase.google.com) for authentication services
- [Material Design](https://material.io) for design guidelines
- All open-source contributors whose packages made this possible

---

## 📞 Support

If you like this project, please ⭐ star it on GitHub!

For questions or support:
- 📧 Email: support@journalintime.com
- 🐦 Twitter: [@journalintime](https://twitter.com/journalintime)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/journal_intime/discussions)

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to Top](#-journal-intime---personal-journal-app)

</div>