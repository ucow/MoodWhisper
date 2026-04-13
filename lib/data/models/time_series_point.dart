/// A data point for time series charts
class TimeSeriesPoint {
  final DateTime date;
  final double value;
  final int count;

  const TimeSeriesPoint({
    required this.date,
    required this.value,
    this.count = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'value': value,
      'count': count,
    };
  }

  factory TimeSeriesPoint.fromMap(Map<String, dynamic> map) {
    return TimeSeriesPoint(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      value: (map['value'] as num).toDouble(),
      count: map['count'] as int? ?? 0,
    );
  }
}
