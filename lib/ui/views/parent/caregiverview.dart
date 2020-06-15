import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/caregiver.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/parent/caregiver_model.dart';
import 'package:tunza_app/res/strings.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:tunza_app/ui/views/communication/call.dart';
import 'package:tunza_app/ui/views/parent/videocall_view.dart';

class CaregiverView extends StatelessWidget{
  Child child;
  CaregiverView(this.child);
  CaregiverModel model;
  Caregiver currentCaregiver;


  



  @override

  Widget build(BuildContext context) {

    return BaseView<CaregiverModel>(
      onModelReady: (model)async{
        this.model=model;
        await model.fetchCategivers(this.child.child_id);
      },
      builder: (context,model,child){
        return Scaffold(
            appBar: new AppBar(title: new Text(this.child.child_name),),
            bottomNavigationBar: !model.isInChannel?BottomNavigationBar(
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
                    Navigator.pushReplacementNamed(context, "communication",arguments: [this.child]);
                    break;
                }
              },
            ):null,
            floatingActionButton: !model.isInChannel?FloatingActionButton(
              child: model.isInChannel?Icon(Icons.call_end):Icon(Icons.group_add),
              onPressed: (){
                Navigator.pushNamed(context, "invite_caregiver",arguments: this.child);
              },
            ):null,
            body:  model.state==ViewState.Busy?
            Center(
              child: CircularProgressIndicator(),
            )
                :RefreshIndicator(
              child: model.isInChannel?
                  _viewRows(context,this.currentCaregiver)
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
                                                String url=DateTime.now().toIso8601String();
                                                if(await Permission.camera.isGranted && await Permission.camera.isGranted){
                                                  await model.makeCall(
                                                      url,
                                                      model.caregiverList[i].caregiver_user_id,
                                                      "voice");
                                                  // todo: add navigation to call page
                                                  Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => VoiceCallPage(url+"!"+model.caregiverList[i].caregiver_user_id.toString()+"!"+"voice"+"!"+model.caregiverList[i].email_provided)));
                                                }else{
                                                  await [Permission.camera,Permission.microphone].request();

                                                }

                                              }
                                            },
                                            ),
                                            IconButton(icon: Icon(Icons.video_call),
                                              onPressed: ()async{
                                                if(model.caregiverList[i].caregiver_user_id!=null) {

                                                  String url=DateTime.now().toIso8601String();
                                                  this.currentCaregiver=model.caregiverList[i];
                                                  if(await Permission.camera.isGranted && await Permission.camera.isGranted){
                                                    await model.makeCall(
                                                        url,
                                                        model.caregiverList[i].caregiver_user_id,
                                                        "video");
                                                    Navigator.pop(context);
                                                    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => VideoCallView(url+"!"+model.caregiverList[i].caregiver_user_id.toString())));
                                                  }else{
                                                    await [Permission.camera,Permission.microphone].request();

                                                  }
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


  }



  Widget _viewRows(context,Caregiver caregiver) {
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
            child: FloatingActionButton(
              child: model.isInChannel?Icon(Icons.call_end):Icon(Icons.group_add),
              onPressed: (){

                Navigator.pop(context);
                this.currentCaregiver=null;
              },
            ),
          ),
        ),_renderWidget.length<1?Align(
          alignment: FractionalOffset.topCenter,
            child:Card(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(caregiver.email_provided,style: TextStyle(fontSize: 20),),
                    ],
                  ),
                  Text("Calling")
                ],
              ),
            )
        ):null

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
class VideoSession {
  int uid;
  Widget view;
  int viewId;

  VideoSession(int uid, Widget view) {
    this.uid = uid;
    this.view = view;
  }
}