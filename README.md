# 👕 AI Closet

AI Closet is a **Flutter-based personal wardrobe management app** that helps users digitally organize their clothing and generate outfit combinations automatically.

The app works **entirely offline**, storing clothing images locally on the device and generating outfits using **smart color theory rules**.

This project was built as a **personal wardrobe assistant** to simplify daily outfit selection.

---

# ✨ Features

## 👗 Digital Closet
- Upload photos of clothing items
- Categorize clothes into:
  - Shirts
  - Pants
  - Shoes
  - Jackets
  - Caps / Hats
- Filter items by category
- Delete clothing items
- View all clothing in a clean grid layout

---

## 🎨 Smart Outfit Generator
Generate outfit combinations using **fashion-based color harmony rules**.

The generator:
1. Selects a **base shirt**
2. Finds **compatible pants**
3. Chooses **neutral shoes**
4. Optionally adds a **jacket**
5. Optionally adds a **cap**

This ensures outfits look visually balanced instead of randomly combined.

Example generated outfit:

```
White Shirt
Beige Pants
White Sneakers
Navy Jacket
Black Cap
```

---

## 💾 Save Outfits
Users can:
- Save generated outfits
- View saved outfits later
- Delete saved outfits anytime

---

## 📤 Share Outfit Images
Create a **shareable image collage** of the generated outfit and send it to friends.

Supported via:
- Share sheet
- Messaging apps
- Social media

---

## 📱 Modern UI
The app includes:
- Modern home dashboard
- Clothing statistics
- Floating action buttons
- Clean fashion-inspired layout
- Mobile optimized interface

---

# 🧠 Outfit Generation Logic

The outfit generator uses **rule-based color harmony**.

## Neutral Colors

Neutral colors match most outfits:

```
Black
White
Grey
Beige
Brown
Navy
```

---

## Color Compatibility

Examples:

```
Black → White, Grey, Beige, Blue
White → Black, Blue, Beige
Blue → White, Grey, Beige
Beige → Brown, White, Navy
```

---

## Outfit Creation Process

```
Step 1 → Select Shirt (Base)
Step 2 → Find Compatible Pants
Step 3 → Prefer Neutral Shoes
Step 4 → Add Matching Jacket (optional)
Step 5 → Add Matching Cap (optional)
```

This produces more natural outfits.

---

# 📦 Tech Stack

| Technology | Purpose |
|--------|--------|
Flutter | Cross-platform mobile development |
Dart | Programming language |
SQLite (sqflite_common_ffi) | Local database |
Image Picker | Upload clothing photos |
Share Plus | Share outfit images |
Path Provider | File storage |

---

# 🗂 Project Structure

```
lib/
│
├── data/
│   ├── database/
│   │   └── db_helper.dart
│   │
│   ├── models/
│   │   ├── clothing_item.dart
│   │   └── outfit.dart
│   │
│   └── repositories/
│       ├── clothing_repository.dart
│       └── outfit_repository.dart
│
├── services/
│   ├── image_storage_service.dart
│   └── outfit_generator_service.dart
│
├── presentation/
│   └── screens/
│       ├── home_screen.dart
│       ├── closet_screen.dart
│       ├── add_item_screen.dart
│       ├── generate_screen.dart
│       └── saved_outfits_screen.dart
│
└── main.dart
```

---

# 📷 Screenshots

*(Add screenshots here once available)*

Example:

```
screenshots/
   home_screen.png
   closet_screen.png
   generator_screen.png
```

Then reference them:

```
![Home Screen](screenshots/home_screen.png)
```

---

# 🚀 Getting Started

## 1️⃣ Clone the repository

```bash
git clone https://github.com/yourusername/ai-closet.git
```

---

## 2️⃣ Navigate into project

```bash
cd ai_closet
```

---

## 3️⃣ Install dependencies

```bash
flutter pub get
```

---

## 4️⃣ Run the app

```bash
flutter run
```

---

# 📦 Build APK

To generate an Android APK:

```bash
flutter build apk --release
```

The APK will be located at:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

# 📱 Supported Platforms

Currently tested on:

- Android
- Windows Desktop

Flutter also supports:

- iOS
- Web
- macOS
- Linux

---

# 🛠 Future Improvements

Potential upgrades:

- Background removal for clothing images
- AI-based outfit recommendations
- Weather-based outfit suggestions
- Style presets (casual, formal, streetwear)
- Outfit scoring system
- Wardrobe analytics
- Cloud sync / backup
- Daily outfit suggestions

---

# 🔒 Privacy

AI Closet stores **all data locally on the device**.

No user data is uploaded or sent to any external server.

---

# 📄 License

MIT License

---

# 👤 Author

Developed by:

**Himanshu Kumar**

Computer Science (Cybersecurity)

---

# ⭐ Contributing

Contributions are welcome.

To contribute:

1. Fork the repository
2. Create a new feature branch
3. Submit a pull request

---

# 💡 Inspiration

This project was created to solve a simple everyday problem:

**"What should I wear today?"**

AI Closet helps users visualize outfits using their own wardrobe while keeping everything private and offline.