import 'package:meta/meta.dart';

@immutable
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.offset,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      offset: json['offset'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }

  final List<T> items;
  final int offset;
  final int limit;
  final int total;
  final bool hasMore;

  Map<String, dynamic> toJson(T Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'offset': offset,
      'limit': limit,
      'total': total,
      'hasMore': hasMore,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatedResponse<T> &&
        other.items == items &&
        other.offset == offset &&
        other.limit == limit &&
        other.total == total &&
        other.hasMore == hasMore;
  }

  @override
  int get hashCode {
    return Object.hash(items, offset, limit, total, hasMore);
  }
}
