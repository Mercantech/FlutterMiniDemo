# Flutter Debugging & Koncepter Guide

Denne guide forklarer de 3 hovedkoncepter der demonstreres i denne Flutter app:

## 1. 🔍 Debugging og Fejlfinding med VSCode

### Debugging Værktøjer i VSCode

#### Breakpoints
1. **Sæt et breakpoint**: Klik på linjenummeret til venstre for koden (rød prik vises)
2. **Kør i Debug mode**: Tryk `F5` eller klik på "Run and Debug" i sidebar
3. **Step through koden**:
   - `F10` - Step Over (gå til næste linje)
   - `F11` - Step Into (gå ind i funktioner)
   - `Shift+F11` - Step Out (gå ud af funktion)
   - `F5` - Continue (fortsæt til næste breakpoint)

#### Debug Console
- Se værdier af variabler ved at hover over dem i koden
- Indtast variabelnavne i Debug Console for at se deres værdier
- Evaluér udtryk ved at skrive dem i Console

#### Print Statements
```dart
// Brug debugPrint() i stedet for print() i Flutter
debugPrint('Min variabel værdi: $myVariable');

// DEBUGGING: Log når en funktion kaldes
void myFunction() {
  debugPrint('myFunction() kaldt med parameter: $param');
}
```

#### Eksempler i Koden
- `lib/main.dart` - Debugging ved app start
- `lib/pages/home_page.dart` - Debugging ved navigation
- `lib/pages/hangman_page.dart` - Debugging i spil logik
- `lib/pages/wordle_page.dart` - Debugging ved state ændringer

### Debugging Tips
1. **Sæt breakpoints ved kritiske steder**: Init state, button clicks, state updates
2. **Brug Conditional Breakpoints**: Højreklik på breakpoint → "Edit Breakpoint" → tilføj condition
3. **Inspect Widget Tree**: Brug Flutter DevTools (tryk `Ctrl+Shift+P` → "Flutter: Open DevTools")
4. **Hot Reload**: Tryk `Ctrl+F5` eller klik på hot reload ikon (hurtigere end hot restart)

---

## 2. 🧭 Routing og Navigation

### Hovedkoncepter

#### Navigator Stack
Flutter bruger en **stack** til navigation:
- Hver ny side skubbes på toppen af stacken
- Når du går tilbage, popper den øverste side af

#### Grundlæggende Navigation

```dart
// 1. Naviger til ny side (push)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NextPage(),
  ),
);

// 2. Gå tilbage til forrige side (pop)
Navigator.pop(context);

// 3. Naviger med resultat
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextPage()),
).then((result) {
  // Håndter resultat når siden popper
  debugPrint('Resultat: $result');
});

// 4. Returner resultat når man går tilbage
Navigator.pop(context, 'mit resultat');
```

### Named Routes (Nu implementeret i appen!)

Named routes er nu implementeret i denne app! Dette giver flere fordele:

**1. Routes i URL'en**: Når appen kører i web browser, kan du se routes i URL'en (fx: `localhost:8080/#/wordle`)

**2. Centraliseret route management**: Alle routes er defineret i `lib/routes/app_routes.dart`

**3. Deep linking**: Du kan bookmarke og dele links til specifikke sider

```dart
// I main.dart MaterialApp (NU IMPLEMENTERET):
routes: AppRoutes.getRoutes(),
initialRoute: AppRoutes.getInitialRoute(),

// I app_routes.dart:
class AppRoutes {
  static const String home = '/';
  static const String wordle = '/wordle';
  static const String hangman = '/hangman';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      wordle: (context) => const WordlePage(),
      hangman: (context) => const HangmanPage(),
    };
  }
}

// Naviger ved navn (NU BRUGT I APPEN):
Navigator.pushNamed(context, '/wordle');

// Gå tilbage (fungerer stadig):
Navigator.pop(context);
```

**Fordele ved named routes:**
- ✅ Routes vises i browser URL (web deployment)
- ✅ Deep linking muligheder
- ✅ Centraliseret vedligeholdelse
- ✅ Lettere at teste navigation
- ✅ Bedre SEO for web apps

