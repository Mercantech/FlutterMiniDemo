import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/keyboard_input_service.dart';

/// HANGMAN PAGE - Demonstrerer STATE MANAGEMENT og DEBUGGING
/// 
/// Dette spil demonstrerer:
/// 1. STATE MANAGEMENT: Bruger setState() til lokal state og ChangeNotifier til delt state
/// 2. DEBUGGING: Har debugging kommentarer og print statements
/// 3. CONDITIONAL RENDERING: Viser forskellige UI baseret på spil state
class HangmanPage extends StatefulWidget {
  const HangmanPage({super.key});

  @override
  State<HangmanPage> createState() => _HangmanPageState();
}

class _HangmanPageState extends State<HangmanPage> {
  // STATE MANAGEMENT EKSEMPEL 1: Lokal state med setState()
  // Disse variabler ændres gennem setState() hvilket trigger en rebuild af widget
  final KeyboardInputService _keyboardService = KeyboardInputService();
  final FocusNode _focusNode = FocusNode();
  
  String _selectedWord = '';
  List<String> _guessedLetters = [];
  int _wrongGuesses = 0;
  final int _maxWrongGuesses = 7;
  bool _gameWon = false;
  bool _gameOver = false;
  bool _wordEntered = false; // Ny state: Er ordet indtastet?

