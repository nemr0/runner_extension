import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:runner_extension/Data/models/project.dart';

class RecentProjectTile extends StatelessWidget {
  const RecentProjectTile({
    super.key,
    required this.recentProject, required this.onRemove,
  });

  final Project recentProject;
  final Function(Project recentProject) onRemove;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MacosListTile(
        title: Text(recentProject.path),
        subtitle:
        Text(recentProject.projectType.name),
        leading: MacosIconButton(
            onPressed: () => onRemove(recentProject),
            boxConstraints: BoxConstraints(minWidth: 20, minHeight: 20),
            icon: MacosIcon(CupertinoIcons.delete_left_fill)),
      ),
    );
  }
}
