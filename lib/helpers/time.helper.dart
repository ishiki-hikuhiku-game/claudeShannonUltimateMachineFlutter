String formatDiff(DateTime after, DateTime before) {
  final diff = after.difference(before);
  final hours = diff.inHours.toString().padLeft(2, "0");
  final minutes = diff.inMinutes.toString().padLeft(2, "0");
  final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, "0");
  return "$hours:$minutes:$seconds";
}
