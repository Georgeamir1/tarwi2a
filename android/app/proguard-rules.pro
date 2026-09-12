# Flutter ProGuard Rules

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve Flutter engine annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Supabase / GoTrue / PostgREST (Dart serialization via reflection/isolate if any)
-dontwarn com.supabase.**

# Sentry
-keepattributes LineNumberTable,SourceFile
-dontwarn io.sentry.**

# AndroidX / Material
-dontwarn androidx.**
-dontwarn com.google.android.material.**
