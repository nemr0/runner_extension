import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:runner_extension/Data/models/project.dart';
/// Defines the type of output line.
enum ProcessOutputType { stdout, stderr, done }

/// Encapsulates a line of output along with the type of output it came from.
/// You could also store timestamp, project ID, etc.
class ProcessOutputEvent {
  final ProcessOutputType type;
  final String message;

  ProcessOutputEvent({
    required this.type,
    required this.message,
  });

  @override
  String toString() => '[${type.name}] $message';
}
class CommandService {
  final Project project;

  /// A list of available devices for Flutter projects (if any).
  List<String> _devices = [];

  /// A list of parsed extra arguments derived from [_rawExtraParams].
  List<String> _parsedExtraArgs = [];

  /// Keep reference to the currently running process (for hot reload, etc).
  Process? _currentProcess;

  CommandService({required this.project});

  /// Get currently known devices (only valid if [project.projectType] == [ProjectType.flutter]).
  List<String> get devices => _devices;

  /// Set the extra parameters as a single string (e.g., "--release --flavor=dev --target=lib/main_dev.dart").
  void setExtraParams(String allParams) {
    // Naive split on whitespace
    _parsedExtraArgs = allParams
        .split(' ')
        .map((arg) => arg.trim())
        .where((arg) => arg.isNotEmpty)
        .toList();
  }

  /// Clear the extra params.
  void clearExtraParams() {
    _parsedExtraArgs.clear();
  }