  @override
  void initState() {
    super.initState();
    // DEBUGGING: Log når siden initialiseres
    debugPrint('HangmanPage initialiseret');
    // Vis dialog til at indtaste ord i stedet for at vælge automatisk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWordInputDialog();
      // Sæt fokus når siden er klar (efter dialog er lukket)
      // Dette gør det muligt at bruge keyboard input
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Vis dialog til at indtaste ord
  /// DEBUGGING: Denne dialog demonstrerer state management og input håndtering
  void _showWordInputDialog() {
    final TextEditingController wordController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false, // Man kan ikke lukke dialog ved at klikke udenfor
      builder: (context) => AlertDialog(
        title: const Text('Indtast ord til Hangman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Indtast et ord som de andre skal gætte.\nOrdet bliver skjult når du indtaster det.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // DEBUGGING: TextField med obscureText skjuler teksten (som password)
            // Dette sikrer at andre ikke kan se ordet når det indtastes
            TextField(
              controller: wordController,
              obscureText: true, // Skjul teksten - som password field
              textCapitalization: TextCapitalization.none,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Indtast ord',
                hintText: 'fx: programering',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                // Når Enter trykkes, submit
                if (_validateWord(value)) {
                  _startNewGameWithWord(value);
                  Navigator.of(context).pop(); // Luk dialog
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Kun bogstaver er tilladt (min. 2 bogstaver)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // DEBUGGING: Log hvis man annullerer
              debugPrint('Ord indtastning annulleret');
              Navigator.of(context).pop(); // Luk dialog
              Navigator.of(context).pop(); // Gå tilbage til menu
            },
            child: const Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () {
              final word = wordController.text.trim().toLowerCase();
              if (_validateWord(word)) {
                _startNewGameWithWord(word);
                Navigator.of(context).pop(); // Luk dialog
              } else {
                // Vis fejlbesked hvis ordet ikke er gyldigt
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ordet skal indeholde mindst 2 bogstaver og kun bogstaver (a-z, æ, ø, å)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Start spil'),
          ),
        ],
      ),
    );
  }

  /// Valider om ordet er gyldigt
  bool _validateWord(String word) {
    // DEBUGGING: Log validering
    debugPrint('Validerer ord: $word');
    
    if (word.length < 2) {
      debugPrint('Ord for kort: ${word.length} bogstaver');
      return false;
    }
    
    // Tjek at ordet kun indeholder bogstaver (inkl. danske bogstaver)
    final validPattern = RegExp(r'^[a-zæøå]+$');
    if (!validPattern.hasMatch(word)) {
      debugPrint('Ord indeholder ugyldige tegn');
      return false;
    }
    
    debugPrint('Ord er gyldigt');
    return true;
  }

  /// Start et nyt spil med indtastet ord
  void _startNewGameWithWord(String word) {
    // STATE MANAGEMENT: setState() opdaterer alle state variabler og rebuilds UI
    setState(() {
      _selectedWord = word.toLowerCase();
      _guessedLetters = [];
      _wrongGuesses = 0;
      _gameWon = false;
      _gameOver = false;
      _wordEntered = true;
    });

    // DEBUGGING TIP: Brug debugPrint() i stedet for print() i Flutter
    // debugPrint() respekterer Flutter's debug flag
    debugPrint('Nyt spil startet. Ord: $_selectedWord (${_selectedWord.length} bogstaver)');
    
    // Sæt fokus så keyboard input virker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    
    // DEBUGGING: I VSCode kan du sætte et breakpoint her og:
    // 1. Se værdien af _selectedWord i Debug Console
    // 2. Inspicere alle state variabler
    // 3. Step through koden linje for linje (F10)
  }

  /// Start et helt nyt spil (vis dialog igen)
  void _startNewGame() {
    _showWordInputDialog();
  }

  /// Håndter et bogstav gæt
  void _guessLetter(String letter) {
    if (_gameOver || _guessedLetters.contains(letter)) {
      return;
    }

    setState(() {
      _guessedLetters.add(letter);

      // Tjek om bogstavet findes i ordet
      if (!_selectedWord.contains(letter)) {
        _wrongGuesses++;
        debugPrint('Forkert gæt: $letter (Forkerte: $_wrongGuesses/$_maxWrongGuesses)');
      } else {
        debugPrint('Korrekt gæt: $letter');
      }

      // Tjek om spillet er vundet (alle bogstaver er gættet)
      _gameWon = _selectedWord
          .split('')
          .every((char) => _guessedLetters.contains(char));

      // Tjek om spillet er tabt (for mange forkerte gæt)
      if (_wrongGuesses >= _maxWrongGuesses) {
        _gameOver = true;
      } else if (_gameWon) {
        _gameOver = true;
      }
    });

    // DEBUGGING: Log spil status efter hver gæt
    if (_gameOver) {
      debugPrint('Spil afsluttet. Vundet: $_gameWon, Ord: $_selectedWord');
      
      // Vis dialog når spillet er slut
      _showGameOverDialog();
    }
  }

  /// Håndter keyboard input
  /// DRY PRINCIP: Bruger KeyboardInputService til at håndtere keyboard input
  void _onKeyPressed(String key) {
    if (_gameOver || !_wordEntered) return;
    
    // Hangman behøver ikke ENTER eller BACKSPACE, kun bogstaver
    if (key != 'ENTER' && key != 'BACKSPACE') {
      _guessLetter(key.toLowerCase());
    }
  }

  /// Vis game over dialog
  void _showGameOverDialog() {
    // ROUTING: Navigator.pop() bruges også til at lukke dialogs
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_gameWon ? 'Tillykke!' : 'Spillet er slut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_gameWon
                ? 'Du gættede ordet korrekt!'
                : 'Det rigtige ord var: $_selectedWord'),
            const SizedBox(height: 16),
            // STATE MANAGEMENT EKSEMPEL: Vis statistik
            // I en større app kunne man bruge ChangeNotifier/Provider her
            Text(
              'Forkerte gæt: $_wrongGuesses/$_maxWrongGuesses',
              style: TextStyle(
                color: _wrongGuesses >= _maxWrongGuesses
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Luk dialog
              _showWordInputDialog(); // Vis dialog til at indtaste nyt ord
            },
            child: const Text('Nyt spil'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Luk dialog
              Navigator.of(context).pop(); // ROUTING: Gå tilbage til menu
            },
            child: const Text('Tilbage til menu'),
          ),
        ],
      ),
    );
  }

  /// Hent det visuelle ord (med underscores for ikke-gættede bogstaver)
  String _getDisplayWord() {
    return _selectedWord
        .split('')
        .map((char) => _guessedLetters.contains(char) ? char : '_')
        .join(' ');
  }

  /// Tegn Hangman figuren
  Widget _buildHangman() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 250,
        child: CustomPaint(
          painter: _HangmanPainter(_wrongGuesses),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DEBUGGING: Hvis ordet ikke er indtastet endnu, vis venteskærm
    if (!_wordEntered) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('HANGMAN'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        // DRY PRINCIP: Bruger KeyboardInputService til at håndtere keyboard input
        // Samme service som Wordle bruger - genbrugelig kode!
        _keyboardService.handleKeyEvent(
          event,
          onKeyPressed: _onKeyPressed,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HANGMAN'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // ROUTING EKSEMPEL 3: Navigator.pop() - Gå tilbage til forrige side
            onPressed: () {
              debugPrint('Navigerer tilbage til menu');
              Navigator.of(context).pop();
            },
          ),
          actions: [
            // Knap til at starte nyt spil med nyt ord
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Nyt spil',
              onPressed: () {
                debugPrint('Bruger ønsker nyt spil');
                _startNewGame();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Centreret indhold i toppen (scrollbart hvis nødvendigt)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hangman tegning
                        _buildHangman(),
                        
                        const SizedBox(height: 32),

                        // Vis ordet
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            _getDisplayWord(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Spil status
                        Text(
                          _gameOver
                              ? (_gameWon ? 'Du vandt!' : 'Du tabte!')
                              : 'Forkerte gæt: $_wrongGuesses/$_maxWrongGuesses',
                          style: TextStyle(
                            fontSize: 18,
                            color: _gameOver
                                ? (_gameWon ? Colors.green : Colors.red)
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Gættede bogstaver
                        if (_guessedLetters.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: _guessedLetters.map((letter) {
                                final isWrong = !_selectedWord.contains(letter);
                                return Chip(
                                  label: Text(
                                    letter.toUpperCase(),
                                    style: TextStyle(
                                      color: isWrong ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: isWrong
                                      ? Colors.red.shade100
                                      : Colors.green.shade100,
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Keyboard i bunden
            _buildKeyboard(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Byg keyboard til at vælge bogstaver - Wordle stil layout
  Widget _buildKeyboard() {
    // Wordle keyboard layout med danske bogstaver i 4. række
    final rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
      ['Æ', 'Ø', 'Å'],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Beregn knap-størrelse baseret på tilgængelig bredde
        final screenWidth = constraints.maxWidth;
        final padding = 32.0; // Total padding (16 på hver side)
        final availableWidth = screenWidth - padding;
        
        // Find den længste række (første række med 10 bogstaver)
        final longestRow = 10;
        final spacing = 4.0; // 2 pixels på hver side pr. knap
        final maxButtonWidth = (availableWidth - (longestRow - 1) * spacing) / longestRow;
        
        // Begræns knap-størrelse mellem 28 og 32 pixels
        final buttonWidth = maxButtonWidth.clamp(28.0, 32.0);
        final buttonHeight = (buttonWidth * 1.5).clamp(42.0, 48.0);
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: row.map((key) {
                    final isGuessed = _guessedLetters.contains(key.toLowerCase());
                    final isWrong = isGuessed && !_selectedWord.contains(key.toLowerCase());
                    final isCorrect = isGuessed && _selectedWord.contains(key.toLowerCase());
                    
                    // Bestem farve baseret på status
                    Color? keyColor;
                    Color? textColor = Colors.black;
                    
                    if (isWrong) {
                      keyColor = Colors.red.shade300;
                      textColor = Colors.white;
                    } else if (isCorrect) {
                      keyColor = Colors.green.shade300;
                      textColor = Colors.white;
                    } else if (isGuessed) {
                      keyColor = Colors.grey.shade300;
                    } else {
                      keyColor = Colors.grey.shade300;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: isGuessed || _gameOver
                              ? null
                              : () => _guessLetter(key.toLowerCase()),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: keyColor,
                            foregroundColor: textColor,
                            disabledBackgroundColor: keyColor,
                            disabledForegroundColor: textColor,
                          ),
                          child: Text(
                            key,
                            style: TextStyle(
                              fontSize: buttonWidth * 0.35,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Custom painter til at tegne Hangman figuren
/// DEBUGGING TIP: Du kan sætte breakpoints i paint() metoden for at se
/// hvordan tegningen opdateres baseret på _wrongGuesses state
class _HangmanPainter extends CustomPainter {
  final int wrongGuesses;

  _HangmanPainter(this.wrongGuesses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final height = size.height;

    // Tegn galge (altid synlig)
    if (wrongGuesses >= 1) {
      // Base
      canvas.drawLine(
        Offset(20, height - 20),
        Offset(80, height - 20),
        paint,
      );
    }

    if (wrongGuesses >= 2) {
      // Støtte
      canvas.drawLine(
        Offset(50, height - 20),
        Offset(50, 20),
        paint,
      );
    }

    if (wrongGuesses >= 3) {
      // Top
      canvas.drawLine(
        Offset(50, 20),
        Offset(150, 20),
        paint,
      );
    }

    if (wrongGuesses >= 4) {
      // Rope
      canvas.drawLine(
        Offset(150, 20),
        Offset(150, 60),
        paint,
      );
    }

    // Tegn person (kun hvis der er gæt)
    if (wrongGuesses >= 5) {
      // Hoved
      canvas.drawCircle(Offset(150, 80), 20, paint);
    }

    if (wrongGuesses >= 6) {
      // Krop
      canvas.drawLine(
        Offset(150, 100),
        Offset(150, 180),
        paint,
      );
    }

    if (wrongGuesses >= 7) {
      // Arme
      canvas.drawLine(
        Offset(150, 120),
        Offset(120, 160),
        paint,
      );
      canvas.drawLine(
        Offset(150, 120),
        Offset(180, 160),
        paint,
      );
      // Ben
      canvas.drawLine(
        Offset(150, 180),
        Offset(120, 220),
        paint,
      );
      canvas.drawLine(
        Offset(150, 180),
        Offset(180, 220),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HangmanPainter oldDelegate) {
    return oldDelegate.wrongGuesses != wrongGuesses;
  }
}
