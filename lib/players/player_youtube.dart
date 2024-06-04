import 'package:dtpocketfm/provider/playerprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PlayerYoutube extends StatefulWidget {
  final int? videoId, videoType, typeId, stopTime, contentID;
  final String? playType, videoUrl, vUploadType, videoThumb;
  const PlayerYoutube(
      this.contentID,
      this.playType,
      this.videoId,
      this.videoType,
      this.typeId,
      // this.otherId,
      this.videoUrl,
      this.stopTime,
      this.vUploadType,
      this.videoThumb,
      {super.key});

  @override
  State<PlayerYoutube> createState() => PlayerYoutubeState();
}

class PlayerYoutubeState extends State<PlayerYoutube> {
  YoutubePlayerController? controller;
  bool fullScreen = false;
  late PlayerProvider playerProvider;
  int? playerCPosition;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    _initPlayer();
  }

  _initPlayer() async {
    controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
    debugPrint("videoUrl :===> ${widget.videoUrl}");
    var videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl ?? "");
    debugPrint("videoId :====> $videoId");
    controller = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    // if (widget.playType == "Video" || widget.playType != "Show") {
    //   /* Add Video view */
    playerProvider.getAddContentPlay(
        1, widget.videoId.toString(), 2, widget.contentID.toString());
    // }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return PopScope(
      onPopInvoked: (didPop) {
        onBackPressed();
      },
      child: Scaffold(
        backgroundColor: black,
        body: SafeArea(
          child: Stack(
            children: [
              _buildPlayer(),
              if (!kIsWeb)
                Positioned(
                  top: 15,
                  left: 15,
                  child: SafeArea(
                    child: InkWell(
                      onTap: onBackPressed,
                      focusColor: gray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      child: Utils.buildBackBtnDesign(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (controller == null) {
      return Utils.pageLoader();
    } else {
      return YoutubePlayerScaffold(
        backgroundColor: appBgColor,
        controller: controller!,
        autoFullScreen: true,
        defaultOrientations: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        builder: (context, player) {
          return Scaffold(
            body: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return player;
                },
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    controller?.close();
    if (!(kIsWeb) || !(Constant.isTV)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<bool> onBackPressed() async {
    if (!(kIsWeb) || !(Constant.isTV)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    double? currentPos;
    currentPos = await controller?.currentTime;
    playerCPosition = (currentPos ?? 0).toInt();
    debugPrint("onBackPressed playerCPosition :===> $playerCPosition");
    debugPrint("onBackPressed playType :===> ${widget.playType}");
    if (widget.playType == "Video" || widget.playType == "Show") {
      if ((playerCPosition ?? 0) > 0) {
        /* Add to Continue */
        await playerProvider.addToContinue(
            widget.contentID, 1, "$playerCPosition", "${widget.videoId}", 2);
        if (!mounted) return Future.value(false);
        Navigator.pop(context, true);
        return Future.value(true);
      } else {
        if (!mounted) return Future.value(false);
        Navigator.pop(context, false);
        return Future.value(true);
      }
    } else {
      if (!mounted) return Future.value(false);
      Navigator.pop(context, false);
      return Future.value(true);
    }
  }
}
