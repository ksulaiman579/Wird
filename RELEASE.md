# Releasing Wird

Three distribution channels (see `IMPLEMENTATION_PLAN.md`'s Distribution
section for the full rationale): the PWA (auto-deployed on every push —
see `README.md`'s "Deploying to Vercel"), a direct APK on GitHub Releases,
and F-Droid. This file covers the two Android paths.

## Quick debug APK for device testing

`.github/workflows/build-apk.yml` builds a **debug-signed** APK (Flutter's
default debug key — fine for sideloading onto your own device, not a
real release) on GitHub Actions, since building Android at all needs the
Android SDK, which no local dev container in this project's workflow has
had installed. Trigger it manually from the repo's Actions tab ("Build
debug APK" → "Run workflow"), or push a `v*` tag; download the
`wird-debug-apk` artifact from the finished run. This is for quick
testing only — it's not the signed release APK covered below, and Android
will warn that the app is from an "unknown developer" since it's
debug-signed.

## Building a signed release APK

Flutter's default `android/app/build.gradle.kts` signs release builds with
the debug key (fine for `flutter run --release` locally, **not** fine for
anything distributed). To ship a real release:

1. **Generate a signing key** (once, on your own machine — never commit
   this key or its passwords):
   ```sh
   keytool -genkey -v -keystore ~/wird-release-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias wird
   ```
2. **Create `android/key.properties`** (already gitignored via
   `android/`'s standard Flutter `.gitignore` rules — double-check before
   committing anything):
   ```properties
   storePassword=<password you set above>
   keyPassword=<password you set above>
   keyAlias=wird
   storeFile=/absolute/path/to/wird-release-key.jks
   ```
3. **Wire it into `android/app/build.gradle.kts`** — add above the
   `android {` block:
   ```kotlin
   val keystoreProperties = java.util.Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
   }
   ```
   and replace the `release { signingConfig = signingConfigs.getByName("debug") }`
   block with a real `signingConfigs.create("release") { ... }` reading
   from `keystoreProperties`, per
   [Flutter's own signing guide](https://docs.flutter.dev/deployment/android#signing-the-app).
   This repo intentionally ships with debug signing until a real key
   exists — don't add one speculatively.
4. **Build:**
   ```sh
   flutter build apk --release
   # output: build/app/outputs/flutter-apk/app-release.apk
   ```
5. **Attach to a GitHub Release:** tag the commit (`git tag v1.0.0 && git
   push --tags`), then create a release on GitHub and upload the APK as a
   release asset.

Bump `pubspec.yaml`'s `version:` (both the `x.y.z` name and the `+N` build
number) before each release — both `flutter build apk` and `flutter build
web` read versioning from there.

## F-Droid

F-Droid builds from source itself (it doesn't accept pre-built APKs) using
a build recipe submitted to the [`fdroiddata`](https://gitlab.com/fdroid/fdroiddata)
repository — you don't upload anything to F-Droid directly.

### Build recipe draft

A draft lives at `metadata/io.github.ksulaiman579.wird.yml` in this repo
(F-Droid's own repo expects it at `metadata/<applicationId>.yml` in
*their* `fdroiddata` repo — copy it there as part of submission, don't
expect F-Droid to read it from here). Review/adjust `AuthorName`,
`CurrentVersion`/`CurrentVersionCode`, and the `commit:` tag before
submitting — F-Droid's own maintainers will also review and may request
changes.

Once a real PayPal URL replaces the placeholder in
`lib/core/donations.dart` (see "Donations" below), add a matching
`Donate:` field to the recipe before submitting — not added yet since
F-Droid metadata should point at a real, live URL.

### Submission steps

1. Tag and push a release commit (e.g. `v1.0.0`) — F-Droid builds from a
   specific git tag/commit, not a moving branch.
2. Fork [`fdroid/fdroiddata`](https://gitlab.com/fdroid/fdroiddata) on
   GitLab.
3. Add `metadata/io.github.ksulaiman579.wird.yml` (adapted from this
   repo's draft) to your fork.
4. Open a merge request against `fdroiddata`, or — often smoother for a
   first submission — open a **Request For Packaging (RFP)** issue on
   `fdroiddata` first and let a F-Droid maintainer prepare/verify the
   recipe with you.
5. F-Droid's CI does a reproducible build check (rebuilds from source and
   diffs against expectations) before the app appears in the F-Droid
   client. This can take a few review cycles — respond to any CI/reviewer
   feedback on the MR.
6. Once merged, the app appears in F-Droid's repo index (updates propagate
   to users' F-Droid clients on their own periodic refresh, no action
   needed after merge).

### Reproducible-build notes

- No proprietary dependencies, no Google Play Services, no analytics/ads —
  confirmed in `DATA_SOURCES.md`'s dependency-license audit (M9.1).
- `applicationId`/`namespace` is `io.github.ksulaiman579.wird` (M9.2) —
  F-Droid's own recommended convention for a GitHub-hosted app without a
  custom domain.
- The build needs network access during F-Droid's build step only to
  resolve Gradle/Flutter-pub dependencies (standard for any Flutter app);
  no network access is needed or used at *runtime* beyond what's already
  documented (recitation audio streaming, optional online prayer-time
  lookups) — everything else works fully offline.

## Fastlane metadata

`fastlane/metadata/android/en-US/` holds the listing text both F-Droid and
(if ever needed) Google Play read: `title.txt`, `short_description.txt`,
`full_description.txt`, `changelogs/<versionCode>.txt`, and
`images/icon.png`. Add a new `changelogs/<versionCode>.txt` with every
release. Phone screenshots (`images/phoneScreenshots/`) aren't included
yet — add real device/emulator screenshots before the first public
release; F-Droid doesn't require them but they help the listing.

## Donations

`lib/core/donations.dart` holds the PayPal URL shown on the "Support this
project" card (Al-Manhaj tab, moved there from About in M16.1) and in
`README.md`'s badges. It's a
placeholder (`REPLACE_ME`) until the app's maintainer sets up a real
PayPal.me page. The "Buy Me a Coffee" button/badge intentionally links to
the same PayPal URL — there's no separate Buy Me a Coffee account, it's
just a second, more casual-sounding call to action. To go live:

1. Create the PayPal.me page.
2. Update `DonationLinks.payPal` in `lib/core/donations.dart`.
3. Update the two badge URLs in `README.md`.
4. Add a `Donate:` field to `metadata/io.github.ksulaiman579.wird.yml`
   (see the F-Droid section above) before/when submitting to `fdroiddata`.
