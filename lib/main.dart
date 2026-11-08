import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/alarm_service.dart';
import 'theme/app_theme.dart';
import 'shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await Notify.init();
  await AlarmService.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NoorApp());
}

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'نور العادات',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const Shell(),
      );
}
