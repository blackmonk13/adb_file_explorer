void main() {
  List<String> pathSegments = [
    "devices",
    "R4ND0MS3R14L",
    "/storage/emulated/0"
  ];

  List<String> breadcrumbs = [];

  for (final segment in pathSegments) {
    final segmentIndex = pathSegments.indexOf(segment);
    String segmentPath = '';

    if (segmentIndex <= 1) {
      segmentPath = pathSegments.sublist(0, segmentIndex + 1).join('/');
      breadcrumbs.add("$segmentIndex - $segmentPath - $segment");
    } else {
      for (final subSegment in segment.split('/')) {
        final dirSegment = subSegment.isEmpty ? '/' : subSegment;
        final encodedSegment = Uri.encodeComponent(dirSegment);
        segmentPath = [
          pathSegments.sublist(0, segmentIndex).join('/'),
          encodedSegment,
        ].join('/');
        breadcrumbs.add("$segmentIndex - $segmentPath - $dirSegment");
      }
    }
  }

  for (var element in breadcrumbs) {
    print(element);
  }
}
