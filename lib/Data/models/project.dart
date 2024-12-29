import 'dart:io';

import 'package:isar/isar.dart';
part 'project.g.dart';
@collection
class Project {
  final String path;
  @enumerated
  final ProjectType projectType;
  final Id id = Isar.autoIncrement; // you can also use id = null to auto increment
   const Project( { required this.path,required this.projectType,});
    @override
    int get hashCode=>Object.hash(path,projectType);

  @override
  bool operator ==(Object other) {
    if(other is! Project) return false;
    return path == other.path;
  }
  factory Project.fromPath(String path) {
    return Project(path: path, projectType: detectProjectType(path));
  }
}
ProjectType detectProjectType(String path) {


  // Check if 'pubspec.yaml' exists
  final pubspecFile = File('$path/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return ProjectType.none;
  }

  // Check for Flutter-specific subdirectories
  final flutterIndicators = ['android', 'ios','macos','windows','web','linux'];
  for (var name in flutterIndicators) {
    if (Directory('$path/$name').existsSync()) {
      return ProjectType.flutter;
    }
  }

  if(Directory('$path/lib').existsSync()==false)  return ProjectType.other;

  // Check for Dart files to classify as a Dart project
  final hasDartFiles = Directory('$path/lib')
      .listSync(recursive: true)
      .any((entity) => entity is File && entity.path.endsWith('.dart'));

  if (hasDartFiles) {
    return ProjectType.dart;
  }

  // If none of the above, it might be another type of project using pubspec.yaml
  return ProjectType.other;
}
enum ProjectType {
  flutter,
  dart,
  other,
  none
}