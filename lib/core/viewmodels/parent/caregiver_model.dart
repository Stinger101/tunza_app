import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/call.dart';
import 'package:tunza_app/core/models/caregiver.dart';
import 'package:tunza_app/core/models/profile.dart';
import 'package:tunza_app/core/models/user.dart';
import 'package:tunza_app/core/services/api.dart';
import 'package:tunza_app/core/services/authentication_service.dart';
import 'package:tunza_app/core/services/socket_service.dart';
import 'package:tunza_app/core/viewmodels/base_model.dart';
import 'package:tunza_app/locator.dart';
import 'package:tunza_app/ui/views/parent/caregiverview.dart';

class CaregiverModel extends BaseModel{
  Api _api=locator<Api>();
  AuthenticationService _authenticationService=locator<AuthenticationService>();
  User get currentUser=>_authenticationService.currentUser;
  List<Caregiver> caregiverList=[];


  bool isInChannel = false;
  final infoStrings = <String>[];

  final sessions = List<VideoSession>();
  String dropdownValue = 'Off';

  /// remote user list
  final remoteUsers = List<int>();
  SocketService socketService=locator<SocketService>();
  fetchCategivers(child_id)async{
    setState(ViewState.Busy);
    caregiverList= await _api.fetchCaregivers(child_id);
    setState(ViewState.Idle);
  }
  makeCall(call_url,receiver_id,call_type)async{
    setState(ViewState.Idle);
    await _api.makeCall(call_url, receiver_id, call_type);
    setState(ViewState.Idle);
  }
}