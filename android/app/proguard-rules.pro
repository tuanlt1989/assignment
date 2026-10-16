# Release builds are minified by R8. WorkManager (pulled in by Google Mobile Ads)
# creates its Room database by reflection, so R8 must keep the generated
# implementations and their no-arg constructors, or the app crashes at launch:
# "Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**
