# Unshipped translations

ARB files for languages the app doesn't offer yet (only en, ar, ur, hi,
bn, ml, fil are in the language picker). Kept here, outside `lib/l10n/`,
so they aren't compiled into the app (~3 MB of generated code).

Most values are still English and all are 16 keys behind. To ship one:
fill it in, move it back to `lib/l10n/`, add its code to `shipLocaleCodes`
in `lib/core/prefs/app_language_provider.dart`, and walk it on device.
