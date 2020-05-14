import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/enums/role.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/communication/communication_model.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:tunza_app/ui/views/parent/singlepostview.dart';

class CommunicationView extends StatelessWidget{
  Child child;
  Role role;
  CommunicationView(args){
    this.child=args[0];
    this.role=args.length>1?args[1]:Role.Parent;
  }

  @override

  Widget build(BuildContext context) {
    return BaseView<CommunicationModel>(
      onModelReady: (model)async{
        await model.fetchPosts(this.child.child_id);
      },
      builder: (context,model,child){
        return Scaffold(
          appBar: new AppBar(title: new Text("Posts - "+this.child.child_name),),
          bottomNavigationBar: BottomNavigationBar(
            items: this.role==Role.Parent?[

              BottomNavigationBarItem(icon: Icon(Icons.receipt),title: Text("General")),
              BottomNavigationBarItem(icon: Icon(Icons.child_friendly),title: Text("Caregivers")),
              BottomNavigationBarItem(icon: Icon(Icons.content_paste),title:Text("Posts")),
            ]:[

              BottomNavigationBarItem(icon: Icon(Icons.receipt),title: Text("General")),
              BottomNavigationBarItem(icon: Icon(Icons.content_paste),title:Text("Posts")),
            ],
            currentIndex: this.role==Role.Parent?2:1,
            onTap: (i){
              switch(i){
                case 0:
                  Navigator.pushReplacementNamed(context, this.role==Role.Parent?"child":"caregiver_child_view",arguments: this.child);
                  break;
                case 1:
                  this.role==Role.Parent?Navigator.pushReplacementNamed(context, "caregivers",arguments: this.child):null;
                  break;
                case 2:
                  break;
              }
            },
          ),
          body: model.state==ViewState.Busy?
          Center(
            child: CircularProgressIndicator(),
          )
          :Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                    hintText: "Whats on your mind?"
                ),
                onTap: (){
                  Navigator.pushNamed(context, "add_post",arguments: [this.child]);
                },
                readOnly: true,
              ),
              Divider(),
              Text("Recent Posts",style: TextStyle(fontSize: 14,color: Colors.blueGrey,fontWeight: FontWeight.bold),),
              Divider(),
              Expanded(
                child: RefreshIndicator(
                  child: ListView.builder(itemCount:model.postList.length,itemBuilder: (context,i){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          isThreeLine: true,
                          title: Text("${model.postList[i].editor}: ${model.postList[i].created_at}"),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${model.postList[i].topic}"),
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
                                          Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Icon(Icons.comment,size: 16,color: Colors.blueGrey,),
                                          ),
                                          Text("${model.postList[i].comment_count}")
                                        ],
                                      ),
                                      onTap: (){
                                        //todo: go to next page with child and post
                                        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => SinglePostView([this.child,model.postList[i],this.role])));
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Icon(Icons.favorite,size: 16,color: Colors.blueGrey,),
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
                  onRefresh: ()async{
                    await model.fetchPosts(this.child.child_id);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}