class WeightResponse {
  final bool isStable;
  final bool isGross;
  final double weight;
  final String unit;

  WeightResponse({
    required this.isStable,
    required this.isGross,
    required this.weight,
    required this.unit,
  });

  factory WeightResponse.parse(String raw) {
    final parts = raw.trim().split(',');
    if (parts.length < 3) {
      throw FormatException('Invalid response format');
    }

    final weightPart = parts[2];
    final match = RegExp(r'([+-]?\d+\.\d+)([a-zA-Z]+)').firstMatch(weightPart);
    if (match == null) {
      throw FormatException('Weight format not matched');
    }

    return WeightResponse(
      isStable: parts[0] == 'ST',
      isGross: parts[1] == 'GS',
      weight: double.parse(match.group(1)!),
      unit: match.group(2)!,
    );
  }

  @override
  String toRawString() {
    final status = isStable ? 'ST' : 'US';
    final mode = isGross ? 'GS' : 'NT';
    final sign = weight >= 0 ? '+' : '';
    return '$status,$mode,$sign${weight.toStringAsFixed(2)}$unit\r\n';
  }
}