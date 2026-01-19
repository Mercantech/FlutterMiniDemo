enum LetterStatus {
  correct, // Grøn - bogstavet er på den rigtige position
  present, // Gul - bogstavet findes i ordet men ikke på den position
  absent,  // Grå - bogstavet findes ikke i ordet
  empty,   // Tom - ikke gættet endnu
}

class Letter {
  final String character;
  final LetterStatus status;

  Letter({
    required this.character,
    required this.status,
  });
}
