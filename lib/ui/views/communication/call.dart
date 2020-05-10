import 'dart:async';

import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class  MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lets Call',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey
      ),
      home: VoiceCallPage() ,

    );
  }
}

class VoiceCallPage extends StatefulWidget {

  @override
  _VoiceCallPageState createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {

  Timer _timerInstance;
  int _start = 0;
  String _timer = '';

  void startTimer(){
    var onSec = Duration(seconds: 1);
    _timerInstance = Timer.periodic(onSec, (Timer timer) => setState(() {
      if (_start < 0){
        _timerInstance.cancel();
      }else{
        _start = _start + 1;
        _timer = getTimerTime(_start);
      }
    }));
  }

  String getTimerTime(int start){
    int minutes= (start~/60);
    String sMinute = '';
    if(minutes.toString().length ==1){
      sMinute = '0'+ minutes.toString();
    }else sMinute = minutes.toString();

    int seconds= (start % 60);
    String sSeconds = '';
    if(minutes.toString().length ==1){
      sSeconds = seconds.toString();
    }else sMinute = seconds.toString();

    return sMinute + ':' + sSeconds;
  }
  @override

  void initState(){
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var clipRRect = ClipRRect(
      borderRadius: BorderRadius.circular(200.0),
      child: Image.network(
        'https://avatars0.githubusercontent.com/u/1515991?s=400&u=992d9ed72113954c22d87d6185064027bc600c51&v=4',),
    );
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        padding: EdgeInsets.all(46.0),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 15.0,),
            Text('Santosh Rampu',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w900,
                  fontSize: 25),
            ),
            SizedBox(height: 15.0,),
            Text(
              'Calling...',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w300,
                  fontSize: 14),
            ),
            SizedBox(height:20.0,),
            Text(
              _timer,
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w300,
                  fontSize: 10),
            ),
            SizedBox(height:20.0,),
            clipRRect,
            SizedBox(height: 60.0,),
            Row(
              mainAxisSize:MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FunctionalButton(title: 'speaker', icon: Icons.phone_in_talk, onPressed: (){},),
                FunctionalButton(title: 'video call', icon: Icons.videocam, onPressed: (){},),
                FunctionalButton(title: 'mute', icon: Icons.mic_off, onPressed: (){},),
              ],
            ),
            SizedBox(
              height:70.0,
            ),
            FloatingActionButton(
              onPressed: (){},
              elevation:20.0,
              shape: CircleBorder(side: BorderSide(color:Colors.red)),
              mini:false,
              child: Icon(Icons.call_end, color: Colors.red,),
              backgroundColor: Colors.red[100],
            )
          ],
        ),
      ),
    );

  }
}

class FunctionalButton extends StatefulWidget {
  final title;
  final icon;
  final Function() onPressed;

  const FunctionalButton({Key key, this.title, this.icon, this.onPressed}) : super(key: key);

  @override
  _FunctionalButtonState createState() => _FunctionalButtonState();
}

class _FunctionalButtonState extends State<FunctionalButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RawMaterialButton(
          onPressed: widget.onPressed,
          splashColor: Colors.blueGrey,
          fillColor: Colors.white,
          elevation: 10.0,
          shape: CircleBorder(),
          child: Icon(
              widget.icon,
              size: 30.0,
              color:Colors.blueGrey),
        ),
        Container(
            margin: EdgeInsets.symmetric(vertical:10.0, horizontal:2.0),
            child: Text(widget.title, style: TextStyle(fontSize: 11.0, color: Colors.blueGrey,))
        )
      ],

    );


  }
}