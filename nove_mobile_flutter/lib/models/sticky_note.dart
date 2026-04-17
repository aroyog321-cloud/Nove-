enum StickyColor { yellow, pink, green, blue }

class StickyNote {
  final String id;
  final String title;
  final String content;
  final StickyColor color;
  final int createdAt;

  const StickyNote({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
  });

  StickyNote copyWith({
    String? id,
    String? title,
    String? content,
    StickyColor? color,
    int? createdAt,
  }) {
    return StickyNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.name,
      'created_at': createdAt,
    };
  }

  factory StickyNote.fromMap(Map<String, dynamic> map) {
    return StickyNote(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      color: StickyColor.values.firstWhere(
        (c) => c.name == map['color'],
        orElse: () => StickyColor.yellow,
      ),
      createdAt: map['created_at'] as int,
    );
  }
}
