import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/services/api.dart';
import 'package:tunza_app/core/services/authentication_service.dart';
import 'package:tunza_app/core/viewmodels/base_model.dart';
import 'package:tunza_app/locator.dart';

class ChildModel extends BaseModel{
  Api _api=locator<Api>();
  addChild(String name,String date_of_birth)async{
    setState(ViewState.Busy);
    var success = await _api.addChild(name,date_of_birth);
    setState(ViewState.Idle);
    return success;
  }
  editChild(child_id,String name,String date_of_birth)async{
    setState(ViewState.Busy);
    var success = await _api.editChild(child_id,name,date_of_birth);
    setState(ViewState.Idle);
    return success;
  }
}