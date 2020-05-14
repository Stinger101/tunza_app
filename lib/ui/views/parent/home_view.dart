import 'package:flutter/material.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/parent/home_model.dart';
import 'package:tunza_app/ui/views/base_view.dart';
import 'package:tunza_app/ui/views/parent/communicationview.dart';


class HomeView extends StatefulWidget{

  createState() => new _HomeViewState();

}

class _HomeViewState extends State<HomeView>{
  HomeModel myModel;
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeModel>(
      onModelReady: (model)async {
        myModel=model;
        await model.fetchChildren();
        model.socketService.callController.stream.listen((call){
          setState(() {
            model.current_call=call;
          });
        });

      },
      builder: (context,model,child){
        return Scaffold(

          appBar: AppBar(title: Text('TunzaApp Home'),


            actions: <Widget>[

//              IconButton(icon: Icon(Icons.perm_identity), onPressed: (){
//                Navigator.pushNamed(context ,"profile");
//              }),

              IconButton(icon: Icon(Icons.search), onPressed: (){
                showSearch(context: context, delegate: AppSearch(model.childList));
              })
              

            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text("Test"),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit:BoxFit.cover,
                          image: NetworkImage("https://www.unicef.org/jordan/sites/unicef.org.jordan/files/styles/hero_desktop/public/20181129_JOR_445.jpg?itok=759I5CEx")
                      )
                  ),
                  accountEmail: Text("Profile"),
                  currentAccountPicture: CircleAvatar(
                    child: Text("P",style: TextStyle(fontSize: 28),),

                  ),
                  otherAccountsPictures: model.currentUser.user_role==2|| model.currentUser.user_role==3? [
                    CircleAvatar(
                      child: FlatButton(
                        child: Text("C",style: TextStyle(color: Colors.white),),
                        onPressed: (){
                          Navigator.pushReplacementNamed(context, "caregiver_home");
                        },
                      ),
                    )
                  ]:null,
                ),
                ListTile(
                    title: Text('Children'),
                    trailing: Icon(Icons.child_care),
                    onTap: (){
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context ,"/");
                    }
                ),

                Divider(),
                ListTile(
                  title: Text('Manage Categories'),
                  trailing: Icon(Icons.list),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "categories");
                    }
                ),
                Divider(),
                ListTile(
                    title: Text('Logout'),
                    trailing: Icon(Icons.lock_open),
                    onTap: ()async{
                      var success= await model.logout();
                      if (success) {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, "login");
                      }
                    }
                ),

              ],
            ),
          ),
          body: model.state==ViewState.Busy?
          Center(
            child: CircularProgressIndicator(),
          )
          :RefreshIndicator(
            child: model.childList.length>0?
            ListView.builder(itemCount:model.childList.length ,itemBuilder: (context,i){

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQOL0wCKxBI3i8-S8OnckAeaszWpVHziXKSnzBRNuABcKZw66M-&usqp=CAU"),
                  ),
                  title: Text(model.childList[i].child_name),
                  subtitle: Text(model.childList[i].child_date_of_birth),
                  trailing: model.state==ViewState.Edit?Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(

                      child: Icon(Icons.edit,size: 16,color: Colors.green,),
                      onTap: (){
                        Navigator.pushNamed(context, "add_child",arguments: [model.childList[i]]);
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
                                      await model.deleteChild(model.childList[i].child_id);
                                    },color: Colors.red,
                                  ),

                                ],

                              );
                            });
                      },

                    )
                  ],
                ):Icon(Icons.remove_red_eye,size: 16),
                  onLongPress: ()async{
                    //@todo: edit delete stuff here
                    model.state!=ViewState.Edit?model.setState(ViewState.Edit):model.setState(ViewState.Idle);
                  },
                  onTap: (){
                    Navigator.pushNamed(context, "child",arguments:model.childList[i]);
                  },
                ),
              );
            }):
            Container(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 2),
              child: Column(
                children: <Widget>[
                  Text(
                    "Welcome to tunza app.",
                    style: TextStyle(
                        fontSize: 16
                    ),
                  ),
                  Text(
                    "- You can add your child on the system by clicking on the floating \"add\" button.\n "+
                        "- If you do not see your child's name on this page after adding them, pull down on the page to refresh the list.\n"+
                        "- To view and add more information about your child or assign a caregiver, click on the card with your child's name on  the list.",
                    style: TextStyle(
                        fontSize: 14
                    ),
                  )
                ],
              ),
            ),
            onRefresh: ()async{
              await model.fetchChildren();
            },
          ),
          floatingActionButton: model.state==ViewState.Idle?FloatingActionButton.extended(
            icon: Icon(Icons.child_care),
            label: Text("add"),
            tooltip: "add child",
            onPressed: (){
              Navigator.pushNamed(context, "add_child",arguments: []);
            },
          ):null,

        );
      },
    );
  }

}
class AppSearch extends SearchDelegate<String>{
  List<Child> childList=[];
  final recentSearch =[];
AppSearch(this.childList);
  @override
  List<Widget> buildActions(BuildContext context) {
    //what kind of actions do i want to perform

    return [IconButton(
      icon: Icon(Icons.clear), 
      onPressed: () {
            query="";
      }
      )
    ];
  }
  

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of the app bar
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow, 
      progress: transitionAnimation,
      ),
      onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => HomeView())
      
      ));
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Center(
      child: Container(
        height: 100.0,
        width: 100.0,
        child: Card(
          color: Colors.red,
          child: Center(
            child: Text(query),
          )
        ),
      )
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // give suggestions whan someone searches something
    final suggestionList = query.isEmpty ? recentSearch : this.childList.where((p)=>p.child_name.startsWith(query)).toList();
    return ListView.builder(itemCount:suggestionList.length ,itemBuilder: (context,i){

      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQOL0wCKxBI3i8-S8OnckAeaszWpVHziXKSnzBRNuABcKZw66M-&usqp=CAU"),
          ),
          title: Text(suggestionList[i].child_name),
          subtitle: Text(suggestionList[i].child_date_of_birth),
          trailing: Icon(Icons.remove_red_eye,size: 16),
          onLongPress: ()async{
            //@todo: edit delete stuff here

          },
          onTap: (){

            Navigator.pushReplacementNamed(context, "child",arguments:suggestionList[i]);
          },
        ),
      );
    });
  }

}