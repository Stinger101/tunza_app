import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/models/post.dart';
import 'package:tunza_app/core/viewmodels/communication/addpost_model.dart';
import 'package:tunza_app/ui/views/base_view.dart';

class AddPostView extends StatelessWidget{
  Child child;
  Post post;

  var _formKey=GlobalKey<FormState>();
  var _question;
  var _visibility = true;
  var _visibility_val = 1;
  bool isTextual=true;
  AddPostView(args){
    this.child=args[0];
    this.post=args.length>1?args[1]:null;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseView<AddPostModel>(
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
                    TextFormField(
                      initialValue: this.post!=null?post.topic:null,
                      minLines: 4,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
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
                    ),
                    MaterialButton(
                      child: Text ('Post'),
                      color: Colors.blueGrey,
                      onPressed: ()async{
                        if(_formKey.currentState.validate()){
                          _formKey.currentState.save();
                          var success = this.post!=null ? await model.editPost(this.post.id,this.child.child_id, _question)
                              :await model.addPost(this.child.child_id, _question);//todo: use model to post
                          if(success){
                            Navigator.of(context).pop();
                            Navigator.pushReplacementNamed(context, "communication",arguments:this.child);
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