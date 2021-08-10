import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:fourleggedlove/utils/constants.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    Key? key,
    required this.token,
    required this.channelName,
    required this.res,
  }) : super(key: key);
  final String token;
  final String channelName;
  final DocumentSnapshot<Map<String, dynamic>> res;

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false, speakerEnabled = false, noiseFilterEnabled = false;
  late final RtcEngine? _engine;
  final Common _common = Common();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              icon: Icon(
                  speakerEnabled ? Icons.speaker_phone : Icons.call_outlined),
              onPressed: _onToggleSpeaker),
          actions: [
            IconButton(
                icon: Icon(noiseFilterEnabled
                    ? Icons.multitrack_audio
                    : Icons.strikethrough_s_outlined),
                onPressed: _onToggleNoiseFilter),
            IconButton(
              icon: Icon(Icons.library_books_rounded),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Color(0xff31343c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Center(child: Text("Meeting Log")),
                  titleTextStyle: TextStyle(
                    fontFamily: "Nexa",
                    color: _common.blue,
                    fontSize: 20,
                  ),
                  contentTextStyle: TextStyle(color: Colors.blueGrey),
                  content: _panel(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.channelName))
                    .whenComplete(() =>
                        _common.displayToast("Meeting code copied!", context));
              },
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[
              _viewRows(),
              _toolbar(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    deleteChannelAndMeeting();
    _users.clear();
    _engine!.leaveChannel();
    _engine!.destroy();
    super.dispose();
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  deleteChannelAndMeeting() async {
    widget.res.reference.update({
      inCallWith: "",
      channelName: "",
    }).whenComplete(
      () => FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .update({
        inCallWith: "",
        channelName: "",
      }),
    );
  }

  Future<void> initialize() async {
    if (dotenv.env['APP_ID']!.isEmpty) {
      setState(() {
        _infoStrings
            .add('APP_ID missing, please provide your APP_ID in settings.dart');
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions();
    await _engine!.setVideoEncoderConfiguration(configuration);
    await _engine!.joinChannel(widget.token, widget.channelName, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(dotenv.env['APP_ID']!);
    await _engine!.enableVideo();
    await _engine!.setChannelProfile(ChannelProfile.Communication);
    // await _engine!.setClientRole(ClientRole.);
    await _engine!.enableFaceDetection(true);
  }

  void _addAgoraEventHandlers() {
    _engine!.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
      case 3:
        return Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off_outlined : Icons.mic_none_outlined,
              color: muted ? Colors.white : _common.blue,
              size: 25.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? _common.blue : Colors.white,
            padding: const EdgeInsets.all(10.0),
          ),
          Flexible(child: SizedBox(width: 30)),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end_outlined,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          Flexible(child: SizedBox(width: 30)),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera_outlined,
              color: _common.purple,
              size: 25.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(10.0),
          )
        ],
      ),
    );
  }

  Widget _panel() {
    return Container(
      width: 100,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          thickness: 0,
          height: 5,
          color: Colors.transparent,
        ),
        shrinkWrap: true,
        addAutomaticKeepAlives: true,
        itemCount: _infoStrings.length,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Text(
              _infoStrings[index],
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Poppins", color: Colors.white70),
            ),
          );
        },
      ),
    );
  }

  void _onCallEnd(BuildContext context) => Navigator.pop(context);

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine!.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine!.switchCamera();
  }

  void _onToggleSpeaker() {
    setState(() => speakerEnabled = !speakerEnabled);
    _engine!.setEnableSpeakerphone(speakerEnabled);
    _common.displayToast(
        "Speaker turned ${speakerEnabled ? 'on' : 'off'}", context);
  }

  void _onToggleNoiseFilter() {
    setState(() => noiseFilterEnabled = !noiseFilterEnabled);
    _engine!.enableDeepLearningDenoise(noiseFilterEnabled);

    _common.displayToast(
        "Noise Filtering turned ${noiseFilterEnabled ? 'on' : 'off'}", context);
  }
}
