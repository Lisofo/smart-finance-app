/// Callback registered from [main] so [Dio] interceptors can clear session
/// without importing [auth_provider] (avoids import cycles).
Future<void> Function()? notifySessionUnauthorized;
