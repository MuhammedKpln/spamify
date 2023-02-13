import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';
import 'package:spamify/features/mails/models/message.model.dart';
import 'package:spamify/features/mails/models/single_message.model.dart';
import 'package:spamify/features/mails/repositories/messages.repository.dart';
import 'package:spamify/storage/messages.storage.dart';
import 'package:url_launcher/url_launcher.dart';

part 'messages.controller.g.dart';

@LazySingleton()
class MessagesController = _MessagesControllerBase with _$MessagesController;

abstract class _MessagesControllerBase with Store {
  _MessagesControllerBase(this.messagesRepository, this.messagesStorage);

  MessagesRepository messagesRepository;
  MessagesStorage messagesStorage;

  @observable
  bool isLoading = true;

  @observable
  StreamController<List<Message>> messages = StreamController.broadcast();

  @observable
  SingleMessage? showingMessage;

  @observable
  bool isFetchingSingleMessage = false;

  @observable
  ObservableList<Message> selectedMessages = ObservableList.of([]);

  @observable
  bool deleteMode = false;

  @action
  init() async {
    fetchLocalMessages();
    fetchMessagesPeriodically();
  }

  @action
  Future<void> fetchMessages() async {
    final messagesFromRepo = await messagesRepository.fetchMessages();

    if (messagesFromRepo.hydraTotalItems > 0) {
      final _messages = messagesFromRepo.hydraMember.toList();
      final alreadyStored = await messagesStorage.containsMessage(_messages[0]);

      if (!alreadyStored || !deleteMode) {
        _saveMessagesToDatabase(_messages);
        messages.sink.add(_messages);
      }
    }
  }

  @action
  Future<void> fetchLocalMessages() async {
    final messagesFromRepo = await messagesStorage.fetchMessages();

    final mappedList =
        messagesFromRepo.map((e) => Message.fromJson(e.toMap())).toList();

    messages.sink.add(mappedList);
  }

  Future<void> _saveMessagesToDatabase(List<Message> messages) async {
    for (var message in messages) {
      final contains = await messagesStorage.containsMessage(message);

      if (!contains) {
        await messagesStorage.saveMessage(message);
      }
    }
  }

  fetchMessagesPeriodically() {
    Timer.periodic(const Duration(seconds: 5), (_) => fetchMessages());
  }

  @action
  fetchMessage(Message message) async {
    isFetchingSingleMessage = true;
    final messageFromRepo =
        await messagesRepository.fetchMessage(message.hydraMemberId);

    showingMessage = messageFromRepo;
    isFetchingSingleMessage = false;
  }

  @action
  void toggleMessageCheckbox(Message message) {
    final contains = selectedMessages.contains(message);

    if (contains) {
      selectedMessages.remove(message);
      return;
    }

    selectedMessages.add(message);
  }

  @action
  deleteMessages() {
    print(selectedMessages);
  }

  FutureOr<bool> onTapUrl(String url) async {
    final uri = Uri.parse(url);

    await canLaunchUrl(uri)
        ? launchUrl(uri, mode: LaunchMode.externalApplication)
        : false;

    return true;
  }

  @action
  toggleDeleteMode() {
    deleteMode = !deleteMode;

    if (!deleteMode) {
      selectedMessages.clear();
    }
  }
}
