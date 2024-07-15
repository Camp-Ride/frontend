import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campride/ReplyingState.dart';
import 'package:campride/messages_provider.dart';
import 'package:campride/room.dart';
import 'package:campride/rooms_provider.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends ConsumerWidget {
  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  String userName = "junTest";

  Row? getReactionIcon(String reaction, int reactionCount) {
    if (reaction == ('like')) {
      return Row(
        children: [
          Icon(
            Icons.favorite,
            color: Colors.red,
            size: 15.r,
          ),
          SizedBox(
            width: 3.w,
          ),
          Text(
            reactionCount.toString(),
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(
            width: 3.w,
          ),
        ],
      );
    } else if (reaction == ('hate')) {
      return Row(
        children: [
          Icon(
            Icons.close,
            size: 15.r,
          ),
          SizedBox(
            width: 3.w,
          ),
          Text(
            reactionCount.toString(),
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(
            width: 3.w,
          ),
        ],
      );
    } else if (reaction == ('check')) {
      return Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.green,
            size: 15.r,
          ),
          SizedBox(
            width: 3.w,
          ),
          Text(
            reactionCount.toString(),
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(
            width: 3.w,
          ),
        ],
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = new DateTime.now();
    final rooms = ref.watch(roomsProvider);
    final messages = ref.watch(messagesProvider);
    var isReplying = ref.watch(replyingProvider);
    var replyingMessage = ref.watch(replyingMessageProvider);

    void addMessage(String text) {
      Message message = new Message(
          id: "test1",
          text: text,
          timestamp: now,
          isSender: true,
          messageType: MessageType.text,
          reactions: {},
          isReply: false,
          replyingMessage: "",
          imageUrl: '');
      ref.read(messagesProvider.notifier).addMessage(message);
    }

    void _onReply(var index, Message message) {
      ref.read(replyingProvider.notifier).startReplying();
      ref.read(replyingMessageProvider.notifier).startReplying(message.text);
    }

    void stopReply() {
      ref.read(replyingProvider.notifier).stopReplying();
      ref.read(replyingMessageProvider.notifier).stopReplying();
    }

    void _onReact(
        var index, Message message, String reaction, String userName) {
      final notifier = ref.read(messagesProvider.notifier);

      notifier.reactToMessage(index, reaction, userName);
    }

    void _showPopupMenu(
        BuildContext context, Message message, var index, Offset offset) {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      showMenu(
        color: Colors.white70,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0).r),
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          overlay.size.width - offset.dx,
          overlay.size.height - offset.dy,
        ),
        items: [
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.reply),
              title: Text('답장'),
              onTap: () {
                Navigator.pop(context);
                _onReply(index, message);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text('좋아요'),
              onTap: () {
                Navigator.pop(context);
                _onReact(index, message, 'like', userName);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('확인'),
              onTap: () {
                Navigator.pop(context);
                _onReact(index, message, 'check', userName);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.close),
              title: Text('싫어요'),
              onTap: () {
                Navigator.pop(context);
                _onReact(index, message, 'hate', userName);
              },
            ),
          ),
        ],
      );
    }

    Widget buildMessageWidget(Message message) {
      final time = DateFormat('h:mm a').format(message.timestamp);
      final alignment =
          message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start;
      final textColor = message.isSender ? Colors.white : Colors.black;

      Widget buildReplyWidget(String replyingMessage) {
        return !replyingMessage.endsWith(".png")
            ? Column(
                crossAxisAlignment: message.isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0).r,
                    margin: EdgeInsets.only(bottom: 4.0).r,
                    decoration: BoxDecoration(
                      color:
                          message.isSender ? Colors.blue[50] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0).r,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          replyingMessage,
                          style: TextStyle(
                            color:
                                message.isSender ? Colors.blue : Colors.black,
                          ),
                        )

                        // if (replyingMessage.imageUrl.isNotEmpty)
                        //   Image.network(replyingMessage.imageUrl, height: 50, fit: BoxFit.cover),
                      ],
                    ),
                  ),
                  message.isSender
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10.0).w,
                          child: Transform.flip(
                              flipY: true,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 10.0).w,
                          child: Transform.rotate(
                              angle: 3.14,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                ],
              )
            : Column(
                crossAxisAlignment: message.isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    child: BubbleNormalImage(
                      id: message.id,
                      image: _image(replyingMessage),
                      color: Colors.white,
                      tail: true,
                      isSender: message.isSender,
                    ),
                  ),
                  message.isSender
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20.0).w,
                          child: Transform.flip(
                              flipY: true,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 20.0).w,
                          child: Transform.rotate(
                              angle: 3.14,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                ],
              );
      }

      final reactionsWidget = Padding(
        padding: const EdgeInsets.only(left: 8.0).w,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0).r,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: message.reactions.keys.map((reaction) {
              return message.reactions[reaction]!.length == 0
                  ? Container()
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: getReactionIcon(
                          reaction, message.reactions[reaction]!.length),
                    );
            }).toList(),
          ),
        ),
      );

      final timeWidget = Text(
        time,
        style: TextStyle(color: Colors.black54, fontSize: 12.sp),
      );

      final reactionAndTime = message.isSender
          ? Row(
              mainAxisAlignment: alignment,
              children: [
                reactionsWidget,
                SizedBox(width: 8.0).w,
                timeWidget,
              ],
            )
          : Row(
              mainAxisAlignment: alignment,
              children: [
                timeWidget,
                SizedBox(width: 8.0).w,
                reactionsWidget,
              ],
            );

      switch (message.messageType) {
        case MessageType.text:
          return Column(
            crossAxisAlignment: message.isSender
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isReply && message.replyingMessage != null)
                buildReplyWidget(message.replyingMessage!),
              BubbleSpecialThree(
                text: message.text,
                color: message.isSender ? Color(0xFF1B97F3) : Color(0xFFE8E8EE),
                tail: false,
                textStyle: TextStyle(color: textColor, fontSize: 16),
                isSender: message.isSender,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 26.0, right: 26.0, top: 6.0).r,
                child: reactionAndTime,
              ),
            ],
          );
        case MessageType.image:
          return Column(
            crossAxisAlignment: message.isSender
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isReply && message.replyingMessage != null)
                buildReplyWidget(message.replyingMessage!),
              BubbleNormalImage(
                id: message.id,
                image: _image(message.imageUrl),
                color: Colors.white,
                tail: true,
                isSender: message.isSender,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26.0, right: 26.0).w,
                child: reactionAndTime,
              ),
            ],
          );
        default:
          return Container();
      }
    }

    Widget buildMessageList(List<Message> messages) {
      List<Widget> messageWidgets = [];
      DateTime? lastDate;

      for (var i = 0; i < messages.length; i++) {
        if (lastDate == null || !isSameDay(lastDate, messages[i].timestamp)) {
          messageWidgets.add(DateChip(date: messages[i].timestamp));
          lastDate = messages[i].timestamp;
        }

        messageWidgets.add(
          GestureDetector(
            onLongPressStart: (details) {
              _showPopupMenu(context, messages[i], i, details.globalPosition);
            },
            child: buildMessageWidget(messages[i]),
          ),
        );
      }

      return ListView(
        children: messageWidgets,
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          rooms[0].title,
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF355A50), Color(0xFF154135)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: buildMessageList(messages)),
          MessageBar(
            replying: isReplying,
            replyingTo: replyingMessage,
            onTapCloseReply: stopReply,
            onSend: (String text) => addMessage(text),
            actions: [
              InkWell(
                child: Icon(
                  Icons.image,
                  color: Colors.lightBlueAccent,
                  size: 24,
                ),
                onTap: () {},
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: InkWell(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.lightGreen,
                    size: 24,
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _image(String url) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 20.0,
        minWidth: 20.0,
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

class Message {
  final String id;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final bool isSender;
  final MessageType messageType;
  final Map<String, List<String>> reactions;
  final bool isReply;
  final String replyingMessage;

  Message({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.isSender,
    required this.messageType,
    required this.reactions,
    required this.isReply,
    required this.replyingMessage,
  });

  Message copyWith({
    String? id,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
    bool? isSender,
    MessageType? messageType,
    Map<String, List<String>>? reactions,
    bool? isReply,
    String? replyingMessage,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isSender: isSender ?? this.isSender,
      messageType: messageType ?? this.messageType,
      reactions: reactions ?? this.reactions,
      isReply: isReply ?? this.isReply,
      replyingMessage: replyingMessage ?? this.replyingMessage,
    );
  }
}

enum MessageType { text, image }
