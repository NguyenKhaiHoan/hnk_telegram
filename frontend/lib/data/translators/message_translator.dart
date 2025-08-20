import 'package:telegram_frontend/data/services/api/model/message/message_api_model.dart';
import 'package:telegram_frontend/domain/models/message.dart';

class MessageTranslator {
  Message toDomain(MessageApiModel apiModel) {
    return Message(
      id: apiModel.id,
      chatId: apiModel.chatId,
      sender: MessageSender(
        id: apiModel.sender.id,
        name: apiModel.sender.name,
        profilePicture: apiModel.sender.profilePicture,
      ),
      content: apiModel.content,
      type: _mapApiTypeToDomain(apiModel.type),
      status: _mapApiStatusToDomain(apiModel.status),
      timestamp: DateTime.parse(apiModel.timestamp),
      replyToMessageId: apiModel.replyToMessageId,
      location: apiModel.location != null
          ? MessageLocation(
              latitude: apiModel.location!.latitude,
              longitude: apiModel.location!.longitude,
              address: apiModel.location!.address,
            )
          : null,
      linkPreview: apiModel.linkPreview != null
          ? MessageLinkPreview(
              url: apiModel.linkPreview!.url,
              title: apiModel.linkPreview!.title,
              description: apiModel.linkPreview!.description,
              imageUrl: apiModel.linkPreview!.imageUrl,
            )
          : null,
      fileInfo: apiModel.fileInfo != null
          ? MessageFileInfo(
              fileName: apiModel.fileInfo!.fileName,
              fileUrl: apiModel.fileInfo!.fileUrl,
              fileSize: apiModel.fileInfo!.fileSize,
              mimeType: apiModel.fileInfo!.mimeType,
            )
          : null,
    );
  }

  MessageApiModel toApi(Message domainModel) {
    return MessageApiModel(
      id: domainModel.id,
      chatId: domainModel.chatId,
      sender: MessageSenderApi(
        id: domainModel.sender.id,
        name: domainModel.sender.name,
        profilePicture: domainModel.sender.profilePicture,
      ),
      content: domainModel.content,
      type: _mapDomainTypeToApi(domainModel.type),
      status: _mapDomainStatusToApi(domainModel.status),
      timestamp: domainModel.timestamp.toIso8601String(),
      replyToMessageId: domainModel.replyToMessageId,
      location: domainModel.location != null
          ? MessageLocationApi(
              latitude: domainModel.location!.latitude,
              longitude: domainModel.location!.longitude,
              address: domainModel.location!.address,
            )
          : null,
      linkPreview: domainModel.linkPreview != null
          ? MessageLinkPreviewApi(
              url: domainModel.linkPreview!.url,
              title: domainModel.linkPreview!.title,
              description: domainModel.linkPreview!.description,
              imageUrl: domainModel.linkPreview!.imageUrl,
            )
          : null,
      fileInfo: domainModel.fileInfo != null
          ? MessageFileInfoApi(
              fileName: domainModel.fileInfo!.fileName,
              fileUrl: domainModel.fileInfo!.fileUrl,
              fileSize: domainModel.fileInfo!.fileSize,
              mimeType: domainModel.fileInfo!.mimeType,
            )
          : null,
    );
  }

  MessageType _mapApiTypeToDomain(MessageTypeApi apiType) {
    switch (apiType) {
      case MessageTypeApi.text:
        return MessageType.text;
      case MessageTypeApi.image:
        return MessageType.image;
      case MessageTypeApi.file:
        return MessageType.file;
      case MessageTypeApi.location:
        return MessageType.location;
      case MessageTypeApi.link:
        return MessageType.link;
    }
  }

  MessageTypeApi _mapDomainTypeToApi(MessageType domainType) {
    switch (domainType) {
      case MessageType.text:
        return MessageTypeApi.text;
      case MessageType.image:
        return MessageTypeApi.image;
      case MessageType.file:
        return MessageTypeApi.file;
      case MessageType.location:
        return MessageTypeApi.location;
      case MessageType.link:
        return MessageTypeApi.link;
    }
  }

  MessageStatus _mapApiStatusToDomain(MessageStatusApi apiStatus) {
    switch (apiStatus) {
      case MessageStatusApi.sending:
        return MessageStatus.sending;
      case MessageStatusApi.sent:
        return MessageStatus.sent;
      case MessageStatusApi.delivered:
        return MessageStatus.delivered;
      case MessageStatusApi.read:
        return MessageStatus.read;
      case MessageStatusApi.failed:
        return MessageStatus.failed;
    }
  }

  MessageStatusApi _mapDomainStatusToApi(MessageStatus domainStatus) {
    switch (domainStatus) {
      case MessageStatus.sending:
        return MessageStatusApi.sending;
      case MessageStatus.sent:
        return MessageStatusApi.sent;
      case MessageStatus.delivered:
        return MessageStatusApi.delivered;
      case MessageStatus.read:
        return MessageStatusApi.read;
      case MessageStatus.failed:
        return MessageStatusApi.failed;
    }
  }
}
