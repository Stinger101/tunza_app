import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:tunza_app/core/models/caregiver.dart';
import 'package:tunza_app/core/models/category.dart';
import 'package:tunza_app/core/models/child.dart';
import 'package:tunza_app/core/models/info.dart';
import 'package:tunza_app/core/models/invite.dart';
import 'package:tunza_app/core/models/profile.dart';
import 'dart:async';
import 'dart:io';
import 'package:retry/retry.dart';

import 'package:tunza_app/core/models/user.dart';
import 'package:tunza_app/core/models/post.dart';
import 'package:tunza_app/core/models/comment.dart';
import 'package:tunza_app/core/services/authentication_service.dart';
import 'package:tunza_app/locator.dart';
import 'package:tunza_app/res/strings.dart';
class Api{

  static const url= StringConstants.api_url;
  var client = http.Client();
  Dio dio= new Dio();
  Future<User> loginWithEmailAndPassword(String email,String password)async{
    var res = await client.post("$url/login", body: {"email":email,"password":password});
    print(res.body);
    if(res.statusCode==200){
      return User.fromJson(json.decode(res.body));
    } else {
      return null;
    }
  }
  Future<User> registerWithEmailAndPassword(name,String email,phonenumber,String password,{File avatar})async{
    FormData formData=new FormData.fromMap({
      "name":name,
      "email":email,
      "phonenumber":phonenumber,
      "password":password,
      "avatar":await MultipartFile.fromFile(avatar.path,filename: avatar.path.split('/').last)
    });
    var res = await dio.post("$url/register", data:formData );
    if(res.statusCode==200){
      return User.fromJson(res.data);
    } else {
      return null;
    }
  }
  Future<Profile> getUserProfile()async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.get("$url/user",headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"});
    print(res.body);
    if(res.statusCode==200){
      return Profile.fromJson(json.decode(res.body));
    } else {
      return null;
    }
  }
  Future<bool> addChild(String name,String date_of_birth)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/add_child",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body:{"name":name,"date_of_birth":date_of_birth}
    );
    if(res.statusCode==201){
      return true;
    }else{
      //print(res.body);
      return false;
    }
  }
  Future<bool> editChild(int id,String name,String date_of_birth)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$id/update",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body:{"name":name,"date_of_birth":date_of_birth}
    );
    if(res.statusCode==200){
      return true;
    }else{
      //print(res.body);
      return false;
    }
  }

  Future <List<Child>> fetchChildren()async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(
          ()=>client.get("$url/user/children",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
        ),
      retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException
    );
    if(res.statusCode==200){

      List data=json.decode(res.body);
      var children=List.generate(data.length, (i){
        return Child.fromJson(data[i]);
      });
      return children;
    }else{
      return [];
    }

  }
  Future<bool> deleteChild(child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/delete",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    );
    if(res.statusCode==200){
      return true;
    }else{
      return false;
    }
  }
  Future<bool> addCategory(name)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/add_category",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"name":name}
    );
    if(res.statusCode==201){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<bool> editCategory(int id,name)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/category/$id/update",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"name":name}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }

  Future<List<Category>> fetchCategories()async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(()=> client.get("$url/user/categories",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    ),retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException
    );
    if(res.statusCode==200){
      List data=json.decode(res.body);
      if(data.length>0) {
        var categories = List.generate(data.length, (i) {
          return Category.fromJson(data[i]);
        });
        return categories;
      }else{
        return [Category.empty()];
      }
    }else{
      return [Category.empty()];
    }
  }
  Future<List> fetchRawCategories()async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(()=>client.get("$url/user/categories",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    ),retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException,
    );
    if(res.statusCode==200){
      List data=json.decode(res.body);

        return data;
    }else{
      return [];
    }
  }
  Future<bool> deleteCategory(int id,name)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/category/$id/delete",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  //todo: fetch list of caregivers in a category and check children assigned to them
  Future<List<Caregiver>> fetchCaregivers(child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(()=>client.get("$url/user/child/$child_id/caregivers",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    ),
      retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException
    );
    print(res.body);
    if(res.statusCode==200){
      List data=json.decode(res.body);
      var caregivers=List.generate(data.length, (i){
        return Caregiver.fromJson(data[i]);
      });
      return caregivers;
    }else{
      return [];
    }
  }
  Future<bool> sendInvite(child_id,email_provided,int category_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/add_caregiver",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
      body: {"email_provided":email_provided,"category_id":category_id.toString()}
    );
    if(res.statusCode==201){
      return true;
    }else{
//      print(res.body);
      return false;
    }
  }
  Future<bool> deleteInvite(child_id,caregiver_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/caregiver/$caregiver_id/delete",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    );
    if(res.statusCode==200){
      return true;
    }else{
//      print(res.body);
      return false;
    }
  }

  Future <List<Child>> fetchCaregiverChildren()async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(
            ()=>client.get("$url/caregiver/children",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
        ),
      retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException
    );
    if(res.statusCode==200){
      List data=json.decode(res.body);
      var children=List.generate(data.length, (i){
        return Child.fromJson(data[i]);
      });
      return children;
    }else{
      return [];
    }

  }
  Future<List<Invite>> fetchInvites()async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(()=>client.get("$url/caregiver/invites",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    ),retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException
    );
    if(res.statusCode==200){
      List data=json.decode(res.body);
      var invites=List.generate(data.length, (i){
        return Invite.fromJson(data[i]);
      });
      return invites;
    }else{
      return [];
    }
  }
  Future<bool> updateInvite(invite_id,stat)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/caregiver/invite/$invite_id/update",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"status":stat.toString()}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<bool> addChildInfo(child_id,topic,content,visibility)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/add_basicinfo",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"topic":topic,"content":content,"visibility":visibility.toString()}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<bool> editChildInfo(info_id,child_id,topic,content,visibility)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/basicinfo/$info_id/update",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"topic":topic,"content":content,"visibility":visibility.toString()}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<List<Info>> fetchChildInfo(child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(()=>client.get("$url/user/child/$child_id/basicinfos",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    ),retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException,
    );
    if(res.statusCode==200){
      List data=json.decode(res.body);
      var infos=List.generate(data.length, (i){
        return Info.fromJson(data[i]);
      });
      return infos;
    }else{
      return [];
    }
  }
  Future<bool> deleteChildInfo(info_id,child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/basicinfo/$info_id/delete",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }

  Future<bool> makeCall(String call_url,int receiver_id,String call_type)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/call",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body:{"call_url":call_url,"receiver_id":receiver_id.toString(),"call_type":call_type}
    );
    print(res.body);
    if(res.statusCode!=500){
      return true;
    }else{
      //print(res.body);
      return false;
    }
  }
  Future<bool> addPost(child_id,topic)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/add_topic",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"topic":topic}
    );
    if(res.statusCode==201){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<bool> editPost(topic_id,child_id,topic)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/topic/$topic_id/update",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"topic":topic}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<List<Post>> fetchPosts(child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(()=>client.get("$url/user/child/$child_id/topics",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    ),retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException
    );
    print(res.body);
    if(res.statusCode==200){
      List data=json.decode(res.body);
      var posts=List.generate(data.length, (i){
        return Post.fromJson(data[i]);
      });
      return posts;
    }else{
      return [];
    }
  }
  Future<bool> deletePost(topic_id,child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/topic/$topic_id/delete",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<bool> addComment(topic_id,child_id,comment)async{
    print(topic_id);
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/topic/$topic_id/add_comment",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"comment":comment}
    );
    if(res.statusCode==201){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<bool> editComment(comment_id,topic_id,child_id,comment)async{
    print(topic_id);
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/topic/$topic_id/comment/$comment_id/update",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"},
        body: {"comment":comment}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
  Future<List<Comment>> fetchComments(topic_id,child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await retry(()=>client.get("$url/user/child/$child_id/topic/$topic_id/comments",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    ),retryIf: (e)=>e is SocketException || e is TimeoutException || e is http.ClientException
    );
    print(res.body);
    if(res.statusCode==200){
      List data=json.decode(res.body);
      var comments=List.generate(data.length, (i){
        return Comment.fromJson(data[i]);
      });
      return comments;
    }else{
      return [];
    }
  }
  Future<bool> deleteComment(comment_id,topic_id,child_id)async{
    AuthenticationService _authenticationService=locator<AuthenticationService>();
    var res = await client.post("$url/user/child/$child_id/topic/$topic_id/comment/$comment_id/delete",
        headers: {"Authorization":"Bearer ${_authenticationService.currentUser.user_token}"}
    );
    if(res.statusCode==200){
      return true;
    }else{
      print(res.body);
      return false;
    }
  }
}