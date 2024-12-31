import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:runner_extension/Presentation/bloc/projects_cubit/projects_cubit.dart';
import 'package:runner_extension/Presentation/helpers/window_helper.dart';
import 'dart:math' as math;

import 'package:runner_extension/Presentation/views/open_project_view/widgets/recent_project_tile.dart';
import 'package:runner_extension/gen/assets.gen.dart';

class OpenProjectView extends HookWidget {
  const OpenProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WindowHelper.instance.setSize(WindowSize.mid);
      ProjectsCubit.get(context).getProjects();
      return null;
    });

    return MacosWindow(
      child: CustomScrollView(
        slivers: [
          SliverToolBar(
            centerTitle: true,
            pinned: true,
            title: Text('Pick A Project'),
            actions: [
              ToolBarIconButton(
                  label: 'Add A Project',
                  icon: MacosIcon(CupertinoIcons.add_circled),
                  showLabel: true,
                  onPressed: () => ProjectsCubit.get(context).add())
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 8),
            sliver: BlocConsumer<ProjectsCubit, ProjectsState>(
              listener: (context, state) {
                if (state is AddProjectError) {
                  WindowHelper.instance.showDialog((context) =>
                      MacosAlertDialog(
                          appIcon: Icon(CupertinoIcons.xmark_circle),
                          title: Text('Error Happened'),
                          message: Text(state.message),
                          primaryButton: PushButton(
                              onPressed: () => Navigator.pop(context),
                              controlSize: ControlSize.large,
                              child: Text('Ok'))));
                }
              },
              builder: (context, state) {
                final recentProjects =
                    ProjectsCubit.get(context).recentProjects;
                if (recentProjects.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 60,),
                        Assets.emptyBox.svg(colorFilter: ColorFilter.mode(MacosTheme.brightnessOf(context)== Brightness.light?MacosColors.black:MacosColors.white, BlendMode.srcIn)),
                        RichText(
                            text: TextSpan(
                                text: 'No Recent Projects, ',
                                children: [
                              TextSpan(
                                  text: 'click here to add a new one.',
                                  style: TextStyle(color: MacosTheme.of(context).primaryColor),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap =
                                        () => ProjectsCubit.get(context).add())
                            ]))
                      ],
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      if (index.isOdd) return MacosPulldownMenuDivider();
                      index = index ~/ 2;

                      return RecentProjectTile(
                        recentProject: recentProjects[index],
                        onRemove: (recentProject) =>
                            ProjectsCubit.get(context).remove(recentProject),
                      );
                    },
                    semanticIndexCallback: (Widget widget, int localIndex) {
                      if (localIndex.isEven) {
                        return localIndex ~/ 2;
                      }
                      return null;
                    },
                    childCount: math.max(0, recentProjects.length * 2) - 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
