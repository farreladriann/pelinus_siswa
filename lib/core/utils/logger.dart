// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';

/// Production-safe logging utility
/// Only logs in debug mode to avoid performance issues in production
class AppLogger {
  static const String _tag = 'PelinusApp';
  
  /// Debug logs - only appear in debug mode
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('🐛 ${tag ?? _tag}: $message');
    }
  }
  
  /// Info logs - only appear in debug mode
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('ℹ️ ${tag ?? _tag}: $message');
    }
  }
  
  /// Warning logs - only appear in debug mode
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('⚠️ ${tag ?? _tag}: $message');
    }
  }
  
  /// Error logs - appear in debug mode, silent in production
  /// In production, you could send these to crash reporting services
  static void error(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('❌ ${tag ?? _tag}: $message');
      if (error != null) {
        // ignore: avoid_print
        print('Error: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('StackTrace: $stackTrace');
      }
    }
    // In production, could be sent to Firebase Crashlytics, Sentry, etc.
  }
  
  /// Database operation logs - only debug mode
  static void database(String operation, String details) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('💾 DB-$operation: $details');
    }
  }
  
  /// Network operation logs - only debug mode  
  static void network(String operation, String details) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('🌐 NET-$operation: $details');
    }
  }
  
  /// Sync operation logs - only debug mode
  static void sync(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('🔄 SYNC: $message');
    }
  }
  
  /// PDF operation logs - only debug mode
  static void pdf(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('📄 PDF: $message');
    }
  }
}
