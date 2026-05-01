# Firebase Deployment Guide - Honestly Housing

## 📋 Prerequisites

1. **Firebase CLI** installed globally
   ```bash
   npm install -g firebase-tools
   ```

2. **Flutter SDK** installed and configured
   ```bash
   flutter doctor
   ```

3. **Firebase Project** created at [Firebase Console](https://console.firebase.google.com/)

## 🔐 Firebase Authentication

1. Login to Firebase CLI:
   ```bash
   firebase login
   ```

2. Initialize Firebase in your project (if not already done):
   ```bash
   cd honestly-housing
   firebase init
   ```
   
   Select:
   - ✅ Firestore
   - ✅ Storage
   - ✅ Hosting (optional, for web deployment)

3. Select your Firebase project: `honestlyhousing-4d7f0`

## 🗄️ Deploy Firestore Rules and Indexes

### Deploy Security Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

### Deploy Storage Rules
```bash
firebase deploy --only storage
```

### Deploy Everything
```bash
firebase deploy
```

## 🔧 Enable Firebase Services

### 1. Enable Authentication

Go to Firebase Console → Authentication → Sign-in method

Enable:
- ✅ **Email/Password** (Required)
- ✅ **Google** (Optional, already configured)
- ✅ **Apple** (Optional, for iOS)

### 2. Enable Firestore Database

Go to Firebase Console → Firestore Database

1. Click "Create database"
2. Choose **Production mode** (rules are already configured)
3. Select your preferred location (e.g., `us-central1`)

### 3. Enable Firebase Storage

Go to Firebase Console → Storage

1. Click "Get started"
2. Use the security rules from `storage.rules`
3. Select the same location as Firestore

### 4. Enable Firebase Performance Monitoring

Go to Firebase Console → Performance

1. Click "Get started"
2. Follow the setup instructions

## 📱 Platform-Specific Setup

### Android Setup

1. **Verify google-services.json**
   - File location: `android/app/google-services.json`
   - Package name: `com.zeppelin.honestly`

2. **Build Android APK**
   ```bash
   flutter build apk --release
   ```

3. **Build Android App Bundle (for Play Store)**
   ```bash
   flutter build appbundle --release
   ```

4. **Test on Android device**
   ```bash
   flutter run -d android
   ```

### Web Setup

1. **Verify Firebase Config**
   - File location: `lib/backend/firebase/firebase_config.dart`
   - Web config is already set up

2. **Build for Web**
   ```bash
   flutter build web --release
   ```

3. **Deploy to Firebase Hosting**
   ```bash
   firebase deploy --only hosting
   ```

4. **Test locally**
   ```bash
   flutter run -d chrome
   ```

## 🔍 Verify Deployment

### Check Firestore Rules
```bash
firebase firestore:rules:get
```

### Check Storage Rules
```bash
firebase storage:rules:get
```

### Test Security Rules
```bash
firebase emulators:start --only firestore,storage
```

## 📊 Create Initial Data

### 1. Create a Builder Organization

```javascript
// In Firebase Console → Firestore → Add Document
// Collection: builderOrgs
{
  "name": "Example Builders Inc",
  "email": "contact@examplebuilders.com",
  "phone": "+1234567890",
  "address": "123 Builder St, City, State",
  "branding": {
    "logoUrl": null,
    "primaryColor": "#1976D2",
    "accentColor": "#FF9800"
  },
  "settings": {
    "defaultAllowanceType": "fixed",
    "defaultCategories": [
      "Flooring",
      "Lighting",
      "Plumbing",
      "Paint",
      "Tile",
      "Countertops",
      "Hardware"
    ]
  },
  "createdAt": [Firebase Timestamp],
  "updatedAt": [Firebase Timestamp]
}
```

### 2. Create a Builder User

```javascript
// First create user in Authentication
// Then in Firestore → users collection
{
  "uid": "[Firebase Auth UID]",
  "email": "builder@example.com",
  "displayName": "John Builder",
  "role": "builder",
  "builderOrgId": "[builderOrg document ID]",
  "projectIds": [],
  "phone": "+1234567890",
  "createdAt": [Firebase Timestamp],
  "updatedAt": [Firebase Timestamp],
  "lastLoginAt": [Firebase Timestamp],
  "notificationPreferences": {
    "email": true,
    "push": true
  }
}
```

### 3. Create a Client User

```javascript
// First create user in Authentication
// Then in Firestore → users collection
{
  "uid": "[Firebase Auth UID]",
  "email": "client@example.com",
  "displayName": "Jane Client",
  "role": "client",
  "builderOrgId": null,
  "projectIds": [],
  "phone": "+1234567890",
  "createdAt": [Firebase Timestamp],
  "updatedAt": [Firebase Timestamp],
  "lastLoginAt": [Firebase Timestamp],
  "notificationPreferences": {
    "email": true,
    "push": true
  }
}
```

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Run on Emulator
```bash
# Android
flutter run -d android

# Web
flutter run -d chrome
```

### Test Firebase Connection
```bash
flutter run --dart-define=FLUTTER_WEB_USE_SKIA=true
```

## 🚀 Production Deployment Checklist

- [ ] Firebase rules deployed
- [ ] Firestore indexes deployed
- [ ] Storage rules deployed
- [ ] Authentication methods enabled
- [ ] Initial builder organization created
- [ ] Test users created (builder and client)
- [ ] App tested on Android
- [ ] App tested on Web
- [ ] Performance monitoring enabled
- [ ] Error logging configured
- [ ] Analytics enabled (optional)
- [ ] App Check enabled (recommended for production)

## 🔒 Security Best Practices

1. **Enable App Check** (Production)
   ```bash
   firebase app-check:enable
   ```

2. **Set up Firebase Security Rules** (Already done)
   - Firestore rules in `firestore.rules`
   - Storage rules in `storage.rules`

3. **Environment Variables**
   - Never commit API keys to version control
   - Use environment-specific configurations

4. **Rate Limiting**
   - Configure in Firebase Console → App Check

5. **Monitoring**
   - Enable Firebase Crashlytics
   - Set up alerts for security rule violations

## 📝 Useful Commands

### Firebase CLI
```bash
# List projects
firebase projects:list

# Switch project
firebase use honestlyhousing-4d7f0

# View current project
firebase use

# Open Firebase Console
firebase open

# View logs
firebase functions:log
```

### Flutter
```bash
# Clean build
flutter clean && flutter pub get

# Check for issues
flutter doctor -v

# Analyze code
flutter analyze

# Format code
flutter format .
```

## 🆘 Troubleshooting

### Issue: Rules deployment fails
```bash
# Check rules syntax
firebase firestore:rules:validate

# View current rules
firebase firestore:rules:get
```

### Issue: Authentication not working
1. Check Firebase Console → Authentication → Sign-in method
2. Verify email/password is enabled
3. Check `google-services.json` (Android) or Firebase config (Web)

### Issue: Firestore permission denied
1. Check security rules are deployed
2. Verify user has correct role in Firestore
3. Check user's `projectIds` array

### Issue: Storage upload fails
1. Check storage rules are deployed
2. Verify file size limits
3. Check file type restrictions

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security)

## 🔄 Continuous Deployment

### GitHub Actions (Optional)

Create `.github/workflows/firebase-deploy.yml`:

```yaml
name: Deploy to Firebase

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.6'
      
      - name: Install dependencies
        run: flutter pub get
        working-directory: ./honestly-housing
      
      - name: Build web
        run: flutter build web --release
        working-directory: ./honestly-housing
      
      - name: Deploy to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only hosting
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

Generate Firebase token:
```bash
firebase login:ci
```

Add the token to GitHub Secrets as `FIREBASE_TOKEN`.
