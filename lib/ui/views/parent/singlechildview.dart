import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/parent/singlechildmodel.dart';
import 'package:tunza_app/ui/views/base_view.dart';

class SingleChildView extends StatelessWidget {
  Child child;
  SingleChildView(this.child);
  @override
  Widget build(BuildContext context) {
    return BaseView<SingleChildModel>(
      onModelReady: (model)async{
        await model.fetchChildInfo(this.child.child_id);
      },
        builder: (context, model, child) {
          return Scaffold(
            appBar: new AppBar(title: new Text(this.child.child_name),),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.receipt),title: Text("General")),
                BottomNavigationBarItem(icon: Icon(Icons.child_friendly),title: Text("Caregivers")),
                BottomNavigationBarItem(icon: Icon(Icons.content_paste),title:Text("Posts")),
              ],
              currentIndex: 0,
              onTap: (i){
                switch(i){
                  case 0:
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, "caregivers",arguments: this.child);
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, "communication",arguments: [this.child]);
                    break;
                }
              },
            ),
            body:  model.state==ViewState.Busy?
          Center(
          child: CircularProgressIndicator(),
          )
              :RefreshIndicator(
          child: ListView.builder(
              itemCount: model.infoList.length,
              itemBuilder: (context,i){
                return Card(
                  child: ListTile(
                    title: Text("${model.infoList[i].topic.toUpperCase()}"),
                    subtitle: Text("${model.infoList[i].content.split('\n').map((s)=>"- $s").join('\n')}"),
                    trailing: model.state==ViewState.Edit?Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(

                          child: Icon(Icons.edit,size: 16,color: Colors.green,),
                          onTap: (){
                            Navigator.pushNamed(context, "edit_child_info",arguments: [this.child,model.infoList[i]]);
                          },
                        ),
                        GestureDetector(
                          child: Icon(Icons.delete_forever,size: 16,color: Colors.red,),
                          onTap: (){
                            model.setState(ViewState.Delete);
                            showDialog(context: context,
                            builder: (context){
                              return AlertDialog(
                                title: Text("Delete Confirmation"),
                                content: Text("You are about to delete your child's information. This action is not reversible."),
                                actions: <Widget>[

                                  FlatButton(child: Text("Cancel"),
                                  onPressed: (){
                                    model.setState(ViewState.Edit);
                                    Navigator.pop(context);
                                  },
                                    color: Colors.blueGrey[50],
                                  ),
                                  FlatButton(
                                    child: Text("Delete"),
                                    onPressed: ()async{
                                      Navigator.pop(context);
                                      await model.deleteChildinfo(model.infoList[i].id, this.child.child_id);
                                    },color: Colors.red,
                                  ),

                                ],

                              );
                            });
                          },

                        )
                      ],
                    ):null,
                    onLongPress: (){
                      model.state!=ViewState.Edit?model.setState(ViewState.Edit):model.setState(ViewState.Idle);
                    },
                  ),
                );
              }
          ),
          onRefresh: ()async{
          await model.fetchChildInfo(this.child.child_id);
          },
          ),
            floatingActionButton: model.state==ViewState.Idle?FloatingActionButton.extended(
              icon: Icon(Icons.receipt),
              label: Text("add"),
              tooltip: "add info",
              onPressed: (){
                Navigator.pushNamed(context, "add_child_info",arguments: [this.child]);
              },
            ):null,

          );
        }
    );
  }
}