### Eksempler i Koden
- `lib/routes/app_routes.dart` - **Named routes konfiguration** (ny fil!)
- `lib/main.dart` - MaterialApp med named routes setup
- `lib/pages/home_page.dart` - Navigation til spil med `Navigator.pushNamed()`
- `lib/pages/wordle_page.dart` - Tilbage til menu med `Navigator.pop()`
- `lib/pages/hangman_page.dart` - Navigation med dialog og `Navigator.pop()`

### Navigation Tips
1. **Altid brug context**: Navigation kræver en BuildContext
2. **Pop først, derefter push**: Hvis du vil erstatte den nuværende side
3. **Håndter resultater**: Brug `.then()` hvis den nye side returnerer data
4. **Named routes i URL**: Når appen kører i web browser, se routes i URL'en!
5. **Centraliser routes**: Brug `AppRoutes` klassen til at vedligeholde alle routes

---

## 3. ⚙️ State Management

### Lokal State med setState()

**Bruges til**: State der kun bruges i én widget

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0; // State variabel

  void _increment() {
    setState(() {
      _counter++; // Opdater state - trigger rebuild
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Text('Count: $_counter');
  }
}
```

**Hvornår bruges det?**
- Når state kun er relevant for én widget
- Enkle værdier (int, String, bool, etc.)
- Lokal UI state (loading, error, etc.)

**Eksempler i koden**:
- `lib/pages/wordle_page.dart` - Spil state (gæt, ord, game over)
- `lib/pages/hangman_page.dart` - Spil state (gættede bogstaver, forkerte gæt)

### Delstat med ChangeNotifier

**Bruges til**: State der deles mellem flere widgets

```dart
// 1. Opret ChangeNotifier klasse
class MyState extends ChangeNotifier {
  int _value = 0;
  
  int get value => _value;
  
  void increment() {
    _value++;
    notifyListeners(); // Fortæl lyttere om ændring
  }
}

// 2. Opret instans (typisk i main eller højere oppe i tree)
final myState = MyState();

// 3. Lyt til ændringer (i widget)
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: myState,
      builder: (context, child) {
        return Text('Value: ${myState.value}');
      },
    );
  }
}
```

**Eksempler i koden**:
- `lib/models/game_score.dart` - Delstat for spilstatistikker

### State Management Patterns

| Pattern | Brug til | Kompleksitet |
|---------|----------|--------------|
| `setState()` | Lokal state | ⭐ Simpel |
| `ChangeNotifier` | Delstat | ⭐⭐ Medium |
| `Provider` (package) | Global state | ⭐⭐⭐ Avanceret |
| `Riverpod` | Global state | ⭐⭐⭐⭐ Meget avanceret |
| `Bloc` | Kompleks state | ⭐⭐⭐⭐⭐ Meget avanceret |

### State Management Tips
1. **Start simpelt**: Brug `setState()` hvis det er nok
2. **Lift state up**: Hvis flere widgets skal dele state, flyt den op i widget tree
3. **Undgå unødvendige rebuilds**: Kun opdater når nødvendigt
4. **Separate logic**: Hold business logic adskilt fra UI

---

## 📚 Yderligere Ressourcer

### Flutter Dokumentation
- [Debugging Flutter Apps](https://docs.flutter.dev/testing/debugging)
- [Navigation and Routing](https://docs.flutter.dev/ui/navigation)
- [State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)

### VSCode Extensions
- **Flutter**: Officiel Flutter extension
- **Dart**: Dart language support
- **Flutter Widget Snippets**: Hurtigere widget creation

### Næste Skridt
1. Eksperimenter med breakpoints i de eksisterende sider
2. Tilføj flere navigation routes
3. Implementer Provider package for mere avanceret state management

---

## 🎯 Øvelser

### Øvelse 1: Debugging
1. Sæt et breakpoint i `hangman_page.dart` ved `_guessLetter()` metoden
2. Kør appen i Debug mode
3. Gæt et bogstav og se hvordan variablerne ændres

### Øvelse 2: Navigation
1. Tilføj en "Settings" side
2. Naviger til den fra home page
3. Returner et resultat når du går tilbage

### Øvelse 3: State Management
1. Opret en `GameHistory` ChangeNotifier klasse
2. Gem hvert spil resultat
3. Vis historik på en ny side

---

*Oprettet som en del af Flutter Mini Demo projekt*
