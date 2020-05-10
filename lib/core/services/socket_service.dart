import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pusher_websocket_flutter/pusher.dart';
import 'package:tunza_app/core/models/call.dart';

import 'package:tunza_app/core/models/profile.dart';
import 'package:tunza_app/core/services/api.dart';
import 'package:tunza_app/core/services/authentication_service.dart';
import 'package:tunza_app/core/services/notification_service.dart';
import 'package:tunza_app/locator.dart';
import 'package:tunza_app/res/strings.dart';

class SocketService{
  AuthenticationService _authenticationService=locator<AuthenticationService>();
  NotificationService _notificationService=locator<NotificationService>();
  Profile profile;
  Api _api=locator<Api>();
//  Event lastEvent;
  StreamController<Call> callController=StreamController<Call>();
  Channel userChannel;
  Channel callChannel;


  SocketService(){


  }
  initPusher()async{
    try {
      await Pusher.init(
          StringConstants.pusher_app_key,
          PusherOptions(
            cluster: "eu",
            auth:PusherAuth(
              "${StringConstants.api_url}/broadcast/auth",
                headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"
                }
            ),
            encrypted: false,
            port: 80
          ),
          enableLogging: true);
      return true;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
  connectToPusher(){
    Pusher.connect(onConnectionStateChange: (x) async {
      print(x.currentState);
         return x.currentState;

      }, onError: (x) {
        print("Errors: ${x.toJson()}");
    });
  }
  disconnectFromPusher(){
    Pusher.disconnect();
  }
  subscribeToUserChannel()async{
    profile=await _api.getUserProfile();
    userChannel= await Pusher.subscribe('private-user.'+profile.id.toString());
    return true;
  }
  unsubscribeFromUserChannel()async{
    await Pusher.unsubscribe('user.'+profile.id.toString());
    return true;
  }
  bindCallMade()async{
    await userChannel.bind("App\\Events\\CallMade", (x){
      var call=json.decode(x.data)["call"];
      callController.add(Call.fromJson(call));
      print(call);
      Call rec_call=Call.fromJson(call);
      _notificationService.showNotification(call["id"], call['call_type'], call['call_type'],rec_call.call_url+"!"+rec_call.receiver_id );
    });
  }

  unbindCallMade()async{
    await userChannel.unbind("CallMade");
  }

}