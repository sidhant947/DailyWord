import 'package:material_ui/material_ui.dart';
import 'data/repositories/word_repository.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/word_service.dart';
import 'ui/core/theme_controller.dart';
import 'ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await LocalStorageService.create();
  final themeController = ThemeController(storageService);
  final wordService = WordService();
  final wordRepository = WordRepositoryImpl(
    wordService: wordService,
    storageService: storageService,
  );
  runApp(
    DailyWordApp(
      wordRepository: wordRepository,
      themeController: themeController,
    ),
  );
}

class DailyWordApp extends StatelessWidget {
  final WordRepository wordRepository;
  final ThemeController themeController;

  const DailyWordApp({
    super.key,
    required this.wordRepository,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Daily Word',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1C1E),
              surface: Color(0xFFFFFFFF),
              onSurface: Color(0xFF1A1C1E),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFFFFFF),
              foregroundColor: Color(0xFF1A1C1E),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121213),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF8F9FA),
              surface: Color(0xFF121213),
              onSurface: Color(0xFFF8F9FA),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121213),
              foregroundColor: Color(0xFFF8F9FA),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          home: HomeView(
            wordRepository: wordRepository,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
