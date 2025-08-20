enum MessageType {
  text,
  image,
  file,
  location,
  link,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

// Sender information
class MessageSender {
  const MessageSender({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  final String id;
  final String name;
  final String? profilePicture;

  MessageSender copyWith({
    String? id,
    String? name,
    String? profilePicture,
  }) {
    return MessageSender(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}

// Location info for location messages
class MessageLocation {
  const MessageLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  MessageLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return MessageLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}

// Link preview for link messages
class MessageLinkPreview {
  const MessageLinkPreview({
    required this.url,
    required this.title,
    this.description,
    this.imageUrl,
  });

  final String url;
  final String title;
  final String? description;
  final String? imageUrl;

  MessageLinkPreview copyWith({
    String? url,
    String? title,
    String? description,
    String? imageUrl,
  }) {
    return MessageLinkPreview(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// File info for file messages
class MessageFileInfo {
  const MessageFileInfo({
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.mimeType,
  });

  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String? mimeType;

  MessageFileInfo copyWith({
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
  }) {
    return MessageFileInfo(
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
    );
  }
}

// Main Message class - simplified and focused
class Message {
  const Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.replyToMessageId,
    this.location,
    this.linkPreview,
    this.fileInfo,
  });

  final String id;
  final String chatId;
  final MessageSender sender;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? replyToMessageId;
  final MessageLocation? location;
  final MessageLinkPreview? linkPreview;
  final MessageFileInfo? fileInfo;

  Message copyWith({
    String? id,
    String? chatId,
    MessageSender? sender,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? replyToMessageId,
    MessageLocation? location,
    MessageLinkPreview? linkPreview,
    MessageFileInfo? fileInfo,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      location: location ?? this.location,
      linkPreview: linkPreview ?? this.linkPreview,
      fileInfo: fileInfo ?? this.fileInfo,
    );
  }
}
