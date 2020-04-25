import 'package:chat_app/models/user_model.dart';

import 'package:adhara_socket_io/adhara_socket_io.dart';

class RouteArguments{
  final UserModel userModel;
  final SocketIO socketIO;

  RouteArguments(this.userModel, this.socketIO);
}