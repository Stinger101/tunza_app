import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/role.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/models/post.dart';
import 'package:tunza_app/core/models/comment.dart';
import 'package:tunza_app/core/viewmodels/communication/addcomment_model.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:tunza_app/ui/views/parent/singlepostview.dart';

class AddCommentView extends StatelessWidget{
  Child child;
  Post post;
  Comment comment;
  Role role;
  var _formKey=GlobalKey<FormState>();
  var _question;
  var _visibility = true;
  var _visibility_val = 1;
  AddCommentView(args){
    this.child=args[0];
    this.post=args[1];
    this.comment=args.length>2?args[2]:null;
    this.role=args.length>3?args[3]:Role.Parent;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseView<AddCommentModel>(
      builder: (context,model,child){
        return Scaffold(
          appBar: AppBar(
            title: Text(this.comment==null?"Add a comment-":"Edit comment-"+this.child.child_name),
          ),
          body: Container(
            padding: EdgeInsets.fromLTRB(4, 6, 4, 4),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      isThreeLine: true,
                      title:Text("${this.post.editor}: ${this.post.created_at}"),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(this.post.topic),
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
                    TextFormField(
                      initialValue: this.comment!=null?comment.comment:null,
                      minLines: 4,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
//                        prefixIcon: Icon(Icons.receipt),
                        labelText: 'Comment',
                        hintText: "a comment perhaps? something you want to share?",
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
                    ),
                    MaterialButton(
                      child: Text ('Post'),
                      color: Colors.blueGrey,
                      onPressed: ()async{
                        if(_formKey.currentState.validate()){
                          _formKey.currentState.save();
                          print(this.comment);
                          var success = this.comment!=null ? await model.editComment(this.comment.id,this.post.id,this.child.child_id, _question)
                              :await model.addComment(this.post.id,this.child.child_id, _question);//todo: use model to post
                          if(success){
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => SinglePostView([this.child,this.post,this.role])));
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
}