import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tunza_app/ui/views/auth/registerview.dart';
import 'package:tunza_app/ui/views/caregiver/addcaretakerpage.dart';
import 'package:tunza_app/ui/views/caregiver/appointment_view.dart';
import 'package:tunza_app/ui/views/caregiver/home_view.dart';
import 'package:tunza_app/ui/views/caregiver/inviteview.dart';
import 'package:tunza_app/ui/views/caregiver/singlechildview.dart';
import 'package:tunza_app/ui/views/parent/addcategoryview.dart';
import 'package:tunza_app/ui/views/parent/addchildinfo_view.dart';
import 'package:tunza_app/ui/views/parent/addchildview.dart';
import 'package:tunza_app/ui/views/parent/caregiverview.dart';
import 'package:tunza_app/ui/views/parent/categoryview.dart';
import 'package:tunza_app/ui/views/parent/communicationview.dart';
import 'package:tunza_app/ui/views/parent/addpost_view.dart';
import 'package:tunza_app/ui/views/parent/home_view.dart';
import 'package:tunza_app/ui/views/parent/invitecaretakerview.dart';
import 'package:tunza_app/ui/views/auth/loginview.dart';
import 'package:tunza_app/ui/views/auth/profilepage.dart';
import 'package:tunza_app/ui/views/parent/singlechildview.dart';
import 'package:tunza_app/ui/views/parent/videocall_view.dart';
const String initialRoute="login";
class Router{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case "/":
        return MaterialPageRoute(builder:(_)=>HomeView());
        break;
      case "login":
        return MaterialPageRoute(builder:(_)=>LoginView());
        break;
      case "register":
        return MaterialPageRoute(builder:(_)=>RegisterView());
        break;
      case "profile":
        return MaterialPageRoute(builder:(_)=>ProfilePage("My profile"));
        break;
      case "add_child":
        return MaterialPageRoute(builder: (_)=>AddChildView(settings.arguments));
        break;
      case "child":
        return MaterialPageRoute(builder: (_)=>SingleChildView(settings.arguments));
        break;
      case "add_category":
        return MaterialPageRoute(builder: (_)=>AddCategoryView("Add Category"));
        break;
      case "categories":
        return MaterialPageRoute(builder: (_)=>CategoryView("Categories"));
        break;
      case "caregivers":
        return MaterialPageRoute(builder: (_)=>CaregiverView(settings.arguments));
        break;
      case "invite_caregiver":
        return MaterialPageRoute(builder: (_)=>InviteCaretakerView(settings.arguments));
        break;
      case "communication":
        return MaterialPageRoute(builder: (_)=>CommunicationView(settings.arguments));
        break;
      case "add_post":
        return MaterialPageRoute(builder: (_)=>AddPostView(settings.arguments));
        break;
      case "caregiver_home":
        return MaterialPageRoute(builder:(_)=>CaregiverHomeView());
        break;
      case "view_invites":
        return MaterialPageRoute(builder:(_)=>InviteView());
        break;
      case "appointments":
        return MaterialPageRoute(builder:(_)=>AppointmentView());
        break;
      case "add_child_info":
        return MaterialPageRoute(builder: (_)=>AddChildInfoView(settings.arguments));
        break;
      case "edit_child_info":
        return MaterialPageRoute(builder: (_)=>AddChildInfoView(settings.arguments));
        break;
      case "caregiver_child_view":
        return MaterialPageRoute(builder: (_)=>CaregiverSingleChildView(settings.arguments));
        break;
      case "videocall_view":
        return MaterialPageRoute(builder: (_)=>VideoCallView(settings.arguments));
        break;

    }
  }
}