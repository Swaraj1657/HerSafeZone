# HerSafeZone

HerSafeZone is a comprehensive mobile application built with Flutter, focused on enhancing women's personal safety and security. It provides quick access to emergency services, secure location sharing, and a supportive community, seamlessly integrated with Firebase for reliable data management.

## 🌟 Key Features

* **Complete Authentication System:** Secure login and registration powered by Firebase Authentication.
* **SOS & SMS Alerts:** Trigger immediate emergency calls to designated contacts and send automated SMS alerts containing your real-time GPS coordinates.
* **Real-Time Location Tracking:** Integrated Google Maps and geolocator to track and share your location accurately with trusted contacts.
* **Safety Heatmap & Incident Reporting:** A dynamic heatmap feature allows users to view reported incidents in specific areas, as well as manually flag/report unsafe zones for the community's awareness.
* **Emergency Contacts Management:** Easily add, edit, and store phone numbers of primary emergency contacts.
* **Medical Profile:** Securely store essential medical information accessible during emergencies.
* **Community Forum:** Connect with others to share updates, localized safety tips, and raise awareness.
* **History Logs:** Keep track of your past alerts, incident reports, and activities seamlessly.

## 🛠️ Technology Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend:** Firebase (Authentication & Cloud Firestore)
* **Location Services:** `google_maps_flutter`, `geolocator`, `location`
* **Device Capabilities:** `telephony_sms` (Messaging), `flutter_direct_call_plus` (Dialer), `permission_handler`
* **Local Storage:** `shared_preferences`

## 🚀 Getting Started

To get a local copy of this project up and running, follow these steps:

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.7.0 or higher)
* Dart SDK
* An IDE (Android Studio, VS Code, or IntelliJ)
* A Google Maps API Key
* A Firebase Project with Google Services Configuration (`google-services.json` / `GoogleService-Info.plist`)

### Installation 

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Swaraj1657/HerSafeZone.git
   cd HerSafeZone
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase & APIs:**
   * Place your `google-services.json` inside the `android/app/` directory.
   * Place your `GoogleService-Info.plist` inside the `ios/Runner/` directory.
   * Add your Google Maps API key into the relevant `AndroidManifest.xml` (Android) and `AppDelegate.swift` (iOS) files.

4. **Run the application:**
   ```bash
   flutter run
   ```

## 🔐 Permissions Required

Because the application relies heavily on device services for safety capabilities, the following permissions are requested during usage:
* **Location:** Required for the heatmap and sending coordinates during SOS.
* **SMS & Phone Calls:** Required to automatically dial or text contacts during emergencies.

---
*Built with ❤️ for a safer environment.*
