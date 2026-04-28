# Dear Environment 🌿💌

---

**A mobile app that turns everyday environmental moments into tiny digital postcards.**

> Notice the sky.\
> Capture the moment.\
> Let the environment write back.

<img src="https://github.com/CynthiaZHANGovo/MobileApp/blob/main/Pictures/Hero_Image.png" width="600">

---

## 📦 Links

- [Landing Page](https://cynthiazhangovo.github.io/MobileApp/)
- [Demo Video](YOUR_DEMO_VIDEO_LINK_HERE)
- [Download Android APK](https://github.com/CynthiaZHANGovo/MobileApp/releases/tag/v2.0)
- [GitHub Repository](https://github.com/CynthiaZHANGovo/MobileApp)

---

## Overview ✨

**Dear Environment** is a Flutter mobile application that turns real-world environmental moments into editable digital postcards.

The app does not simply take a photo and automatically output a finished image. Instead, it collects environmental context and turns it into creative material that the user can arrange, decorate, save, and share.

Users can capture or select a photo, retrieve live context such as location, weather, air quality, and time, generate postcard writing and social captions, then customise the result in an interactive Studio.

In simple terms:

**photo + place + weather + air quality + generated text + user editing**
**= one environmental keepsake 🌦️📸**

---

## Problem Statement 🚧

Mobile devices constantly collect environmental data, but this information is often fragmented across multiple applications and presented in purely functional ways.

As a result:

* environmental context is rarely experienced as meaningful
* users do not actively reflect on their surroundings
* data is consumed passively rather than creatively

This project addresses this gap by transforming environmental data into a **creative, user-driven artifact**.

---

## Understanding the User 👥

### Personas

<img src="https://github.com/CynthiaZHANGovo/MobileApp/blob/main/Pictures/User_Personas.png">

These personas define target users and guide design decisions.

### Scenario / Storyboard

<img src="https://github.com/CynthiaZHANGovo/MobileApp/blob/main/Pictures/Story_Board.png">

The storyboard illustrates how a user captures an environmental moment, edits the generated postcard, and stores it as part of a growing archive.

---

## Prototype Sketch 🎨

<img src="https://github.com/CynthiaZHANGovo/MobileApp/blob/main/Pictures/Prototype_Sketch.png">

Early prototypes explored the app as an interactive composition flow rather than a one-click image generator.

---

## How the App is Used 🕹️

1. Open the app and view the animated splash screen ᯠ_ ̫ _ᯄ

<img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/splash.png" width="150">

2. Capture a photo or choose one from the gallery

<img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/capture.png" width="150">

3. Generate live environmental context

<img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/generate.png" width="150">

4. Review the generated postcard text, metadata, and visual style

<img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/template.png" width="150">

5. Creatively edit and personalise the postcard in Studio ^›⩊‹^ ੭

<div style="display: flex; gap: 10px;">
  <img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/decor.png" width="150">
  <img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/studio.png" width="150">
  <img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/edit.png" width="150">
</div>


6. Save the postcard to the Album, export it as PNG, or share it

<div style="display: flex; gap: 10px;">
  <img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/text.png" width="150">
  <img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/share.png" width="150">
</div>

Users can create multiple postcards over time, building a personal collection of environmental moments. ฅ^•𐃷•^ฅ

<div style="display: flex; gap: 10px;">
  <img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/album.png" width="150">
  <img src="https://raw.githubusercontent.com/CynthiaZHANGovo/MobileApp/main/Pictures/output.png" width="150">
</div>

---

## System & Technical Design 🧩

### Architecture Overview

* **Input:** camera/gallery image, GPS location, time, API data
* **Processing:** environment collection, photo palette analysis, text generation, style generation
* **Interaction:** template selection, photo adjustment, caption controls
* **Output:** rendered postcard PNG, local archive, native sharing

### Data Flow

Capture / Select Image → Location → Weather + Air Quality APIs → Text + Style Generation → Studio Editing → Save / Export / Share

### Main Screens

* **LaunchSplashPage** — animated postcard-themed splash screen

* **CapturePage** — photo input and postcard generation

* **StudioPage** — the core creative interface

  * layout & composition (image position, templates)
  * stickers & decorations (add, drag, scale, delete)
  * text & captions (generate, switch, copy)

* **ArchivePage** — saved postcard Album

* **AlbumDetailPage** — detailed postcard view

### External Services

* Open-Meteo Weather API
* Open-Meteo Air Quality API
* Reverse Geocoding
* Optional remote LLM endpoint

The text generation system supports a remote LLM endpoint through `LLM_ENDPOINT` and `LLM_API_KEY`. If no endpoint is configured or the request fails, the app uses a local fallback generator.

---

## Connected Environment 🌐

The project connects:

* **User ↔ Environment** — capturing real-world moments
* **Device ↔ Sensors** — camera, GPS, touch, time
* **App ↔ External Services** — weather, air quality, reverse geocoding, optional LLM
* **Data ↔ Creativity** — turning environmental readings into text and visuals
* **User ↔ Time** — building a local archive of saved postcards

---

## Onboard Interaction 📱

### Device Features

* camera
* GPS
* touch gestures
* gallery access
* local storage
* native share sheet

### Environmental Context

* weather condition
* temperature
* air quality index
* place name
* local time
* photo colour mood

---

## Technical Stack 🧑‍💻

* **Framework:** Flutter 3.38.6 stable
* **Language:** Dart 3.10.7
* **App version:** 1.0.0+1
* **Package name:** `envpostcard_everyday`
* **Android applicationId:** `com.example.envpostcard_everyday`

### Main Packages

* `http`
* `geolocator`
* `geocoding`
* `image_picker`
* `shared_preferences`
* `path_provider`
* `share_plus`
* `google_fonts`
* `palette_generator`
* `intl`

---

## Testing 🧪

### Automated Checks

```
flutter pub get  
flutter analyze  
flutter test  
```

### Results

* `flutter analyze` — no issues found
* `flutter test` — all tests passed

### Widget Test Coverage

* splash screen loads
* transitions to Capture screen
* capture UI renders correctly

### Manual Testing Focus

* camera and gallery input
* location permission handling
* API responses
* fallback behaviour
* Studio interactions
* PNG export
* Album save and load
* sharing flow

---

## Installation ⚙️

### Requirements

* Flutter SDK 3.x
* Dart SDK
* Android Studio / VS Code
* A love for mobile app design 💚^⎚˕⎚^

### Run

```
flutter pub get  
flutter run  
```

### Optional LLM Endpoint

The app originally used a personal remote LLM for text generation, but due to cost ;( , the release version defaults to a lightweight local generator.

Developers can optionally provide their own endpoint:

```
flutter run --dart-define=LLM_ENDPOINT=your_endpoint --dart-define=LLM_API_KEY=your_key  
```

If no endpoint is set, the app will use the built-in local generator.

### Build

```
flutter build apk --release  
flutter build appbundle --release  
```

---

## Data Handling 🔐

The app uses environmental data, image data, and generated content to produce postcards.

All postcard metadata is stored locally, and rendered PNG files are saved on-device. Users control when data is saved or shared.

---

## Future Improvements 🚀

* richer editing tools
* map-based archive
* cloud sync
* improved AI integration
* more environmental data sources

---

## License 📄

This project is for academic use.

---

## Contact 📬

* GitHub: https://github.com/CynthiaZHANGovo
* Email: [cynz1223@gmail.com](mailto:cynz1223@gmail.com)

---

## Final Note 🌱

A small app about noticing the world and keeping it :) ---🐈‍⬛
