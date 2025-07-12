class AccumulatedTicket {
  final int no;
  final DateTime dateTime;
  final int totalCount;
  final double totalWeight;

  AccumulatedTicket({
    required this.no,
    required this.dateTime,
    required this.totalCount,
    required this.totalWeight,
  });

  String format() {
    final date = "${_2(dateTime.year % 100)}.${_2(dateTime.month)}.${_2(dateTime.day)}";
    final time = "${_2(dateTime.hour)}.${_2(dateTime.minute)}.${_2(dateTime.second)}";

    return '''
'NO. ${_3(no)} （NO.）'
Date: $date
Time: $time
Total: ${_3(totalCount)}
Total.W: ${totalWeight.toStringAsFixed(2)}kg\r\n
''';
  }

  String _2(int n) => n.toString().padLeft(2, '0');
  String _3(int n) => n.toString().padLeft(3, '0');
}
