class BMIRecord {
  final DateTime date;
  final double weight;
  final double height;
  final double bmi;
  final String category;

  BMIRecord({
    required this.date,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'category': category,
    };
  }

  factory BMIRecord.fromJson(Map<String, dynamic> json) {
    return BMIRecord(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      category: json['category'] as String,
    );
  }
}
