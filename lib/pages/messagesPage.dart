import 'dart:math';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/route_arguments.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({Key key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  TextEditingController _textEditingController = TextEditingController();
  bool flag = false;
  List<MessageModel> messagesList = List<MessageModel>();
  @override
  void initState() {
    super.initState();
  }

  void addSocketListener(
    RouteArguments arguments,
  ) {
    if (!flag) {
      print("Configurando socket");
      arguments.socketIO.emit('getMessages', [
        {'fromUserId': '2', 'toUserId': '${arguments.userModel.id}'}
      ]);
      arguments.socketIO.on('getMessagesResponse', (data) {
        final List<MessageModel> messages = (data['result'] as List)
            .map((messageData) => MessageModel.fromJson(messageData))
            .toList();
        setState(() {
          messagesList = messages.reversed.toList();
        });
      });
      arguments.socketIO.on('addMessageResponse', (data) {
        print("MENSAJE RECIBIDO");
        setState(() {
          messagesList.insert(0, MessageModel.fromJson(data));
        });
      });
    }
    flag = true;
  }

  @override
  Widget build(BuildContext context) {
    RouteArguments arguments = ModalRoute.of(context).settings.arguments;
    final model = arguments.userModel;

    addSocketListener(arguments);
    return WillPopScope(
      onWillPop: () {
        arguments.socketIO.off('getMessagesResponse');
        arguments.socketIO.off('addMessageResponse');
        print("Unsiscribe getMEssagesResponse");
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: ColorTheme.backgroundGrey,
        appBar: AppBar(
          backgroundColor: ColorTheme.backgroundGrey,
          elevation: 0,
          title: Text(
            model.name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_horiz),
              iconSize: 30,
              color: Colors.white,
              onPressed: () {},
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.only(top: 15),
                      itemCount: messagesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        MessageModel message = messagesList[index];
                        final bool isMe = message.fromUserId == 2;
                        return _buildMessage(message, isMe);
                      },
                    ),
                  ),
                ),
              ),
              _buildMessageInput(arguments)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(RouteArguments arguments) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.grey[700],
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25,
            color: ColorTheme.backgroundGrey,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              maxLines: 1,
              controller: _textEditingController,
              cursorColor: ColorTheme.greyAccent,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  InputDecoration.collapsed(hintText: 'Type something...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: ColorTheme.backgroundGrey,
            onPressed: () {
              String msg = _textEditingController.value.text;
              if (msg.isNotEmpty) {
                setState(() {
                  arguments.socketIO.emit('addMessage', [
                    {
                      "fromUserId": 2,
                      "toUserId": arguments.userModel.id,
                      "toSocketId": "${arguments.userModel.socketId}",
                      "message": msg,
                      "time": "asd",
                      "date": "as",
                    }
                  ]);
                  messagesList.insert(
                      0,
                      MessageModel(
                          date: DateTime.now(),
                          fromUserId: 2,
                          toUserId: 1,
                          message: msg,
                          time: '10:10 AM'));
                  _textEditingController.text = "";
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(MessageModel message, bool isMe) {
    bool isShowDate = false;
    return InkWell(
      onTap: () {
        isShowDate = !isShowDate;
        print(isShowDate);
      },
      child: Container(
        margin: isMe
            ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: 80)
            : EdgeInsets.only(top: 8.0, bottom: 8.0, right: 80),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: isMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
              : BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
          color: isMe ? ColorTheme.greyAccent : ColorTheme.blueContainer,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${message.time}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text("${message.message}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            isShowDate
                ? Text("${message.date.toIso8601String().substring(0, 10)}")
                : Container()
          ],
        ),
      ),
    );
  }
}
