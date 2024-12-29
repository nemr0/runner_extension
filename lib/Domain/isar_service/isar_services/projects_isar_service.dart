import 'package:isar/isar.dart';
import 'package:runner_extension/Data/models/project.dart';
import 'package:runner_extension/Domain/isar_service/isar_service.dart';

class ProjectsIsarLocalSource {
  ProjectsIsarLocalSource();

  List<Project> get() {
    return isarService.get<Project>();
  }


  Id write(Project project) {
    return isarService.write<Project>(project);
  }

  bool delete(String path) {
    return isarService.isar.writeTxnSync(() => isarService.isar.projects.filter().pathEqualTo(path).deleteFirstSync());
  }


}