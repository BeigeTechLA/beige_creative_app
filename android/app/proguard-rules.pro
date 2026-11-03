# Flutter / Firebase ship their own consumer ProGuard rules; only app-specific
# -dontwarn / -keep rules belong here.

# OkHttp (optional transitive dependency — suppress missing-class warnings)
-dontwarn okhttp3.Call
-dontwarn okhttp3.Dispatcher
-dontwarn okhttp3.OkHttpClient
-dontwarn okhttp3.Request$Builder
-dontwarn okhttp3.Request
-dontwarn okhttp3.Response
-dontwarn okhttp3.ResponseBody
