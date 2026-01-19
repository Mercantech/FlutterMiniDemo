import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

/// MAIN.DART - App Entry Point
/// 
/// ROUTING & NAVIGATION:
/// MaterialApp er root widget der håndterer navigation i Flutter.
/// Den holder styr på en stack af routes (sider).
/// 
/// NAMED ROUTES:
/// Vi bruger nu named routes i stedet for MaterialPageRoute.
/// Dette giver os:
/// 1. Routes vises i URL'en (ved web deployment)
/// 2. Deep linking - direkte navigation til routes via URL
/// 3. Centraliseret route management
/// 
/// DEBUGGING TIP:
/// - Kør appen i Debug mode (F5 i VSCode)
/// - Sæt breakpoints i runApp() for at se app start
/// - Brug Flutter DevTools til at inspektere widget tree
/// - Se routes i URL'en når appen kører i web browser!
void main() {
  // DEBUGGING: Log når appen starter
  debugPrint('App starter...');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ROUTING EKSEMPEL 2: Named Routes med routes og initialRoute
    // 
    // routes: Map af route navne til deres widgets
    // initialRoute: Den route appen starter på
    // 
    // FORDELE:
    // - Routes vises i browser URL (fx: localhost:8080/#/wordle)
    // - Deep linking: man kan bookmarke og dele links til specifikke sider
    // - Lettere at teste og debug navigation
    return MaterialApp(
      title: 'Flutter Spil Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      
      // ROUTING: Named routes - routes er defineret i AppRoutes
      // DEBUGGING: Routes vises nu i URL'en når appen kører i web!
      routes: AppRoutes.getRoutes(),
      initialRoute: AppRoutes.getInitialRoute(),
      
      // DEBUGGING: Enable debug banner i top-venstre hjørne
      // Sæt til false når du vil fjerne det
      debugShowCheckedModeBanner: false,
    );
  }
}
