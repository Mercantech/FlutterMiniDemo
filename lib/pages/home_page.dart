import 'package:flutter/material.dart';

/// HOME PAGE - Demonstrerer ROUTING og NAVIGATION
/// 
/// I Flutter bruges Navigator til navigation mellem sider.
/// Hovedkoncepter:
/// 1. Navigator.push() - Skubber en ny side på stakken (direkte navigation)
/// 2. Navigator.pop() - Tager den nuværende side af stakken
/// 3. Navigator.pushNamed() - Navigation ved navn (named routes) ✅ BRUGT HER
/// 
/// NAMED ROUTES:
/// Vi bruger nu named routes som er defineret i lib/routes/app_routes.dart
/// FORDELE:
/// - Routes vises i URL'en når appen kører i web browser
/// - Deep linking muligheder (bookmark direkte til /wordle)
/// - Centraliseret route management
/// 
/// DEBUGGING TIP: 
/// - Brug debugPrint() til at logge navigation
/// - I VSCode kan du sætte breakpoints og bruge Debug Console til at inspicere state
/// - Kør appen i web browser for at se routes i URL'en!
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // DEBUGGING: Log når siden bygges
    debugPrint('HomePage bygges');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Spil Menu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vælg et spil!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              
              // Wordle knap - Demonstrerer named routes navigation
              _GameCard(
                title: 'WORDLE',
                description: 'Gæt det 5-bogstavs ord',
                icon: Icons.grid_view,
                color: Colors.green,
                onTap: () {
                  // ROUTING EKSEMPEL 2: Navigator.pushNamed() - Named Routes
                  // Dette bruger route navnet i stedet for MaterialPageRoute
                  // FORDELE:
                  // - Routes vises i URL'en (i web versionen)
                  // - Deep linking muligheder
                  // - Centraliseret route management
                  debugPrint('Navigerer til WordlePage via named route: /wordle');
                  
                  // DEBUGGING TIP: Sæt et breakpoint på næste linje i VSCode
                  // Højreklik på linjenummer -> "Toggle Breakpoint"
                  // Kør appen i Debug mode (F5) og se variabler i Debug Console
                  // I web browser kan du nu se URL'en ændre sig til /wordle
                  Navigator.pushNamed(
                    context,
                    '/wordle', // Route navn defineret i AppRoutes
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Hangman knap - Demonstrerer named routes navigation
              _GameCard(
                title: 'HANGMAN',
                description: 'Gæt ordet bogstav for bogstav',
                icon: Icons.psychology,
                color: Colors.blue,
                onTap: () {
                  // ROUTING EKSEMPEL 2: Named routes med debugging
                  debugPrint('Navigerer til HangmanPage via named route: /hangman');
                  
                  // Navigator.pushNamed() returnerer også Future som kan håndtere resultater
                  Navigator.pushNamed(
                    context,
                    '/hangman', // Route navn defineret i AppRoutes
                  ).then((result) {
                    // DEBUGGING: Log resultat når vi kommer tilbage
                    // .then() kaldes når den nye side popper (Navigator.pop())
                    debugPrint('Kom tilbage fra HangmanPage med resultat: $result');
                    // I web browser kan du se URL'en gå tilbage til /
                  });
                },
              ),
              
              const SizedBox(height: 48),
              
              // Info kort om koncepterne
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flutter Koncepter i denne app:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ConceptItem(
                        icon: Icons.bug_report,
                        title: 'Debugging',
                        description: 'Brug VSCode breakpoints og debugPrint()',
                      ),
                      const SizedBox(height: 8),
                      _ConceptItem(
                        icon: Icons.navigation,
                        title: 'Routing & Navigation',
                        description: 'Navigator.pushNamed() og named routes',
                      ),
                      const SizedBox(height: 8),
                      _ConceptItem(
                        icon: Icons.settings,
                        title: 'State Management',
                        description: 'setState() og ChangeNotifier',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget til at vise et spil kort
class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget til at vise et koncept item
class _ConceptItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ConceptItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
