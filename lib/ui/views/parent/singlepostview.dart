import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/role.dart';
import 'package:tunza_app/core/viewmodels/communication/singlepost_model.dart';
import 'package:tunza_app/core/models/post.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/res/strings.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:tunza_app/ui/views/parent/addcomment_view.dart';
import 'package:video_player/video_player.dart';

class SinglePostView extends StatelessWidget{
  Post post;
  Child child;
  Role role;
  VideoPlayerController controller;
  Future controllerInitialize;

  SinglePostView(args){
    this.child=args[0];
    this.post=args[1];
    this.role=args.length>2?args[2]:Role.Parent;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseView<SinglePostModel>(
      onModelReady: (model)async{
        controller=post.attachment_url!=null&&post.attachment_type=="video"?VideoPlayerController.network(StringConstants.url+post.attachment_url+"?api_token=${model.currentUser.user_token}"):null;
        controllerInitialize=post.attachment_type=="video"?controller.initialize():null;
        await model.fetchComments(this.post.id, this.child.child_id);
      },
      builder:(context,model,child){
        return Scaffold(
          appBar: AppBar(
            title: Text("Comments"),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                isThreeLine: true,
                title:Text("${post.editor}: ${post.created_at}"),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(post.topic),
                    post.attachment_url!=null?(
                        post.attachment_type=="image"?
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.network(StringConstants.url+post.attachment_url,height: MediaQuery.of(context).size.height*0.2,headers: {"Authorization":"Bearer ${model.currentUser.user_token}"})
                          ],
                        ):
                        FutureBuilder(
                          future: controllerInitialize,
                          builder: (context,snapshot){
                            if(snapshot.connectionState==ConnectionState.done){
                              return Container(
                                height: MediaQuery.of(context).size.height*0.4,
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      child: AspectRatio(
                                        aspectRatio: controller.value.aspectRatio,
                                        child: VideoPlayer(controller),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                    Container(

                                      alignment:FractionalOffset.center,
                                      child: Center(
                                        child: FloatingActionButton(
                                          onPressed: () {
                                            controller.value.duration==controller.value.position?controller.seekTo(Duration(seconds: 0)):null;
                                            !controller.value.isPlaying?controller.play():controller.pause();

//                                                model.setState(ViewState.Idle);

                                          },

                                          child: Icon(
                                            Icons.play_arrow,
                                          ),
                                          mini: true,
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.transparent,
                                          heroTag:post.id.toString(),
                                        ),
                                      ),
                                      height: MediaQuery.of(context).size.height*0.2,

                                    )
                                  ],
                                ),
                              );
                            }
                            else{
                              return Center(child: CircularProgressIndicator(),);
                            }
                          },
                        ))
                        : Container(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.only(right: 18,top: 8),
                          child: GestureDetector(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Reply",style: TextStyle(fontWeight: FontWeight.bold),),
                                Icon(Icons.reply,size: 16,color: Colors.blueGrey,)
                              ],
                            ),
                            onTap: (){

                              //todo: go to next page with child and post
                              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => AddCommentView([this.child,this.post,null,this.role])));
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(Icons.favorite_border,size: 16,color: Colors.blueGrey,),
                        ),

                      ],
                    )
                  ],
                ),
              ),
              Divider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8,right: 8, left: 12),
                    child: Text("${post.comment_count} comments"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8,right: 4),
                    child: Icon(Icons.favorite,size: 16,color: Colors.blueGrey,),
                  ),
//                  Padding(
//                    padding: EdgeInsets.only(top: 8,right: 8),
//                    child: Text("4"),
//                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(itemCount:model.commentList.length,itemBuilder: (context,i){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(
                          child: Text("${model.commentList[i].editor.substring(0,1).toUpperCase()}"),
                        ),
                        title: Text("${model.commentList[i].editor} : ${model.commentList[i].created_at}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text("${model.commentList[i].comment}"),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 8,right: 4),
                                  child: Icon(Icons.thumb_up,size: 16,color: Colors.blueGrey,),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8,right: 8),
                                  child: Text("2"),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8,right: 8),
                                  child: Icon(Icons.thumb_down,size: 16,color: Colors.blueGrey,),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text("Reply",style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider()
                    ],
                  );
                }),
              )
            ],
          ),
        );
      }
    );
  }
}