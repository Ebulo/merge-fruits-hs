# WorkManager creates this Room database by reflection at application startup.
# Keep its generated implementation and constructor in optimized release builds.
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
