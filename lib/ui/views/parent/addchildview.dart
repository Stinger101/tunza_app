import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/viewmodels/parent/child_model.dart';
import 'package:tunza_app/ui/views/base_view.dart';

class AddChildView extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  Child child;
  String _name;
  String _date_of_birth;
  var txt;
  AddChildView(args){
    this.child=args.length>0?args[0]:null;
    this.txt=TextEditingController(text: this.child!=null?this.child.child_date_of_birth:null);
  }
  @override
  Widget build(BuildContext context) {
    return BaseView<ChildModel>(
      builder: (context, model, child){
        return Scaffold(
          appBar: new AppBar(title: new Text("Child details"),),
          body: new Center(
            child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 80.0,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.teal,
                        radius: 50.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
                        child: TextFormField(
                          initialValue: this.child!=null?this.child.child_name:null,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.child_care),
                            labelText: 'Childs Name',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (val){
                            _name=val;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
                        child: new FocusScope(
                          canRequestFocus: false,
                          node: new FocusScopeNode(),
                          child: TextFormField(
                          controller: txt,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Date of birth',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onTap: ()async{
                            final date = await showDatePicker(context: context,firstDate: DateTime(1900),
                              initialDate: DateTime.now(),lastDate: DateTime(2100));
                            txt = TextEditingController(text: DateFormat('yyyy-MM-dd').format(date));
                            model.setState(ViewState.Idle);
                          },
                            onSaved: (val){
                            _date_of_birth=val;
                            },
                        ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: model.state==ViewState.Busy?
                        CircularProgressIndicator():
                        MaterialButton(
                          child: Text ('Submit'),
                          color: Colors.blueGrey,
                          onPressed: ()async{
                            if(formKey.currentState.validate()){
                              formKey.currentState.save();
                              var success = this.child==null?await model.addChild(_name, _date_of_birth):await model.editChild(this.child.child_id,_name, _date_of_birth);
                              if(success){
                                formKey.currentState.reset();
                                txt=TextEditingController(text: "");
                                Navigator.of(context).pushReplacementNamed("/");
                              }
                            }
                          },
                        ),
                      )
                    ],
                  ),
                )
            ),
          ),
        );
      },
    );
  }
}
