import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/res/strings.dart';

class VoiceCallPage extends StatefulWidget {
   String call_url;
   int receiver_id;
   String receiver_name;
   String mode;//receiving or calling
   int call_status=1;//call waiting,call ongoing, call ended

  VoiceCallPage(arg){
    var ls=arg.split("!");
    this.call_url=ls[0];
    this.receiver_id=int.parse(ls[1]);
    this.mode=ls[2];
    this.receiver_name=ls[3];
  }
  @override
  _VoiceCallPageState createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {

  Timer _timerInstance;
  int _start = 0;
  String _timer = '';
  final infoStrings=<String>[];
  final remoteUsers = <int>[];
  bool isInChannel = false;
  bool onSpeaker=false;

  void startTimer(){
    var onSec = Duration(seconds: 1);
    _timerInstance = Timer.periodic(onSec, (Timer timer) => setState(() {
      if (_start < 0){
        _timerInstance.cancel();
      }else{
        _start = _start + 1;
        _timer = getTimerTime(_start);
      }
    }));
  }

  String getTimerTime(int start){
    int minutes= (start~/60);
    String sMinute = '';
    if(minutes.toString().length ==1){
      sMinute = '0'+ minutes.toString();
    }else sMinute = minutes.toString();

    int seconds= (start % 60);
    String sSeconds = '';
    if(minutes.toString().length ==1){
      sSeconds = seconds.toString();
    }else sMinute = seconds.toString();

    return sMinute + ':' + sSeconds;
  }
  @override

  void initState(){
    super.initState();
    _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    _toggleChannel(widget.call_url, widget.receiver_id);
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var clipRRect = ClipRRect(
      borderRadius: BorderRadius.circular(200.0),
      child: Image.network(
        StringConstants.missing_avatar_url,
        height: 100,
        width: 100,
      ),
    );
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        padding: EdgeInsets.all(46.0),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 15.0,),
            Text(widget.receiver_name,
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w900,
                  fontSize: 25),
            ),
            SizedBox(height: 15.0,),
            Text(
              widget.call_status==1?'Calling...':widget.call_status==2?"Connected":"Call ended",
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w300,
                  fontSize: 14),
            ),
            SizedBox(height:20.0,),
            Text(
              _timer,
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w300,
                  fontSize: 10),
            ),
            SizedBox(height:20.0,),
            clipRRect,
            SizedBox(height: 60.0,),
            Row(
              mainAxisSize:MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FunctionalButton(title: 'speaker', icon: Icons.phone_in_talk, onPressed: (){
                  AgoraRtcEngine.setEnableSpeakerphone(!onSpeaker);
                },),
                FunctionalButton(title: 'video call', icon: Icons.videocam, onPressed: (){},),
                FunctionalButton(title: 'mute', icon: Icons.mic_off, onPressed: (){},),
              ],
            ),
            SizedBox(
              height:50.0,
            ),
            FloatingActionButton(
              onPressed: ()async{
                await _toggleChannel("",0);
                widget.call_status=3;
                Navigator.pop(context);

              },
              elevation:20.0,
              shape: CircleBorder(side: BorderSide(color:Colors.red)),
              mini:false,
              child: remoteUsers.length>0?Icon(Icons.call_end, color: Colors.red,):Icon(Icons.call_end, color: Colors.green,),
              backgroundColor: Colors.red[100],
            )
          ],
        ),
      ),
    );

  }
  void dispose() {
    // clear users
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    _timerInstance.cancel();
    AgoraRtcEngine.destroy();
    super.dispose();

  }

  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(StringConstants.agora_app_id);
    AgoraRtcEngine.enableAudio();
    AgoraRtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);
//    AgoraRtcEngine.setParameters("{\"rtc.log_filter\": 65535}");

  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      setState(() {
        String info = 'onJoinChannel: ' + channel + ', uid: ' + uid.toString();
        infoStrings.add(info);

      });


    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        infoStrings.add('onLeaveChannel');
        remoteUsers.clear();
        widget.call_status=3;
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {

      setState(() {
        String info = 'userJoined: ' + uid.toString();
        infoStrings.add(info);
        remoteUsers.add(uid);
        _start=0;
        _timer='';
        widget.call_status=2;
      });

    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {

      setState(() {
        String info = 'userOffline: ' + uid.toString();
        infoStrings.add(info);
        remoteUsers.remove(uid);
        AgoraRtcEngine.leaveChannel();
        _timerInstance.cancel();
        widget.call_status=3;
        AgoraRtcEngine.destroy();
        Navigator.pop(context);
      });
    };
  }

  void _toggleChannel(url,receiver_id)async {

      if (isInChannel) {

        await AgoraRtcEngine.leaveChannel();
        _timerInstance.cancel();
        setState(() {
          isInChannel = false;
        });

      } else {

        await AgoraRtcEngine.joinChannel(null, url+'_call_'+receiver_id.toString(), null, 0);
        setState(() {
          isInChannel = true;
        });
      }


  }





}

class FunctionalButton extends StatefulWidget {
  final title;
  final icon;
  final Function() onPressed;

  const FunctionalButton({Key key, this.title, this.icon, this.onPressed}) : super(key: key);

  @override
  _FunctionalButtonState createState() => _FunctionalButtonState();
}

class _FunctionalButtonState extends State<FunctionalButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RawMaterialButton(
          onPressed: widget.onPressed,
          splashColor: Colors.blueGrey,
          fillColor: Colors.white,
          elevation: 10.0,
          shape: CircleBorder(),
          child: Icon(
              widget.icon,
              size: 30.0,
              color:Colors.blueGrey),
        ),
        Container(
            margin: EdgeInsets.symmetric(vertical:10.0, horizontal:2.0),
            child: Text(widget.title, style: TextStyle(fontSize: 11.0, color: Colors.blueGrey,))
        )
      ],

    );


  }
}