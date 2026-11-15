# flutter_local_notifications stores scheduled notifications with Gson and
# needs its own classes and Gson's generic type info kept, or scheduled
# notifications fail to (de)serialise after shrinking.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.** { *; }

# background_downloader and android_alarm_manager_plus run work from
# background services/receivers declared in the manifest.
-keep class com.bbflight.background_downloader.** { *; }
-keep class dev.fluttercommunity.plus.androidalarmmanager.** { *; }

# Play Core references in the Flutter embedding (deferred components),
# not used by this app.
-dontwarn com.google.android.play.core.**
