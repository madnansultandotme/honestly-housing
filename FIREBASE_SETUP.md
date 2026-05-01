# Firebase Backend Setup - Honestly Housing

## ✅ Configuration Status

### Firebase Project
- **Project ID**: honestlyhousing-4d7f0
- **Project Number**: 656663435593
- **Storage Bucket**: honestlyhousing-4d7f0.firebasestorage.app

### Platform Support
- ✅ **Web**: Configured in `lib/backend/firebase/firebase_config.dart`
- ✅ **Android**: Configured with `android/app/google-services.json`

### Firebase Services Enabled
- ✅ Firebase Authentication (Email/Password)
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firebase Performance Monitoring
- ✅ Google Sign-In

## 📦 Dependencies Installed

All Firebase dependencies are properly configured in `pubspec.yaml`:
- firebase_core: 3.14.0
- firebase_auth: 5.6.0
- cloud_firestore: 5.6.9
- firebase_performance: 0.10.1+7
- google_sign_in: 6.3.0

## 🗄️ Firestore Collections

### Root Collections
1. **users** - User profiles and authentication
2. **builderOrgs** - Builder organization information
3. **projects** - Project details and configuration

### Subcollections (under projects)
4. **rooms** - Individual rooms within projects
5. **categories** - Selection categories with budgets
6. **items** - Selection items (products)
7. **messages** - Project chat messages
8. **photos** - Project photo gallery
9. **changeRequests** - Client change requests

### Subcollections (under builderOrgs)
10. **options** - Curated product options (Good/Better/Best)
11. **templates** - Saved project templates

### Subcollections (under users)
12. **notifications** - User notifications

## 🔐 Security Rules Configuration

Firebase security rules are already configured in the project:

### Files Created
- ✅ `firestore.rules` - Firestore database security rules
- ✅ `storage.rules` - Firebase Storage security rules
- ✅ `firestore.indexes.json` - Firestore composite indexes
- ✅ `firebase.json` - Firebase project configuration

### Deploy Rules to Firebase

```bash
# Deploy all Firebase configurations
firebase deploy

# Or deploy individually
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only storage
```

### Key Security Features

**Firestore Rules:**
- Role-based access control (builder/client)
- Project-based permissions
- Builder organization isolation
- Client approval restrictions
- Message and photo access control

**Storage Rules:**
- File size validation (10MB images, 50MB documents)
- File type validation (images and documents only)
- Project-based access control
- Builder organization isolation

## 🚀 Running the App

### For Web
```bash
cd honestly-housing
flutter run -d chrome
```

### For Android
```bash
cd honestly-housing
flutter run -d android
```

### Build for Production

#### Web
```bash
flutter build web --release
```

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## 📝 Next Steps

1. **Set up Firebase Security Rules** in Firebase Console
2. **Set up Firebase Storage Rules** in Firebase Console
3. **Enable Email/Password Authentication** in Firebase Console
4. **Create Firestore Indexes** as needed (Firebase will prompt you)
5. **Test authentication flow**
6. **Create sample data** for testing

## 🔍 Testing Firebase Connection

Run this command to verify the setup:
```bash
flutter run -d chrome --dart-define=FLUTTER_WEB_USE_SKIA=true
```

## 📱 Android Package Name
- **Package**: com.zeppelin.honestly

## 🌐 Web Configuration
- **Auth Domain**: honestlyhousing-4d7f0.firebaseapp.com
- **API Key**: AIzaSyBJ9n3Mjqx0Ol6FSg35i8fTFRxnnRjzHmE

## ⚠️ Important Notes

1. **Never commit sensitive keys** to version control
2. **Set up environment-specific configurations** for dev/staging/prod
3. **Enable Firebase App Check** for production
4. **Set up Firebase Analytics** for user tracking
5. **Configure Firebase Cloud Messaging** for push notifications
6. **Set up proper error logging** with Firebase Crashlytics

## 📚 Documentation References

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Data Model](./docs/firestore-data-model.md)
- [Backend Specification](./docs/backend-spec.md)
