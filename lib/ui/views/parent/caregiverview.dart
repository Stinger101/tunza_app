import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/parent/caregiver_model.dart';
import 'package:tunza_app/res/strings.dart';
import 'package:tunza_app/ui/views/base_view.dart';

class CaregiverView extends StatelessWidget{
  Child child;
  CaregiverView(this.child);
  CaregiverModel model;


  



  @override

  Widget build(BuildContext context) {

    return BaseView<CaregiverModel>(
      onModelReady: (model)async{
        this.model=model;
        await model.fetchCategivers(this.child.child_id);
        _initAgoraRtcEngine();
        _addAgoraEventHandlers();

      },
      builder: (context,model,child){
        return Scaffold(
            appBar: new AppBar(title: new Text(this.child.child_name),),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.receipt),title: Text("General")),
                BottomNavigationBarItem(icon: Icon(Icons.child_friendly),title: Text("Caregivers")),
                BottomNavigationBarItem(icon: Icon(Icons.content_paste),title:Text("Posts")),
              ],
              currentIndex: 1,
              onTap: (i){
                switch(i){
                  case 0:
                    Navigator.pushReplacementNamed(context, "child",arguments: this.child);
                    break;
                  case 1:
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, "communication",arguments: this.child);
                    break;
                }
              },
            ),
            floatingActionButton: FloatingActionButton(
              child: model.isInChannel?Icon(Icons.call_end):Icon(Icons.group_add),
              onPressed: (){
                model.isInChannel?_toggleChannel("",0)
                    :Navigator.pushNamed(context, "invite_caregiver",arguments: this.child);
              },
            ),
            body:  model.state==ViewState.Busy?
            Center(
              child: CircularProgressIndicator(),
            )
                :RefreshIndicator(
              child: model.isInChannel?
                  _viewRows()
                  :ListView.builder(itemCount:model.caregiverList.length ,itemBuilder: (context,i){

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage("https://i.ya-webdesign.com/images/customer-vector-engagement-18.png")),
                      title: Text(model.caregiverList[i].email_provided),
                      subtitle: Text(model.caregiverList[i].status?"invite accepted":"invite pending"),
                      onLongPress: (){
                        //todo: allow deletion of care givers
                      },
                      onTap: (){
                        return showDialog(
                            context: context,

                            builder: (context){
                              return AlertDialog(
                                contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                titlePadding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                                title: Text(model.caregiverList[i].email_provided),

                                content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:[
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                                        child: Image.network("https://i.ya-webdesign.com/images/customer-vector-engagement-18.png"),
                                      ),
                                      Container(
                                        color: Colors.blueGrey,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            IconButton(icon: Icon(Icons.phone),
                                            onPressed: ()async{
                                              if(model.caregiverList[i].caregiver_user_id!=null) {
                                                print(model.caregiverList[i].caregiver_user_id);
                                                await model.makeCall(
                                                    "voice call url",
                                                    model.caregiverList[i].caregiver_user_id,
                                                    "voice");
                                                // todo: add navigation to call page
                                              }
                                            },
                                            ),
                                            IconButton(icon: Icon(Icons.video_call),
                                              onPressed: ()async{
                                                if(model.caregiverList[i].caregiver_user_id!=null) {
                                                  Navigator.pop(context);
                                                  String url=DateTime.now().toIso8601String();
                                                  await _toggleChannel(url,model.caregiverList[i].caregiver_user_id);
                                                  await model.makeCall(
                                                      url,
                                                      model.caregiverList[i].caregiver_user_id,
                                                      "video");

                                                }
                                              },),
                                            IconButton(icon: Icon(Icons.chat),),
                                            IconButton(icon: Icon(Icons.perm_identity),)
                                          ],
                                        ),
                                      )
                                    ]
                                ),

                              );
                            }
                        );
                      },
                    ),
                    Divider()
                  ],
                );
              }),
              onRefresh: ()async{
                await model.fetchCategivers(this.child.child_id);
              },
            ),
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
    AgoraRtcEngine.setParameters("{\"rtc.log_filter\": 65535}");

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

  Widget _viewRows() {
    return Row(
      children: <Widget>[
        for (final widget in _renderWidget)
          Expanded(
            child: Container(
              child: widget,
            ),
          )
      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {
    yield AgoraRenderWidget(0, local: true, preview: false);

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
class VideoSession {
  int uid;
  Widget view;
  int viewId;

  VideoSession(int uid, Widget view) {
    this.uid = uid;
    this.view = view;
  }
}