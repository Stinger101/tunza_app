import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/role.dart';
import 'dart:io';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/models/post.dart';
import 'package:tunza_app/core/viewmodels/communication/addpost_model.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:video_player/video_player.dart';

class AddPostView extends StatelessWidget{
  Child child;
  Post post;
  Role role;
  String file;
  VideoPlayerController controller;
  Future controllerInitialize;

  var _formKey=GlobalKey<FormState>();
  var _question;
  var _visibility = true;
  var _visibility_val = 1;
  bool isTextual=true;
  bool isImage=true;
  bool play=false;
  AddPostView(args){
    this.child=args[0];
    this.role=args.length>1?args[1]:Role.Parent;
    this.post=args.length>2?args[2]:null;

  }
  @override
  Widget build(BuildContext context) {
    controller=file!=null&&!isImage?VideoPlayerController.file(File(file)):null;
    // TODO: implement build
    return BaseView<AddPostModel>(
      dispose: dispose,
      builder: (context,model,child){
        return Scaffold(
          appBar: AppBar(
            title: Text(this.post!=null?"Add a post-":"Edit post"+this.child.child_name),
          ),
          body: Container(
            padding: EdgeInsets.fromLTRB(4, 6, 4, 4),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(icon: Icon(Icons.receipt,color: isTextual?Colors.blueGrey:null),onPressed: (){
                          isTextual=true;
                          model.setState(ViewState.Idle);
                        },),
                        IconButton(icon: Icon(Icons.burst_mode,color: isTextual?null:Colors.blueGrey),onPressed: (){
                          isTextual=false;
                          model.setState(ViewState.Idle);
                        },),
                      ],
                    ),
                    isTextual?TextFormField(
                      initialValue: this.post!=null?post.topic:_question,
                      minLines: 4,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (val){
                        _question=val;
                      },
                      decoration: InputDecoration(
//                        prefixIcon: Icon(Icons.receipt),
                        labelText: 'Post',
                        hintText: "Got a question? a comment perhaps? something you want to share?",
                        alignLabelWithHint: true,

                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (val){
                        _question=val;
                      },
                    ):Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        file!=null?(
                            isImage?
                            Image.file(File(file),height: MediaQuery.of(context).size.height*0.2,):
                            FutureBuilder(
                              future: controllerInitialize,
                              builder: (context,snapshot){
                                if(snapshot.connectionState==ConnectionState.done){
                                  return Container(
                                    height: MediaQuery.of(context).size.height*0.2,
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
                                            child: !controller.value.isPlaying?FloatingActionButton(
                                              onPressed: () {

                                                controller.play();

                                                model.setState(ViewState.Idle);

                                              },

                                              child: Icon(
                                                Icons.play_arrow,
                                              ),
                                              mini: true,
                                              backgroundColor: Colors.transparent,
                                            ):FloatingActionButton(

                                              onPressed: () {

                                                controller.pause();

                                                model.setState(ViewState.Idle);

                                              },
                                              child: Icon(
                                                Icons.pause,
                                              ),
                                              mini: true,
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: Colors.transparent,

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
                            )):
                        Row(
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height*0.2,
                              width: MediaQuery.of(context).size.width - 8,
                              child: Card(
                                color: Colors.transparent,
                                child: Center(
                                  child: Text("No preview"),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width:MediaQuery.of(context).size.width/2 -4,
                              child: GestureDetector(
                                child: Card(
                                  child: Icon(Icons.image),
                                ),
                                onTap: ()async{
                                  isImage=true;
                                  file=await FilePicker.getFilePath(type: FileType.image);
                                  model.setState(ViewState.Idle);
                                },
                              ),
                            ),
                            Container(
                              width:MediaQuery.of(context).size.width/2 -4,
                              child: GestureDetector(
                                child: Card(
                                  child: Icon(Icons.video_library),
                                ),
                                onTap: ()async{
                                  isImage=false;
                                  file=await FilePicker.getFilePath(type: FileType.video);
                                  if(controller!=null){
                                    controller.dispose();
                                    controller=null;
                                  }
                                  controller=file!=null&&!isImage?VideoPlayerController.file(File(file)):null;
                                  controllerInitialize=controller.initialize();
                                  model.setState(ViewState.Idle);
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    MaterialButton(
                      child: Text ('Post'),
                      color: Colors.blueGrey,
                      onPressed: ()async{
                        if(_formKey.currentState.validate()){
                          model.setState(ViewState.Busy);
                          _formKey.currentState.save();
                          var success = this.post!=null ? await model.editPost(this.post.id,this.child.child_id, _question)
                              :await model.addPost(this.child.child_id, _question,attachment:file!=null?file:null,attachment_type:file!=null?isImage?"image":"video":null);//todo: use model to post
                          model.setState(ViewState.Idle);
                          if(success){
                            Navigator.of(context).pop();
                            Navigator.pushReplacementNamed(context, "communication",arguments:[this.child,this.role]);
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  dispose(){
    if(controller!=null){
      controller.dispose();
      controller=null;
    }
  }
}