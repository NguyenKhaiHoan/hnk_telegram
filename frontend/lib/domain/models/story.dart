class Story {
  Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfilePicture,
    required this.storyPicture,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    required this.viewCount,
    this.isCurrentUserStory = false,
    this.isSeen = false,
    this.caption,
  });

  final String id;
  final String userId;
  final String userName;
  final String userProfilePicture;
  final String storyPicture;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final int viewCount;
  final bool isCurrentUserStory;
  final bool isSeen;

  Story copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfilePicture,
    String? storyPicture,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    int? viewCount,
    bool? isCurrentUserStory,
    bool? isSeen,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      storyPicture: storyPicture ?? this.storyPicture,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      isCurrentUserStory: isCurrentUserStory ?? this.isCurrentUserStory,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}
