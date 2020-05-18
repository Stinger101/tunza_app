import 'package:tunza_app/core/enums/viewstate.dart';
import 'package:tunza_app/core/services/api.dart';
import 'package:tunza_app/core/viewmodels/base_model.dart';
import 'package:tunza_app/locator.dart';

class AddPostModel extends BaseModel{
  Api _api=locator<Api>();
  addPost(child_id,topic,{attachment,attachment_type})async{
    setState(ViewState.Busy);
    var success = await _api.addPost(child_id, topic,attachment:attachment,attachment_type: attachment_type);
    setState(ViewState.Idle);
    return success;
  }
  editPost(topic_id,child_id,topic)async{
    setState(ViewState.Busy);
    var success= await _api.editPost(topic_id, child_id, topic);
    setState(ViewState.Idle);
  }
}