  /// Fetch the list of Flutter devices (only relevant if `projectType == ProjectType.flutter`).
  FutureOr<void> fetchFlutterDevices() async {
    if (project.projectType != ProjectType.flutter) {
      return;
    }

    try {
      final result = await Process.run(
        'flutter',
        ['devices'],
        workingDirectory: project.path,
      );
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        _devices = lines
            .where((line) => line.contains('•'))
            .map((line) => line.split('•').first.trim())
            .toList();

        print('Flutter devices found: $_devices');
      } else {
        print('Error fetching devices: ${result.stderr}');
      }
    } catch (e) {
      print('Exception when fetching devices: $e');
    }
  }

  /// Run the project **as a stream** of ProcessOutputEvent (or raw String if you prefer).
  ///
  /// `deviceId` is optional; if null, uses first device in [_devices].
  /// If [enableHotReload] or [enableHotRestart] is true, you will
  /// want to wire up ways to send 'r' or 'R' to process.stdin via separate methods.
  Stream<ProcessOutputEvent> runProject({
    String? deviceId,
    bool enableHotReload = false,
    bool enableHotRestart = false,
  }) async* {
    // Just in case a previous process is still running, you might want to kill it or handle it.
    _currentProcess?.kill();
    _currentProcess = null;

    switch (project.projectType) {
      case ProjectType.flutter:
        yield* _runFlutterProject(
          deviceId: deviceId,
          enableHotReload: enableHotReload,
          enableHotRestart: enableHotRestart,
        );
        break;
      case ProjectType.dart:
        yield* _runDartProject();
        break;
      case ProjectType.other:
      case ProjectType.none:
        yield ProcessOutputEvent(
          type: ProcessOutputType.stderr,
          message: "Project type is 'other' or 'none'. No known run command.",
        );
        break;
    }
  }

  /// Opens Flutter DevTools (only for [ProjectType.flutter]).
  Future<void> openFlutterDevTools() async {
    if (project.projectType != ProjectType.flutter) {
      print("DevTools is only available for Flutter projects.");
      return;
    }

    try {
      final result = await Process.run(
        'flutter',
        ['pub', 'global', 'run', 'devtools'],
        workingDirectory: project.path,
      );

      if (result.exitCode == 0) {
        print('DevTools started. ${result.stdout}');
      } else {
        print('Failed to open DevTools: ${result.stderr}');
      }
    } catch (e) {
      print('Exception while opening DevTools: $e');
    }
  }

  /// Attempts a hot reload by writing 'r' to the current process.
  /// You could wire this up to a GUI button or keyboard shortcut.
  void hotReload() {
    if (_currentProcess == null) return;
    _currentProcess!.stdin.write('r\n');
  }

  /// Attempts a hot restart by writing 'R' to the current process.
  void hotRestart() {
    if (_currentProcess == null) return;
    _currentProcess!.stdin.write('R\n');
  }

  // ----------------------------------------------------------
  // Private helpers returning streams
  // ----------------------------------------------------------

  /// Runs a Flutter project and returns a Stream of output events.
  Stream<ProcessOutputEvent> _runFlutterProject({
    String? deviceId,
    required bool enableHotReload,
    required bool enableHotRestart,
  }) async* {
    final args = <String>['run'];

    // If a specific device is requested, use it. Otherwise pick the first if available.
    final chosenDevice = deviceId ?? (_devices.isNotEmpty ? _devices.first : null);
    if (chosenDevice != null) {
      args.addAll(['-d', chosenDevice]);
    }

    // Append user-provided extra arguments
    if (_parsedExtraArgs.isNotEmpty) {
      args.addAll(_parsedExtraArgs);
    }

    final commandString = 'flutter ${args.join(' ')}';
    print('Running Flutter command: $commandString');

    try {
      final process = await Process.start(
        'flutter',
        args,
        workingDirectory: project.path,
        runInShell: true,
      );

      // keep a reference so we can do hot reload/restart
      _currentProcess = process;

      // If user wants hot reload/restart, you can optionally print instructions or do something else
      if (enableHotReload) {
        yield ProcessOutputEvent(
          type: ProcessOutputType.stdout,
          message: "Hot Reload enabled. Press 'r' in console or call `hotReload()`.",
        );
      }
      if (enableHotRestart) {
        yield ProcessOutputEvent(
          type: ProcessOutputType.stdout,
          message: "Hot Restart enabled. Press 'R' in console or call `hotRestart()`.",
        );
      }

      // Merge the stdout & stderr streams into a single event stream
      yield* _processToStream(process);
    } catch (e) {
      yield ProcessOutputEvent(
        type: ProcessOutputType.stderr,
        message: 'Exception while running Flutter project: $e',
      );
    }
  }

  /// Runs a simple Dart project and returns a Stream of output events.
  Stream<ProcessOutputEvent> _runDartProject() async* {
    final args = <String>['run'];

    // Append user-provided extra arguments
    if (_parsedExtraArgs.isNotEmpty) {
      args.addAll(_parsedExtraArgs);
    }

    final commandString = 'dart ${args.join(' ')}';
    print('Running Dart command: $commandString');

    try {
      final process = await Process.start(
        'dart',
        args,
        workingDirectory: project.path,
        runInShell: true,
      );

      _currentProcess = process;

      // Merge stdout & stderr
      yield* _processToStream(process);
    } catch (e) {
      yield ProcessOutputEvent(
        type: ProcessOutputType.stderr,
        message: 'Exception while running Dart project: $e',
      );
    }
  }

  /// Helper to convert a [Process] to a Stream of [ProcessOutputEvent] by merging stdout & stderr.
  Stream<ProcessOutputEvent> _processToStream(Process process) {
    // We’ll use a StreamController to combine stdout/stderr lines into one stream of events
    final controller = StreamController<ProcessOutputEvent>();

    // Listen to stdout
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      controller.add(
        ProcessOutputEvent(type: ProcessOutputType.stdout, message: line),
      );
    }, onError: (error, st) {
      controller.addError(error, st);
    });

    // Listen to stderr
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      controller.add(
        ProcessOutputEvent(type: ProcessOutputType.stderr, message: line),
      );
    }, onError: (error, st) {
      controller.addError(error, st);
    });

    // When the process exits, close the controller (after reporting exit code if you like).
    process.exitCode.then((exitCode) {
      controller.add(
        ProcessOutputEvent(
          type: ProcessOutputType.done,
          message: 'Process exited with code $exitCode',
        ),
      );
      controller.close();
      // Optionally reset _currentProcess if you only allow one process at a time
      _currentProcess = null;
    });

    return controller.stream;
  }
}
