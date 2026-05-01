# Honestly Housing - Client Selection Management App

A Flutter application for managing home builder client selections, built with Firebase backend.

## 🏗️ Overview

Honestly Housing is a comprehensive platform that streamlines the client selection process for home builders. It allows builders to manage projects, present product options, and enables clients to make selections with real-time budget tracking.

## ✨ Features

### For Builders
- 📊 **Project Management** - Create and manage multiple construction projects
- 🏢 **Organization Branding** - Customize with your company logo and colors
- 📦 **Product Options** - Upload Good/Better/Best product options
- ✅ **Approval Tracking** - Monitor client selections and approvals
- 💬 **Client Communication** - Built-in messaging system
- 📸 **Photo Gallery** - Share project progress photos
- 📅 **Due Date Management** - Track selection deadlines

### For Clients
- 🏠 **Project Dashboard** - View project progress and budget status
- 🛍️ **Product Selection** - Browse and select from curated options
- 💰 **Budget Tracking** - Real-time allowance vs. actual cost comparison
- ✏️ **Change Requests** - Request changes to approved selections
- 💬 **Direct Messaging** - Communicate with your builder
- 📸 **Photo Access** - View project photos and progress
- 🔔 **Notifications** - Stay updated on important deadlines

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.41.6 or higher
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd honestly-housing
   ```

2. **Install dependencies**
   ```bash
   cd honestly-housing
   flutter pub get
   ```

3. **Firebase Setup**
   - Follow the [Firebase Setup Guide](FIREBASE_SETUP.md)
   - Deploy security rules: `firebase deploy`

4. **Run the app**
   ```bash
   # For Web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   ```

## 📱 Platform Support

- ✅ **Android** - Fully supported
- ✅ **Web** - Fully supported
- ⏳ **iOS** - Configuration needed (google-services.plist)

## 🗄️ Firebase Backend

### Services Used
- **Firebase Authentication** - Email/Password, Google Sign-In
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage for images
- **Firebase Performance** - Performance monitoring

### Collections Structure
```
users/
builderOrgs/
  └── options/
  └── templates/
projects/
  └── rooms/
  └── categories/
  └── items/
  └── messages/
  └── photos/
  └── changeRequests/
```

See [Firestore Data Model](docs/firestore-data-model.md) for detailed schema.

## 📚 Documentation

- [Firebase Setup Guide](FIREBASE_SETUP.md) - Complete Firebase configuration
- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Production deployment instructions
- [Backend Specification](docs/backend-spec.md) - API and data structure
- [Firestore Data Model](docs/firestore-data-model.md) - Database schema
- [App Requirements](docs/app-requirements.md) - Feature specifications

## 🔐 Security

Security rules are configured for:
- Role-based access control (Builder/Client)
- Project-based permissions
- File upload restrictions
- Data validation

Rules are located in:
- `firestore.rules` - Database security
- `storage.rules` - File storage security

## 🛠️ Development

### Project Structure
```
lib/
├── auth/              # Authentication logic
├── backend/           # Firebase backend integration
│   ├── firebase/      # Firebase configuration
│   └── schema/        # Firestore data models
├── components/        # Reusable UI components
├── flutter_flow/      # FlutterFlow utilities
└── pages/            # App screens
```

### Key Technologies
- **Flutter** - UI framework
- **Firebase** - Backend services
- **Provider** - State management
- **Go Router** - Navigation

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

## 🚀 Deployment

### Web Deployment
```bash
flutter build web --release
firebase deploy --only hosting
```

### Android Deployment
```bash
# APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

See [Deployment Guide](DEPLOYMENT_GUIDE.md) for detailed instructions.

## 🔧 Configuration

### Firebase Project
- **Project ID**: honestlyhousing-4d7f0
- **Package Name**: com.zeppelin.honestly
- **Web App**: Configured

### Environment Variables
Configure in `lib/backend/firebase/firebase_config.dart`

## 📝 Git Configuration

```bash
git config user.name "Muhammad Adnan"
git config user.email "info.adnansultan@gmail.com"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software. All rights reserved.

## 👥 Team

- **Developer**: Muhammad Adnan
- **Email**: info.adnansultan@gmail.com

## 🆘 Support

For issues and questions:
1. Check the [Documentation](docs/)
2. Review [Firebase Setup Guide](FIREBASE_SETUP.md)
3. Check [Deployment Guide](DEPLOYMENT_GUIDE.md)
4. Contact: info.adnansultan@gmail.com

## 🎯 Roadmap

- [ ] iOS platform support
- [ ] Push notifications
- [ ] Offline mode
- [ ] PDF report generation
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] Dark mode theme

## 📊 Status

- ✅ Firebase Backend Configured
- ✅ Security Rules Deployed
- ✅ Android Support
- ✅ Web Support
- ⏳ iOS Support (Pending)

## 🔗 Links

- [Firebase Console](https://console.firebase.google.com/project/honestlyhousing-4d7f0)
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)

---

Built with ❤️ using Flutter and Firebase
