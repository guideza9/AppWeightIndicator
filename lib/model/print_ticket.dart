class PrintTicket {
  final int no;
  final DateTime dateTime;
  final double grossWeight;
  final double tareWeight;

  PrintTicket({
    required this.no,
    required this.dateTime,
    required this.grossWeight,
    required this.tareWeight,
  });

  double get netWeight => grossWeight - tareWeight;

  String format() {
    final date =
        "${_2(dateTime.year % 100)}.${_2(dateTime.month)}.${_2(dateTime.day)}";
    final time =
        "${_2(dateTime.hour)}.${_2(dateTime.minute)}.${_2(dateTime.second)}";

    return '''
NO. ${_3(no)} （NO.）
Date: $date
Time: $time
G.W: ${grossWeight.toStringAsFixed(2)}kg
T.W: ${tareWeight.toStringAsFixed(2)}kg
N.W: ${netWeight.toStringAsFixed(2)}kg\r\n
''';
  }

  String _2(int n) => n.toString().padLeft(2, '0');
  String _3(int n) => n.toString().padLeft(3, '0');
}
