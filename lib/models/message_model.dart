// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
    int id;
    int fromUserId;
    int toUserId;
    String message;
    DateTime date;
    String time;

    MessageModel({
        this.id,
        this.fromUserId,
        this.toUserId,
        this.message,
        this.date,
        this.time,
    });

    factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["id"],
        fromUserId: json["from_user_id"],
        toUserId: json["to_user_id"],
        message: json["message"],
        date: DateTime.parse(json["date"]),
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "from_user_id": fromUserId,
        "to_user_id": toUserId,
        "message": message,
        "date": date.toIso8601String(),
        "time": time,
    };
}
