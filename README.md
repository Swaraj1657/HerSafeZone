<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.7%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.7%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=for-the-badge" />

<br /><br />

# 🛡️ HerSafeZone

### *Empowering Women. One Alert at a Time.*

**HerSafeZone** is a comprehensive personal safety mobile application built with Flutter, designed to put safety in the hands of every woman. From one-tap SOS alerts and real-time GPS sharing to community-powered incident heatmaps — HerSafeZone provides a complete safety ecosystem, backed by Firebase.

<br />

[![Demo Video](https://img.shields.io/badge/▶%20Watch%20Demo-YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtube.com/watch?v=wi65YmX-xos&feature=youtu.be)
&nbsp;&nbsp;
[![Download APK](https://img.shields.io/badge/⬇%20Download%20APK-Google%20Drive-4285F4?style=for-the-badge&logo=google-drive&logoColor=white)](https://drive.google.com/file/d/1KqKP0pXu5n5-fzjdFo5JLSeK4lP__-sD/view)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Permissions](#-permissions-required)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🆘 SOS & Emergency Alerts
Trigger an instant emergency call to your designated contacts with a single tap. Automated SMS alerts containing your real-time GPS coordinates are sent simultaneously — no manual input needed in a crisis.

### 📍 Real-Time Location Tracking
Powered by Google Maps and `geolocator`, your precise location is tracked and shareable with trusted contacts at all times, ensuring someone always knows where you are.

### 🗺️ Safety Heatmap & Incident Reporting
View a live community-driven heatmap of reported unsafe areas near you. Flag and report incidents directly from the app to help protect others in your community.

### 📞 Emergency Contacts Management
Add, edit, and securely store your primary emergency contacts — always ready when you need them most.

### 🏥 Medical Profile
Store critical medical information (blood type, allergies, medications) securely within the app — accessible by responders during an emergency.

### 💬 Community Forum
Connect with other users, share localized safety tips, discuss local incidents, and build a network of awareness and support.

### 📜 History Logs
Review a complete log of your past SOS alerts, incident reports, and location sharing activities for peace of mind.

### 🔐 Secure Authentication
Full sign-up and login system powered by Firebase Authentication — your data stays private and protected.

---

## 📸 Screenshots

> _Watch the full app walkthrough in the [demo video](https://youtube.com/watch?v=wi65YmX-xos&feature=youtu.be) or [download the APK](https://drive.google.com/file/d/1KqKP0pXu5n5-fzjdFo5JLSeK4lP__-sD/view) to try it yourself._

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) — SDK ^3.7.0 |
| **Backend & Auth** | Firebase Authentication + Cloud Firestore |
| **Maps & Location** | `google_maps_flutter`, `geolocator`, `location` |
| **Messaging** | `telephony_sms` — automated SMS |
| **Calling** | `flutter_direct_call_plus` — direct emergency dialing |
| **Permissions** | `permission_handler` |
| **Local Storage** | `shared_preferences` |
| **Internationalization** | `intl` |

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following set up:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.7.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio, VS Code, or IntelliJ IDEA
- A Google Maps API Key (enabled for Maps SDK for Android/iOS)
- A Firebase project with:
  - Firebase Authentication enabled (Email/Password)
  - Cloud Firestore database created
  - `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) downloaded

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/Swaraj1657/HerSafeZone.git
cd HerSafeZone
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase**

- Place `google-services.json` inside `android/app/`
- Place `GoogleService-Info.plist` inside `ios/Runner/`

**4. Add your Google Maps API Key**

_Android_ — open `android/app/src/main/AndroidManifest.xml` and add:
```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="YOUR_API_KEY_HERE"/>
```

_iOS_ — open `ios/Runner/AppDelegate.swift` and add:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

**5. Run the application**
```bash
flutter run
```

---

## 🔐 Permissions Required

HerSafeZone relies on several device permissions to deliver its safety features. Users are prompted to grant these at runtime:

| Permission | Purpose |
|---|---|
| **Location** (Fine & Background) | Real-time tracking, GPS coordinates in SOS alerts, heatmap |
| **SMS** | Automated emergency SMS to contacts |
| **Phone / Call** | Direct emergency calls to designated contacts |
| **Internet** | Firebase sync, maps, community forum |

---

## 📁 Project Structure

```
HerSafeZone/
├── android/              # Android-specific configuration
├── ios/                  # iOS-specific configuration
├── lib/                  # Main Dart source code
│   ├── screens/          # UI screens (Home, SOS, Heatmap, Forum, etc.)
│   ├── services/         # Firebase, Location, SMS & Call services
│   ├── models/           # Data models
│   └── main.dart         # App entry point
├── firestore.rules       # Cloud Firestore security rules
├── firebase.json         # Firebase project configuration
└── pubspec.yaml          # Dependencies & app metadata
```

---

## 🤝 Contributing

Contributions are welcome! To get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add: your feature description'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please make sure your changes don't break existing features and follow Flutter best practices.

---

## 📄 License

This project is open source. Feel free to use, modify, and distribute with attribution.

---

<div align="center">

Built with ❤️ for a safer world.

**[⭐ Star this repo](https://github.com/Swaraj1657/HerSafeZone)** if you find it helpful!

</div>
