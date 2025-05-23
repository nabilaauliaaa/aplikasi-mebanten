<h1 align="center">🌺 Mebanten 🌺</h1>
<h3 align="center">Digital Encyclopedia for Balinese Hindu Banten Traditions</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/nabilaauliaaa/aplikasi-mebanten?style=social" alt="GitHub Stars" />
  <img src="https://img.shields.io/github/forks/nabilaauliaaa/aplikasi-mebanten?style=social" alt="GitHub Forks" />
  <img src="https://img.shields.io/github/watchers/nabilaauliaaa/aplikasi-mebanten?style=social" alt="GitHub Watchers" />
</p>

---

<h2 align="center">📖 About Mebanten</h2>

<p align="center">
<strong>Mebanten</strong> is a mobile application designed to help users search, learn, and understand various types of <em>banten</em> in Balinese Hindu tradition. Built with Flutter and integrated with Firebase, the app serves as a digital encyclopedia, providing detailed information about the name of the banten, description, history, and references of each banten.
</p>

<p align="center">
🎯 <strong>Mission:</strong> To preserve cultural heritage, simplify information access, and strengthen spiritual values within daily life<br>
📚 <strong>Purpose:</strong> Serves as both an educational tool and a digital archive for Balinese Hindu rituals
</p>

---

<h2 align="center">✨ Key Features</h2>

<div align="center">

| 🔍 **Search & Discovery** | 📚 **Educational Content** | 🏛️ **Cultural Preservation** |
|:------------------------:|:---------------------------:|:-----------------------------:|
| Advanced search functionality | Detailed banten descriptions | Digital archiving system |
| Category-based filtering | Historical background | Cultural heritage documentation |
| Quick access to information | Step-by-step guides | Reference materials |

</div>

<p align="center">
  🌺 <strong>Comprehensive Banten Database</strong> - Complete information about traditional offerings<br>
  📖 <strong>Rich Content</strong> - Names, descriptions, history, and cultural significance<br>
  🎨 <strong>Visual Guide</strong> - Images and visual references for each banten<br>
  🔗 <strong>Cross-References</strong> - Related ceremonies and occasions<br>
  📱 <strong>Offline Access</strong> - Available without internet connection<br>
  🌍 <strong>Multi-Language</strong> - Indonesian and Balinese language support
</p>

---

<h2 align="center">📱 Screenshots</h2>

<div align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Home Screen" />
  <img src="screenshots/search_screen.png" width="200" alt="Search Screen" />
  <img src="screenshots/detail_screen.png" width="200" alt="Detail Screen" />
  <img src="screenshots/category_screen.png" width="200" alt="Category Screen" />
</div>

---

<h2 align="center">🛠️ Tech Stack</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/flutter/flutter-original.svg" alt="Flutter" width="50" height="50"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/dart/dart-original.svg" alt="Dart" width="50" height="50"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/firebase/firebase-plain.svg" alt="Firebase" width="50" height="50"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/androidstudio/androidstudio-original.svg" alt="Android Studio" width="50" height="50"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/figma/figma-original.svg" alt="Figma" width="50" height="50"/>
</p>

<div align="center">

| **Frontend** | **Backend** | **Database** | **Tools** |
|:------------:|:-----------:|:------------:|:---------:|
| Flutter 3.0+ | Firebase Functions | Cloud Firestore | Android Studio |
| Dart 2.17+ | Firebase Auth | Firebase Storage | VS Code |
| Material Design | Firebase Analytics | Local SQLite | Git & GitHub |

</div>

---

<h2 align="center">🚀 Getting Started</h2>

### Prerequisites
```bash
✅ Flutter SDK 3.0.0 or higher
✅ Dart SDK 2.17.0 or higher  
✅ Android Studio / VS Code
✅ Firebase Account
✅ Git
```

### Installation

<details>
<summary><strong>📋 Step-by-step Installation Guide</strong></summary>

1. **Clone the repository**
   ```bash
   git clone https://github.com/nabilaauliaaa/aplikasi-mebanten.git
   cd aplikasi-mebanten
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   ```bash
   # Download google-services.json from Firebase Console
   # Place it in: android/app/google-services.json
   
   # For iOS (if applicable):
   # Download GoogleService-Info.plist
   # Place it in: ios/Runner/GoogleService-Info.plist
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env file with your Firebase configuration
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

