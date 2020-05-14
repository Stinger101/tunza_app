import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/call.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/parent/caregiver_model.dart';
import 'package:tunza_app/res/strings.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:tunza_app/ui/views/parent/caregiverview.dart';

class VideoCallView extends StatelessWidget{

  String call_url;
  String receiver_id;
  VideoCallView(String arg){
    this.call_url=arg.split("!")[0];
    this.receiver_id=arg.split("!")[1];
  }
  CaregiverModel model;


  



  @override

  Widget build(BuildContext context) {

    return BaseView<CaregiverModel>(
      onModelReady: (model)async{
        this.model=model;
        _initAgoraRtcEngine();
        _addAgoraEventHandlers();
        _toggleChannel(call_url, receiver_id);

      },
      builder: (context,model,child){
        return Scaffold(
            appBar: new AppBar(title: new Text("Video call"),),
            body:  model.isInChannel?
            _viewRows(context):null,
        );
      },
      dispose: dispose,
    );
  }

  void dispose() {
    // clear users
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();

  }

  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(StringConstants.agora_app_id);

    AgoraRtcEngine.enableVideo();
    AgoraRtcEngine.enableAudio();
     AgoraRtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);
//    AgoraRtcEngine.setParameters("{\"rtc.log_filter\": 65535}");

    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    AgoraRtcEngine.setVideoEncoderConfiguration(config);
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      model.setState(ViewState.Idle);
        String info = 'onJoinChannel: ' + channel + ', uid: ' + uid.toString();
        model.infoStrings.add(info);
      model.setState(ViewState.Idle);
    };

    AgoraRtcEngine.onLeaveChannel = () {
      model.setState(ViewState.Idle);
        model.infoStrings.add('onLeaveChannel');
        model.remoteUsers.clear();
      model.setState(ViewState.Idle);
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      model.setState(ViewState.Idle);
        String info = 'userJoined: ' + uid.toString();
        model.infoStrings.add(info);
        model.remoteUsers.add(uid);
      model.setState(ViewState.Idle);
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      model.setState(ViewState.Idle);
        String info = 'userOffline: ' + uid.toString();
        model.infoStrings.add(info);
        model.remoteUsers.remove(uid);
      model.setState(ViewState.Idle);
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame =
        (int uid, int width, int height, int elapsed) {
      model.setState(ViewState.Idle);
        String info = 'firstRemoteVideo: ' +
            uid.toString() +
            ' ' +
            width.toString() +
            'x' +
            height.toString();
        model.infoStrings.add(info);
      model.setState(ViewState.Idle);
    };
  }

  void _toggleChannel(url,receiver_id)async {
    model.setState(ViewState.Idle);
      if (model.isInChannel) {
        model.isInChannel = false;
        await AgoraRtcEngine.leaveChannel();
        await AgoraRtcEngine.stopPreview();
      } else {
        model.isInChannel = true;
        await AgoraRtcEngine.startPreview();
        await AgoraRtcEngine.joinChannel(null, url+'_call_'+receiver_id.toString(), null, 0);
      }
    model.setState(ViewState.Idle);
  }

  Widget _viewRows(context) {
    return Stack(
      children: <Widget>[
        for (final widget in _renderWidget)
          Expanded(
            child: Container(
              child: widget,
            ),
          ),
        _renderWidget.length<1?AgoraRenderWidget(0, local: true, preview: true)
        :Positioned(
          right: 24.0,
          bottom: 24.0,
          child:Container(
              height: MediaQuery.of(context).size.height*0.2,
              width: MediaQuery.of(context).size.width*0.2,
              child:AgoraRenderWidget(0, local: true, preview: true)
          ),
        ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: model.isInChannel?FloatingActionButton(
              child: Icon(Icons.call_end),
              onPressed: (){
                  _toggleChannel("",0);
                  Navigator.pushNamed(context, "login");
              },
            ):null,
          ),
        ),

      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {


    for (final uid in model.remoteUsers) {
      yield AgoraRenderWidget(uid);
    }
  }

  VideoSession _getVideoSession(int uid) {
    return model.sessions.firstWhere((session) {
      return session.uid == uid;
    });
  }

  List<Widget> _getRenderViews() {
    return model.sessions.map((session) => session.view).toList();
  }

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

  Widget _buildInfoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemExtent: 24,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(model.infoStrings[i]),
        );
      },
      itemCount: model.infoStrings.length,
    );
  }

}
