class HourEntry {
  final int? id;
  final String category;
  final int hours;
  final DateTime date;
  final String? proofPath;

  HourEntry({
    this.id,
    required this.category,
    required this.hours,
    required this.date,
    this.proofPath,
  });

  // Converte o objeto em um mapa para o banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'hours': hours,
      'date': date.toIso8601String(),
      'proofPath': proofPath,
    };
  }

  // Converte um mapa do banco de dados para um objeto
  factory HourEntry.fromMap(Map<String, dynamic> map) {
    return HourEntry(
      id: map['id'],
      category: map['category'],
      hours: map['hours'],
      date: DateTime.parse(map['date']),
      proofPath: map['proofPath'],
    );
  }
}
