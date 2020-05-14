import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/enums/role.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/parent/singlechildmodel.dart';
import 'package:tunza_app/ui/views/base_view.dart';

class CaregiverSingleChildView extends StatelessWidget {
  Child child;
  CaregiverSingleChildView(this.child);
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
//                BottomNavigationBarItem(icon: Icon(Icons.child_friendly),title: Text("Caregivers")),
                BottomNavigationBarItem(icon: Icon(Icons.call),title:Text("Communication")),
              ],
              currentIndex: 0,
              onTap: (i){
                switch(i){
                  case 0:
                    break;
//                  case 1:
//                    Navigator.pushReplacementNamed(context, "caregivers",arguments: this.child);
//                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, "communication",arguments: [this.child,Role.Caregiver]);
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
                    onLongPress: (){
                      //no edit functionality
                    },
                  ),
                );
              }
          ),
          onRefresh: ()async{
          await model.fetchChildInfo(this.child.child_id);
          },
          ),

          );
        }
    );
  }
}