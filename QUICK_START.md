# Quick Start Guide - Honestly Housing

## 🚀 Get Running in 5 Minutes

### Step 1: Install Firebase CLI (if not installed)
```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Deploy Firebase Rules
```bash
cd honestly-housing
firebase deploy
```

This will deploy:
- ✅ Firestore security rules
- ✅ Firestore indexes
- ✅ Storage security rules

### Step 4: Enable Firebase Services

Go to [Firebase Console](https://console.firebase.google.com/project/honestlyhousing-4d7f0)

1. **Authentication** → Sign-in method → Enable "Email/Password"
2. **Firestore Database** → Create database (Production mode)
3. **Storage** → Get started

### Step 5: Run the App

**For Web:**
```bash
flutter run -d chrome
```

**For Android:**
```bash
flutter run -d android
```

## ✅ Verification Checklist

- [ ] Firebase CLI installed
- [ ] Logged into Firebase
- [ ] Rules deployed successfully
- [ ] Authentication enabled
- [ ] Firestore database created
- [ ] Storage enabled
- [ ] App runs on web
- [ ] App runs on Android

## 🎯 What's Already Configured

✅ Firebase project connected (honestlyhousing-4d7f0)
✅ Android configuration (google-services.json)
✅ Web configuration (firebase_config.dart)
✅ Security rules written (firestore.rules, storage.rules)
✅ Firestore indexes defined (firestore.indexes.json)
✅ Git user configured

## 📝 Create Test Users

### In Firebase Console → Authentication → Users → Add User

**Builder User:**
- Email: builder@test.com
- Password: test123456

**Client User:**
- Email: client@test.com
- Password: test123456

### Then in Firestore → users collection → Add Document

**For Builder:**
```json
{
  "uid": "[copy from Authentication]",
  "email": "builder@test.com",
  "displayName": "Test Builder",
  "role": "builder",
  "builderOrgId": "test-org-001",
  "projectIds": [],
  "phone": "+1234567890",
  "createdAt": [Timestamp],
  "updatedAt": [Timestamp],
  "lastLoginAt": [Timestamp],
  "notificationPreferences": {
    "email": true,
    "push": true
  }
}
```

**For Client:**
```json
{
  "uid": "[copy from Authentication]",
  "email": "client@test.com",
  "displayName": "Test Client",
  "role": "client",
  "builderOrgId": null,
  "projectIds": [],
  "phone": "+1234567890",
  "createdAt": [Timestamp],
  "updatedAt": [Timestamp],
  "lastLoginAt": [Timestamp],
  "notificationPreferences": {
    "email": true,
    "push": true
  }
}
```

## 🔧 Common Commands

```bash
# Check Flutter setup
flutter doctor

# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Build for production
flutter build web --release
flutter build apk --release

# Deploy to Firebase
firebase deploy

# View Firebase logs
firebase functions:log
```

## 🆘 Troubleshooting

### "Firebase not initialized"
```bash
firebase login
firebase use honestlyhousing-4d7f0
```

### "Permission denied" in Firestore
- Check rules are deployed: `firebase deploy --only firestore:rules`
- Verify user has correct role in Firestore
- Check user's projectIds array

### "Flutter command not found"
- Install Flutter SDK: https://flutter.dev/docs/get-started/install
- Add Flutter to PATH

### "Android build fails"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

## 📚 Next Steps

1. ✅ Read [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed configuration
2. ✅ Read [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for production deployment
3. ✅ Review [docs/](docs/) for app specifications
4. ✅ Create test data in Firestore
5. ✅ Test authentication flow
6. ✅ Test builder and client roles

## 🎉 You're Ready!

Your app is now configured and ready to run on both Web and Android platforms with a fully functional Firebase backend!

For detailed documentation, see:
- [README.md](README.md) - Project overview
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Complete Firebase setup
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Production deployment
