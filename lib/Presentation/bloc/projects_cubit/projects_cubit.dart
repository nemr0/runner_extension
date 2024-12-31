import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runner_extension/Data/models/project.dart';
import 'package:runner_extension/Domain/isar_service/isar_services/projects_isar_service.dart';

part 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit() : super(ProjectsInitial());
  final recentProjectLocalSource = ProjectsIsarLocalSource();

  static ProjectsCubit get(BuildContext context) =>
      BlocProvider.of<ProjectsCubit>(context);
  List<Project> recentProjects = [];

  getProjects() {
    recentProjects = recentProjectLocalSource.get();
    emit(ProjectsSuccess(recentProjects));
  }

  remove(Project recentProject) {
    recentProjectLocalSource.delete(recentProject.path);
    getProjects();
  }
  bool adding = false;
  Future<void> add() async {
    if(adding) return;
    adding = true;
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        emit(AddProjectError('Please Select A Project'));
        return;
      }
      final recentProject = Project.fromPath(selectedDirectory);

      switch (recentProject.projectType) {
        case ProjectType.flutter:
        case ProjectType.dart:
          recentProjectLocalSource.write(recentProject);
          getProjects();
        case ProjectType.other:
          emit(AddProjectError('Not A Flutter/Dart Project!'));
        case ProjectType.none:
          emit(AddProjectError('Couldn\'t Find Directory!'));
      }
    } catch (e) {
      emit(AddProjectError('Not A Flutter/Dart Project!'));
    } finally {
      adding = false;
    }
  }
}
