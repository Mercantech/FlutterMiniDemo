import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/wordle_page.dart';
import '../pages/hangman_page.dart';

/// APP ROUTES - Named Routes Konfiguration
/// 
/// ROUTING & NAVIGATION EKSEMPEL 2: Named Routes
/// 
/// Named routes giver flere fordele:
/// 1. Routes er centraliseret og nemme at vedligeholde
/// 2. Routes kan vises i URL (i web versionen)
/// 3. Deep linking - man kan navigere direkte til en side via URL
/// 4. Lettere at teste - man kan teste navigation ved navn
/// 
/// DEBUGGING: Du kan nu se routes i URL'en når appen kører i web browser!
class AppRoutes {
  // Route navne som konstanter - undgåer typo fejl
  static const String home = '/';
  static const String wordle = '/wordle';
  static const String hangman = '/hangman';

  /// Generér routes map til MaterialApp
  /// 
  /// ROUTING: Dette map mapper route navne til deres widgets
  /// MaterialApp bruger dette til at vide hvilken widget der skal vises
  /// når man kalder Navigator.pushNamed(context, '/wordle')
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      wordle: (context) => const WordlePage(),
      hangman: (context) => const HangmanPage(),
    };
  }

  /// Generér initial route
  /// 
  /// ROUTING: initialRoute definerer hvilken side appen starter på
  static String getInitialRoute() {
    return home;
  }
}
