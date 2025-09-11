# RUZ++ 📅

A modern, cross-platform timetable app for university students built with Flutter. RUZ++ provides a clean, intuitive interface for viewing schedules, filtering classes, and managing academic calendars.

## ✨ Features

- 🎯 **Cross-Platform**: Runs seamlessly on iOS, Android, and Web
- 📱 **Modern UI**: Material Design 3 with light/dark theme support
- 🔍 **Smart Search**: Find groups, lecturers, and courses quickly
- 🎛️ **Advanced Filters**: Filter by persons, locations, and disciplines
- 📊 **Week Navigation**: Easy week-by-week schedule browsing
- 💾 **Local Caching**: Offline support with smart data caching
- ⚙️ **Customizable**: Custom API endpoints and persistent settings
- 🌐 **PWA Ready**: Progressive Web App support with custom icons

## 🚀 Getting Started

### Prerequisites

Before running RUZ++, make sure you have the following installed:

- **Flutter SDK** (3.7.2 or higher)
  ```bash
  flutter --version
  ```
- **Dart SDK** (included with Flutter)
- **Git** for version control

### Platform-Specific Requirements

#### 🤖 Android Development
- **Android Studio** or **VS Code** with Flutter extension
- **Android SDK** (API level 21 or higher)
- **Java Development Kit (JDK)** 8 or higher
- **Android device** or **Android Emulator**

#### 🍎 iOS Development (macOS only)
- **Xcode** 12.0 or higher
- **iOS Simulator** or **physical iOS device**
- **CocoaPods** (for dependency management)
  ```bash
  sudo gem install cocoapods
  ```

#### 🌐 Web Development
- **Chrome**, **Firefox**, or **Safari** browser
- No additional setup required!

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/RUZplusplus.git
   cd RUZplusplus/ruz_timetable
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify installation**
   ```bash
   flutter doctor
   ```
   Make sure all required components show ✓ checkmarks.

## 🏃‍♂️ Running Debug Builds

### 🤖 Android Debug

#### Option 1: Using Android Emulator
1. **Start Android Studio** and open AVD Manager
2. **Create or start** an Android Virtual Device (AVD)
3. **Run the app**:
   ```bash
   flutter run
   ```
   or specify the platform explicitly:
   ```bash
   flutter run -d android
   ```

#### Option 2: Using Physical Android Device
1. **Enable Developer Options** on your Android device:
   - Go to Settings → About Phone → Tap "Build Number" 7 times
2. **Enable USB Debugging**:
   - Go to Settings → Developer Options → Enable "USB Debugging"
3. **Connect device** via USB cable
4. **Verify device is detected**:
   ```bash
   flutter devices
   ```
5. **Run the app**:
   ```bash
   flutter run
   ```

#### Troubleshooting Android
- If device is not detected: `adb devices`
- If build fails: `flutter clean && flutter pub get`
- For permission issues: Check USB debugging is enabled

### 🍎 iOS Debug (macOS only)

#### Option 1: Using iOS Simulator
1. **Start Xcode** and open Simulator
2. **Choose a device** (iPhone 14, iPad, etc.)
3. **Run the app**:
   ```bash
   flutter run
   ```
   or specify the platform:
   ```bash
   flutter run -d ios
   ```

#### Option 2: Using Physical iOS Device
1. **Connect your iPhone/iPad** via USB cable
2. **Trust the computer** on your iOS device when prompted
3. **Open the project in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. **Configure signing**:
   - Select "Runner" project in Xcode
   - Go to "Signing & Capabilities"
   - Select your Apple Developer account or create a free one
5. **Run from terminal**:
   ```bash
   flutter run
   ```

#### Troubleshooting iOS
- For signing issues: Use Xcode to configure automatic signing
- If pods are outdated: `cd ios && pod install --repo-update`
- For simulator issues: Reset simulator content and settings

### 🌐 Web Debug

Web development is the simplest - no additional setup required!

#### Option 1: Default Web Server
```bash
flutter run -d web-server
```
This will start a development server, typically at `http://localhost:3000`

#### Option 2: Specific Port
```bash
flutter run -d web-server --web-port 8080
```
Access your app at `http://localhost:8080`

#### Option 3: Chrome Browser
```bash
flutter run -d chrome
```
This will automatically open Chrome with your app

#### Option 4: Hot Reload Development
For the best development experience with hot reload:
```bash
flutter run -d web-server --web-port 8080 --hot
```

### 🎯 Running on Specific Devices

#### List Available Devices
```bash
flutter devices
```

#### Run on Specific Device
```bash
flutter run -d <device-id>
```

Example device IDs:
- `chrome` - Chrome browser
- `web-server` - Development web server
- `emulator-5554` - Android emulator
- `iPhone 14 Pro` - iOS simulator
- `00008030-XXXXXXXXXXXX` - Physical iOS device

## 🛠️ Development Commands

### Useful Flutter Commands

#### Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

#### Hot Reload (during development)
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

#### Debug Information
```bash
flutter run --verbose
```

#### Build for Different Modes
```bash
# Debug build (default)
flutter run --debug

# Profile build (performance testing)
flutter run --profile

# Release build (optimized)
flutter run --release
```

## 🔧 Configuration

### API Endpoint
By default, RUZ++ uses the public API endpoint. You can configure a custom endpoint in the app:
1. Go to **Settings** → **General**
2. Scroll to **Custom API Endpoint**
3. Enter your API URL (e.g., `http://localhost:5000/api`)
4. Tap **Save**

### Theme Settings
- **Light/Dark Mode**: Settings → General → Theme
- **System Theme**: Automatically follows device theme

## 📱 Building for Production

### Android APK/AAB
```bash
# APK (for direct installation)
flutter build apk --release

# AAB (for Google Play Store)
flutter build appbundle --release
```

### iOS IPA
```bash
# Build for iOS
flutter build ios --release

# Then use Xcode to archive and export
```

### Web Build
```bash
# Build for web deployment
flutter build web --release

# Files will be in build/web/
```

## 🐛 Troubleshooting

### Common Issues

#### "Flutter command not found"
- Ensure Flutter is added to your PATH
- Run `flutter doctor` to verify installation

#### "No devices found"
- For Android: Check USB debugging and device connection
- For iOS: Check device trust and Xcode configuration
- For Web: Any modern browser should work

#### "Build failed"
- Run `flutter clean && flutter pub get`
- Check `flutter doctor` for missing dependencies
- Verify platform-specific requirements

#### "Hot reload not working"
- Ensure you're running in debug mode
- Check that the app is still connected
- Try hot restart (`R`) instead

### Getting Help

1. **Flutter Documentation**: [https://docs.flutter.dev](https://docs.flutter.dev)
2. **Flutter Issues**: [https://github.com/flutter/flutter/issues](https://github.com/flutter/flutter/issues)
3. **Stack Overflow**: Tag your questions with `flutter`

## 🏗️ Project Structure

```
ruz_timetable/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── screens/                  # UI screens
│   ├── services/                 # API and storage services
│   └── widgets/                  # Reusable UI components
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web-specific files
└── pubspec.yaml                  # Dependencies and metadata
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Uses [Material Design 3](https://m3.material.io)
- Icons from [Material Icons](https://fonts.google.com/icons)

---

**Happy Coding!** 🚀

If you encounter any issues or have questions, please feel free to open an issue on GitHub.
