# Firebase Rules Deployment Instructions

## 📋 Overview

This document provides step-by-step instructions for deploying Firebase security rules and configurations to your Firebase project.

## ✅ Files Ready for Deployment

All Firebase configuration files have been created in your project:

```
honestly-housing/
├── .firebaserc                  ✅ Firebase project configuration
├── firebase.json                ✅ Firebase services configuration
├── firestore.rules              ✅ Firestore security rules
├── firestore.indexes.json       ✅ Firestore composite indexes
└── storage.rules                ✅ Storage security rules
```

## 🚀 Deployment Steps

### Step 1: Install Firebase CLI (if not already installed)

```bash
npm install -g firebase-tools
```

Verify installation:
```bash
firebase --version
```

### Step 2: Login to Firebase

```bash
firebase login
```

This will open a browser window for authentication.

### Step 3: Verify Project Configuration

```bash
cd honestly-housing
firebase use
```

Expected output:
```
Active Project: honestlyhousing-4d7f0 (honestlyhousing-4d7f0)
```

If not set, run:
```bash
firebase use honestlyhousing-4d7f0
```

### Step 4: Deploy All Firebase Configurations

```bash
firebase deploy
```

This will deploy:
- ✅ Firestore security rules
- ✅ Firestore indexes
- ✅ Storage security rules
- ✅ Hosting configuration (if web build exists)

### Step 5: Deploy Individual Components (Optional)

If you want to deploy specific components:

**Deploy only Firestore rules:**
```bash
firebase deploy --only firestore:rules
```

**Deploy only Firestore indexes:**
```bash
firebase deploy --only firestore:indexes
```

**Deploy only Storage rules:**
```bash
firebase deploy --only storage
```

**Deploy only Hosting:**
```bash
firebase deploy --only hosting
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

### View Deployment History

Go to Firebase Console:
1. Open [Firebase Console](https://console.firebase.google.com/project/honestlyhousing-4d7f0)
2. Navigate to **Firestore Database** → **Rules** tab
3. Check the deployment timestamp

## 📊 What Gets Deployed

### Firestore Security Rules

**File**: `firestore.rules`

**Features**:
- Role-based access control (builder/client)
- Project-based permissions
- Builder organization isolation
- Field-level update restrictions for clients
- Subcollection access control

**Key Rules**:
- Users can read their own profile
- Builders can read users in their organization
- Clients can only update specific item fields (approval-related)
- Messages and photos require project access
- Change requests can only be created by clients

### Firestore Indexes

**File**: `firestore.indexes.json`

**Total Indexes**: 24 composite indexes

**Key Indexes**:
- User queries by role and organization
- Project queries by status and builder
- Item queries by category, status, and due date
- Message queries by timestamp
- Photo queries by category and timestamp
- Notification queries by read status

### Storage Security Rules

**File**: `storage.rules`

**Features**:
- File size validation (10MB for images, 50MB for documents)
- File type validation (images and documents only)
- Project-based access control
- Builder organization isolation

**Protected Paths**:
- `/projects/{projectId}/photos/` - Project photos
- `/options/{builderOrgId}/` - Product option images
- `/builderOrgs/{orgId}/logo.png` - Organization logos
- `/messages/{projectId}/{messageId}/` - Message attachments

## ⚠️ Important Notes

### Before Deployment

1. **Backup existing rules** (if any):
   ```bash
   firebase firestore:rules:get > firestore.rules.backup
   firebase storage:rules:get > storage.rules.backup
   ```

2. **Test rules locally** (optional):
   ```bash
   firebase emulators:start --only firestore,storage
   ```

3. **Review rules** in the files before deploying

### After Deployment

1. **Enable Authentication**:
   - Go to Firebase Console → Authentication
   - Enable Email/Password sign-in method
   - Enable Google sign-in (optional)

2. **Create Firestore Database**:
   - Go to Firebase Console → Firestore Database
   - Click "Create database"
   - Choose "Production mode" (rules are already configured)
   - Select your preferred location

3. **Enable Storage**:
   - Go to Firebase Console → Storage
   - Click "Get started"
   - Use production mode (rules are already configured)

## 🧪 Testing Deployment

### Test Firestore Rules

1. Create a test user in Authentication
2. Try to read/write data from the app
3. Verify permissions work as expected

### Test Storage Rules

1. Try to upload a photo to a project
2. Verify file size and type restrictions
3. Check access control works

### Common Test Scenarios

**As Builder:**
- ✅ Can create projects
- ✅ Can add items to projects
- ✅ Can upload product options
- ✅ Can read all project data
- ❌ Cannot access other organizations' data

**As Client:**
- ✅ Can read assigned projects
- ✅ Can approve items (update specific fields)
- ✅ Can send messages
- ✅ Can upload photos
- ❌ Cannot create projects
- ❌ Cannot delete items
- ❌ Cannot access other projects

## 🔧 Troubleshooting

### Error: "Not logged in"
```bash
firebase login
```

### Error: "No project active"
```bash
firebase use honestlyhousing-4d7f0
```

### Error: "Permission denied"
Check that you have Owner or Editor role in the Firebase project.

### Error: "Invalid rules syntax"
```bash
firebase firestore:rules:validate
```

### Error: "Index already exists"
This is normal. Firebase will skip existing indexes.

### Rules not taking effect
- Wait 1-2 minutes for rules to propagate
- Clear app cache and restart
- Check Firebase Console for deployment status

## 📝 Deployment Checklist

Before deploying:
- [ ] Firebase CLI installed
- [ ] Logged into Firebase
- [ ] Correct project selected
- [ ] Rules files reviewed
- [ ] Backup of existing rules (if any)

After deploying:
- [ ] Deployment successful (no errors)
- [ ] Rules visible in Firebase Console
- [ ] Indexes created in Firebase Console
- [ ] Authentication enabled
- [ ] Firestore database created
- [ ] Storage enabled
- [ ] Test users created
- [ ] Rules tested with app

## 🎯 Expected Output

When you run `firebase deploy`, you should see:

```
=== Deploying to 'honestlyhousing-4d7f0'...

i  deploying firestore, storage
i  firestore: reading indexes from firestore.indexes.json...
i  cloud.firestore: checking firestore.rules for compilation errors...
✔  cloud.firestore: rules file firestore.rules compiled successfully
i  firestore: uploading rules firestore.rules...
i  storage: checking storage.rules for compilation errors...
✔  storage: rules file storage.rules compiled successfully
i  storage: uploading rules storage.rules...
✔  firestore: deployed indexes in firestore.indexes.json successfully
✔  firestore: released rules firestore.rules to cloud.firestore
✔  storage: released rules storage.rules

✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/honestlyhousing-4d7f0/overview
```

## 🔄 Updating Rules

To update rules in the future:

1. Edit the rules files (`firestore.rules`, `storage.rules`)
2. Test locally with emulators (optional)
3. Deploy: `firebase deploy`
4. Verify in Firebase Console
5. Test with the app

## 📚 Additional Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Indexes Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)

## 🆘 Need Help?

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
3. Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
4. Contact: info.adnansultan@gmail.com

---

**Ready to deploy?** Run `firebase deploy` from the `honestly-housing` directory!
