part of 'projects_cubit.dart';

sealed class ProjectsState extends Equatable {
  const ProjectsState();
}

final class ProjectsInitial extends ProjectsState {
  @override
  List<Object> get props => [];
}

final class ProjectsLoading extends ProjectsState {
  @override
  List<Object> get props => [];
}

class ProjectsSuccess extends ProjectsState{
  final List<Project> recentProjects;
  const ProjectsSuccess(this.recentProjects);
  @override
  List<Object?> get props => [recentProjects];
}

class AddProjectError extends ProjectsState{
  final String message;
  const AddProjectError (this.message);
  @override
  List<Object?> get props => [message];
}
