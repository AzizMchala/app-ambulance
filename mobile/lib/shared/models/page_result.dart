import 'package:flutter/foundation.dart';

/// Une page de résultats renvoyée par l'API (format commun à tous les modules).
@immutable
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> items;

  /// Index de page, à partir de 0.
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  bool get hasNext => page + 1 < totalPages;

  static PageResult<T> fromJson<T>(Map<String, Object?> json, T Function(Map<String, Object?>) item) {
    final raw = json['items']! as List<Object?>;
    return PageResult<T>(
      items: [for (final e in raw) item((e! as Map).cast<String, Object?>())],
      page: (json['page']! as num).toInt(),
      size: (json['size']! as num).toInt(),
      totalElements: (json['totalElements']! as num).toInt(),
      totalPages: (json['totalPages']! as num).toInt(),
    );
  }
}
