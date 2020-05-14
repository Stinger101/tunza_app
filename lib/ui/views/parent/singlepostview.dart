import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/role.dart';
import 'package:tunza_app/core/viewmodels/communication/singlepost_model.dart';
import 'package:tunza_app/core/models/post.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:tunza_app/ui/views/parent/addcomment_view.dart';

class SinglePostView extends StatelessWidget{
  Post post;
  Child child;
  Role role;
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