
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:runner_extension/Domain/isar_service/isar_service.dart';
import 'package:runner_extension/Presentation/bloc/projects_cubit/projects_cubit.dart';
import 'package:runner_extension/Presentation/helpers/window_helper.dart';
import 'package:runner_extension/Presentation/views/open_project_view/open_project_view.dart';
final navigationKey = GlobalKey<NavigatorState>();
Future<void> main() async {

 WidgetsFlutterBinding.ensureInitialized();
  await isarService.init();
  await WindowHelper.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [BlocProvider(
        lazy: false,
        create: (context) => ProjectsCubit(),)],
      child: MacosApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Runner Extension',
        navigatorKey: navigationKey,
        home: OpenProjectView(),
      ),
    );
  }
}

