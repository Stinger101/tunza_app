import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/models/user.dart';
import 'package:tunza_app/core/services/api.dart';
import 'package:tunza_app/core/services/authentication_service.dart';
import 'package:tunza_app/core/viewmodels/base_model.dart';
import 'package:tunza_app/core/models/comment.dart';
import 'package:tunza_app/locator.dart';

class SinglePostModel extends BaseModel{
  Api _api=locator<Api>();
  AuthenticationService _authenticationService=locator<AuthenticationService>();
  User get currentUser=>_authenticationService.currentUser;
  List<Comment> commentList=[];
  fetchComments(topic_id,child_id)async{
    setState(ViewState.Busy);
    commentList=await _api.fetchComments(topic_id, child_id);
    setState(ViewState.Idle);
  }

}