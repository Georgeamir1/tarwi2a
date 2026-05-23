String exportToCsv(List<Map<String, dynamic>> rows, List<String> headers) {
  final buffer = StringBuffer();

  buffer.writeln(headers.map((h) => '"$h"').join(','));

  for (final row in rows) {
    final values = headers.map((h) {
      final val = row[h]?.toString() ?? '';
      return '"${val.replaceAll('"', '""')}"';
    }).join(',');
    buffer.writeln(values);
  }

  return buffer.toString();
}

List<Map<String, dynamic>> reportsToCsvRows(dynamic reportData) {
  return reportData.revenueByDay
      .map<Map<String, dynamic>>((day) => {
            'date':
                '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-${day.date.day.toString().padLeft(2, '0')}',
            'revenue': day.revenue.toStringAsFixed(2),
            'orders': day.orderCount.toString(),
          })
      .toList();
}
