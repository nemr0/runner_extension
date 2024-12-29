// import 'dart:async';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:runner_extension/Data/models/project.dart';
// import 'package:runner_extension/Domain/isar_service.dart';
//
// final recentProjectsNotifierProvider = NotifierProvider.autoDispose<RecentProjectsNotifier,List<RecentProject>>(() => RecentProjectsNotifier());
//
// class RecentProjectsNotifier extends Notifier<List<RecentProject>> {
//   final RecentProjectsLocalSource recentProjectsLocalSource =
//       RecentProjectsLocalSource();
//
//   @override
//   List<RecentProject> build() {
//     return recentProjectsLocalSource.get();
//   }
//
//  FutureOr add(String path ) {
//
//     recentProjectsLocalSource.write(RecentProject.fromPath(path));
//     state = build();
//   }
//
//   remove(RecentProject recentProject) {
//     recentProjectsLocalSource.delete(recentProject.id);
//     state = build();
//   }
// }
