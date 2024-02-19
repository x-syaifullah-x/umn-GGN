# hide the original source file name.
-renamesourcefileattribute SourceFile

# Kotlin
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
	public static void check*(...);
	public static void throw*(...);
}

-keep class com.google.android.gms.internal.** { *; }

# Excessive obfuscation
-repackageclasses "com"
-allowaccessmodification