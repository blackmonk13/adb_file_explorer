///
/// exceptions.dart
/// Author: Original Author (GitHub: https://github.com/leancodepl/patrol/tree/master/packages/adb)
/// Description: Extended version of the exceptions from the [adb package](https://pub.dev/packages/adb).
/// 

part of "adb.dart";

/// Used when `adb` command fails.
abstract class AdbException implements Exception {
  /// Creates a new [AdbException].
  const AdbException({required this.message});

  /// Raw error output that caused this exception.
  final String message;

  @override
  String toString() => 'AdbException: $message';
}

/// Indicates that `adb` executable was not found.
class AdbExecutableNotFound extends AdbException {
  /// Creates a new [AdbExecutableNotFound].
  const AdbExecutableNotFound({required super.message});

  @override
  String toString() => 'AdbExecutableNotFound: $message';
}

/// Indicates that `adbd` (ADB daemon) was not running when `adb` (ADB client)
/// was called.
///
/// See also:
///  - https://developer.android.com/studio/command-line/adb
class AdbDaemonNotRunning extends AdbException {
  /// Creates a new [AdbDaemonNotRunning].
  const AdbDaemonNotRunning({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbDaemonNotRunning] should be thrown.
  static const trigger = 'daemon not running; starting now at';

  @override
  String toString() => 'AdbDaemonNotRunning: $message';
}

/// Indicates that `adb install` call failed with
/// INSTALL_FAILED_UPDATE_INCOMPATIBLE.
class AdbInstallFailedUpdateIncompatible extends AdbException {
  /// Creates a new [AdbInstallFailedUpdateIncompatible];
  const AdbInstallFailedUpdateIncompatible({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbInstallFailedUpdateIncompatible] should be thrown.
  static const trigger = 'INSTALL_FAILED_UPDATE_INCOMPATIBLE';

  @override
  String toString() => 'AdbInstallFailedUpdateIncompatible: $message';
}

/// Indicates that `adb uninstall` call failed with
/// DELETE_FAILED_INTERNAL_ERROR.
class AdbDeleteFailedInternalError extends AdbException {
  /// Creates a new [AdbDeleteFailedInternalError];
  const AdbDeleteFailedInternalError({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbDeleteFailedInternalError] should be thrown.
  static const trigger = 'DELETE_FAILED_INTERNAL_ERROR';

  @override
  String toString() => 'AdbDeleteFailedInternalError: $message';
}

/// Indicates that `adb shell ls` call failed with
/// Permission denied.
class AdbShellLsPermissionDenied extends AdbException {
  /// Creates a new [AdbShellLsPermissionDenied];
  const AdbShellLsPermissionDenied({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbShellLsPermissionDenied] should be thrown.
  static final trigger = RegExp(r'^ls: .+? Permission denied$');

  @override
  String toString() => 'Permission denied: $message';
}

/// Indicates that `adb pull` call failed with
/// Permission denied.
class AdbPullPermissionDenied extends AdbException {
  /// Creates a new [AdbPullPermissionDenied];
  const AdbPullPermissionDenied({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbPullPermissionDenied] should be thrown.
  static final trigger = RegExp(
      r'^adb: error: failed to stat remote object .+? Permission denied$');

  @override
  String toString() => 'Permission denied: $message';
}

/// Indicates that `adb pull` call failed with
/// No such file or directory.
class AdbPullFileOrDirectoryNotFound extends AdbException {
  /// Creates a new [AdbPullFileOrDirectoryNotFound];
  const AdbPullFileOrDirectoryNotFound({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbPullFileOrDirectoryNotFound] should be thrown.
  static final trigger = RegExp(
      r'^adb: error: failed to stat remote object .+? No such file or directory$');

  @override
  String toString() => 'No such file or directory: $message';
}

/// Indicates that `adb push` call failed with
/// Permission denied.
class AdbPushReadOnlyFs extends AdbException {
  /// Creates a new [AdbPushReadOnlyFs];
  const AdbPushReadOnlyFs({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbPullPermissionDenied] should be thrown.
  static final trigger = RegExp(
      r"^adb: error: failed to copy .+? remote couldn't create file: Read-only file system$");

  @override
  String toString() => 'Read-only file system: $message';
}

/// Indicates that `adb push` call failed with
/// Permission denied.
class AdbPushOperationNotPermitted extends AdbException {
  /// Creates a new [AdbPushOperationNotPermitted];
  const AdbPushOperationNotPermitted({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbPullPermissionDenied] should be thrown.
  static final trigger = RegExp(
      r"^adb: error: failed to copy .+? remote couldn't create file: Operation not permitted$");

  @override
  String toString() => 'Operation not permitted: $message';
}

/// Indicates that `adb push` call failed with
/// Permission denied.
class AdbPushNoSuchFileOrDirectory extends AdbException {
  /// Creates a new [AdbPushNoSuchFileOrDirectory];
  const AdbPushNoSuchFileOrDirectory({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbPullPermissionDenied] should be thrown.
  static final trigger =
      RegExp(r"^adb: error: cannot stat .+? No such file or directory$");

  @override
  String toString() => 'No such file or directory: $message';
}