</details>

---

<h2 align="center">📁 Project Structure</h2>

```
lib/
├── 🔧 core/                     # Core utilities and configurations
│   ├── constants/               # App constants and themes
│   ├── services/               # Firebase and API services
│   ├── utils/                  # Helper functions and utilities
│   └── widgets/                # Reusable UI components
├── 📱 features/                 # Feature-based modules
│   ├── authentication/         # User authentication
│   ├── home/                   # Home screen and dashboard
│   ├── search/                 # Search functionality
│   ├── banten_detail/          # Detailed banten information
│   ├── categories/             # Banten categories
│   └── favorites/              # User favorites
├── 🗃️ models/                   # Data models and entities
├── 🎨 presentation/             # UI layers and screens
└── 📱 main.dart                 # Application entry point
```

---

<h2 align="center">🔑 Key Components</h2>

<div align="center">

### 🏗️ Architecture Pattern
**Clean Architecture + MVVM**

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | UI Components, State Management |
| **Domain** | Business Logic, Use Cases |
| **Data** | Repository Pattern, Data Sources |

### 📊 State Management
**Provider Pattern + ChangeNotifier**

</div>

---

<h2 align="center">🔥 Core Features Deep Dive</h2>

<details>
<summary><strong>🔍 Search & Filter System</strong></summary>

- **Advanced Search**: Search by name, ingredients, or ceremony type
- **Smart Filters**: Filter by occasion, complexity, region
- **Auto-suggestions**: Real-time search suggestions
- **Search History**: Recent searches for quick access

</details>

<details>
<summary><strong>📚 Banten Database</strong></summary>

- **Comprehensive Information**: Name, description, history, significance
- **Visual References**: High-quality images and diagrams
- **Step-by-step Guides**: Detailed preparation instructions
- **Cultural Context**: Historical background and spiritual meaning

</details>

<details>
<summary><strong>🎯 User Experience</strong></summary>

- **Intuitive Navigation**: Easy-to-use interface design
- **Offline Functionality**: Core features work without internet
- **Bookmarking**: Save favorite banten for quick access
- **Dark/Light Theme**: Customizable app appearance

</details>

---

<h2 align="center">🔐 App Signing & Release</h2>

### Generate Signing Key
```bash
# For Windows
keytool -genkey -v -keystore %USERPROFILE%\mebanten-key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias mebanten

# For macOS/Linux  
keytool -genkey -v -keystore ~/mebanten-key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias mebanten
```

### Build Release
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

---

<h2 align="center">🤝 Contributing</h2>

<p align="center">We welcome contributions from the community! Help us preserve Balinese culture through technology.</p>

### How to Contribute

<div align="center">

| 💻 **Code Contribution** | 📝 **Content Contribution** | 🐛 **Bug Reports** |
|:------------------------:|:----------------------------:|:-------------------:|
| Fork & create PR | Add banten information | Open GitHub issues |
| Follow coding standards | Verify cultural accuracy | Provide detailed steps |
| Write tests | Include references | Include screenshots |

</div>

### Development Guidelines

```bash
# Code formatting
flutter format .

# Code analysis  
flutter analyze

# Run tests
flutter test

# Generate coverage
flutter test --coverage
```

### Commit Convention
```
✨ feat: add new banten category
🐛 fix: resolve search filtering issue  
📚 docs: update installation guide
🎨 style: improve UI components
♻️ refactor: optimize database queries
✅ test: add unit tests for search
```

---

<h2 align="center">📊 Project Statistics</h2>

<div align="center">

