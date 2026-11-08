# Tutomato backend: setup (Windows + Android Studio)

Do these in order. Work on a branch so your teammates' UI work isn't disturbed.

## 1. Branch

In the Android Studio **Terminal** (project root, `C:\flutter_proj\Tutomato`):

```bash
git checkout -b feature/backend
```

## 2. Create the Firebase project (browser, ~5 min)

1. Go to <https://console.firebase.google.com> > **Add project** > name it `tutomato` (Analytics can be off).
2. **Build > Authentication > Get started > Email/Password > Enable > Save.**
3. **Build > Firestore Database > Create database** > pick the region closest to you (e.g. `asia-southeast1`) > start in **production mode**.
4. In Firestore, open the **Rules** tab, paste in the contents of `firestore.rules` from this folder, and click **Publish**.

## 3. Connect Flutter to Firebase

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id> --platforms=android
```

This creates `lib/firebase_options.dart` and `android/app/google-services.json`.
(If `npm` isn't installed, install Node.js from nodejs.org first. Close and reopen the Terminal after installing anything.)

## 4. Add the packages

```bash
flutter pub add firebase_core firebase_auth cloud_firestore shared_preferences flutter_riverpod:^2.6.1
```

`flutter_riverpod` is pinned to 2.x because the code is written for it.

## 5. Copy these files into the project

Unzip this package **into the project root** and let it merge/overwrite:

```
lib/            <- replaces the default main.dart, adds everything else
test/logic_test.dart
docs/BACKEND.md
firestore.rules
```

Then **delete `test/widget_test.dart`** (the default Flutter counter test; it no longer applies).

## 6. If the build complains about minSdk

Firebase needs Android API 23 or higher. Open `android/app/build.gradle.kts` (or `build.gradle`) and set:

```kotlin
defaultConfig {
    minSdk = 23
}
```

## 7. Check it

```bash
flutter pub get
flutter analyze
flutter test
```

`flutter test` runs the unit tests for the rules (streaks, points, ripeness, task groups, records, validators). **If `analyze` or `test` shows errors, paste them to Claude** and I'll fix them.

## 8. Try it on the emulator

Press the green Run button. You'll see a plain "backend playground" (not the real design). Try this:

1. **Sign up** (name, email, password such as `tomato123`). Check Firebase Console > Authentication and Firestore: your user and a `users/<uid>` document appear.
2. Add a task. Start a focus session (defaults are 1 min / 1 min / 2 rounds so it's quick).
3. Let it finish: you get +1 point, ripeness +8%, streak 1.
4. Start another and press the emulator's **Home** button: the session breaks, no points (lock-in).
5. Buy something in the shop once you have enough points (cheapest is 60). Tip: set the focus minutes to 25 once to earn 25 at a time.
6. Create a second account on a second emulator (or log out/in), swap invite codes, and try Cheer.

## 9. Commit and open a pull request

```bash
git add .
git commit -m "Add backend: auth, timer, points, tasks, shop, friends"
git push -u origin feature/backend
```

Then open a pull request on GitHub for a teammate to review.
