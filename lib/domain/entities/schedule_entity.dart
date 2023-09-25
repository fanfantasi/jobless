class ScheduleEntity {
  final String? error;
  final List<String> interview;
  final List<String> dates;
  final String message;
  const ScheduleEntity(
      {this.error,
      required this.interview,
      required this.dates,
      required this.message});
}