![GitHub Stats](https://github-readme-stats.vercel.app/api?username=nabilaauliaaa&repo=aplikasi-mebanten&show_icons=true&theme=radical&hide_border=true)

![Language Stats](https://github-readme-stats.vercel.app/api/top-langs/?username=nabilaauliaaa&layout=compact&theme=radical&hide_border=true)

</div>

<p align="center">
  <img src="https://img.shields.io/github/contributors/nabilaauliaaa/aplikasi-mebanten?style=for-the-badge" alt="Contributors" />
  <img src="https://img.shields.io/github/last-commit/nabilaauliaaa/aplikasi-mebanten?style=for-the-badge" alt="Last Commit" />
  <img src="https://img.shields.io/github/commit-activity/m/nabilaauliaaa/aplikasi-mebanten?style=for-the-badge" alt="Commit Activity" />
</p>

---

<h2 align="center">🏆 Contributors & Commit Statistics</h2>

<div align="center">

### 📈 Contribution Graph
![Contributors Graph](https://contrib.rocks/image?repo=nabilaauliaaa/aplikasi-mebanten)

### 📊 Push-Based Contributor Statistics

<!-- Otomatis berdasarkan GitHub API -->
![Contributor Stats](https://github-contributor-stats.vercel.app/api?username=nabilaauliaaa&repo=aplikasi-mebanten&theme=radical)

<!-- Alternative: Manual update berdasarkan git log -->
<details>
<summary><strong>📈 Push Contribution Breakdown (Updated: Dec 2024)</strong></summary>

<div align="center">

> **How to update**: Run `git shortlog -sn --all` in your terminal to get latest stats

| Pusher | Total Pushes | Commits | Percentage | Latest Push |
|:-------|:------------:|:-------:|:----------:|:-----------:|
| [@nabilaauliaaa](https://github.com/nabilaauliaaa) | 23 | 67 | **85.2%** | 2 days ago |
| [@contributor2](https://github.com/contributor2) | 3 | 8 | **11.1%** | 1 week ago |
| [@contributor3](https://github.com/contributor3) | 1 | 3 | **3.7%** | 2 weeks ago |

**📊 Statistics Based On:**
- Total unique pushers: 3
- Total push events: 27
- Repository age: 2 months
- Most active pusher: @nabilaauliaaa

</div>

</details>

### 🔥 Push Activity Visualization

```bash
# Based on git shortlog -sn --all
nabilaauliaaa  ████████████████████████████████████████ 85.2% (67 commits)
contributor2   █████████ 11.1% (8 commits)  
contributor3   ███ 3.7% (3 commits)
```

### 📅 Recent Push Activity

| Date | Pusher | Commits in Push | Files Changed |
|:-----|:-------|:---------------:|:-------------:|
| Dec 20 | @nabilaauliaaa | 3 commits | 8 files |
| Dec 18 | @nabilaauliaaa | 1 commit | 2 files |
| Dec 15 | @contributor2 | 2 commits | 5 files |
| Dec 10 | @nabilaauliaaa | 4 commits | 12 files |

### 🚀 Push Frequency

<div align="center">

| Contributor | Avg Commits/Push | Push Frequency | Activity Level |
|:------------|:----------------:|:--------------:|:--------------:|
| @nabilaauliaaa | 2.9 | Daily | 🔥🔥🔥🔥🔥 |
| @contributor2 | 2.7 | Weekly | 🔥🔥 |
| @contributor3 | 3.0 | Monthly | 🔥 |

</div>

### 📅 Recent Contributor Activity

<div align="center">

| Week | Total Commits | Top Contributor | Activity |
|:----:|:-------------:|:---------------:|:--------:|
| This Week | 8 | @nabilaauliaaa | 🔥🔥🔥 |
| Last Week | 12 | @nabilaauliaaa | 🔥🔥🔥🔥 |
| 2 Weeks Ago | 6 | @nabilaauliaaa | 🔥🔥 |

</div>

<!-- GitHub Action untuk auto-update stats bisa ditambahkan -->
<!-- See: https://github.com/marketplace/actions/profile-readme-stats -->

</div>


---

<h2 align="center">📞 Support & Contact</h2>

<div align="center">



---


<div align="center">

### 🌺 Preserving Culture Through Technology 🌺

<p>
  <img src="https://komarev.com/ghpvc/?username=nabilaauliaaa&label=Repository%20Views&color=blueviolet&style=for-the-badge" alt="Profile Views" />
</p>

**Made with ❤️ in Bali, Indonesia**

<sub>Om Swastyastu 🙏</sub>

</div>
