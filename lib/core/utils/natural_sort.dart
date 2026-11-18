class NaturalSort {
  static final RegExp _chunkRegex = RegExp(r'(\d+|\D+)');

  /// Compares two strings using natural / alphanumeric sort order
  /// e.g. "Episode 2" comes before "Episode 10"
  static int compare(String a, String b) {
    final List<String> chunksA = _chunkRegex.allMatches(a.toLowerCase()).map((m) => m.group(0)!).toList();
    final List<String> chunksB = _chunkRegex.allMatches(b.toLowerCase()).map((m) => m.group(0)!).toList();

    final int len = chunksA.length < chunksB.length ? chunksA.length : chunksB.length;

    for (int i = 0; i < len; i++) {
      final String partA = chunksA[i];
      final String partB = chunksB[i];

      final int? numA = int.tryParse(partA);
      final int? numB = int.tryParse(partB);

      if (numA != null && numB != null) {
        final int numCompare = numA.compareTo(numB);
        if (numCompare != 0) return numCompare;
      } else {
        final int strCompare = partA.compareTo(partB);
        if (strCompare != 0) return strCompare;
      }
    }

    return chunksA.length.compareTo(chunksB.length);
  }
}
