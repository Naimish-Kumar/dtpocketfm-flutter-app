import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dtpocketfm/provider/playerprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';

class PlayerVideo extends StatefulWidget {
  final int? videoId, videoType, typeId, stopTime, contentID;
  final String? playType, videoUrl, vUploadType, videoThumb;
  const PlayerVideo(
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
  State<PlayerVideo> createState() => _PlayerVideoState();
}

class _PlayerVideoState extends State<PlayerVideo> {
  late PlayerProvider playerProvider;
  int? playerCPosition, videoDuration;
  ChewieController? _chewieController;
  late VideoPlayerController _videoPlayerController;
  SubtitleController? subtitleController;

  @override
  void initState() {
    debugPrint("vUploadType ========> ${widget.vUploadType}");
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playerInit();
    });
    super.initState();
  }

  _playerInit() async {
    debugPrint("sSubTitleUrls Length =======> ${Constant.subtitleUrls.length}");

    /* Subtitles & Quality */
    if (!kIsWeb) {
      _loadSubtitle();
      if (widget.playType == "Video" || widget.playType != "Show") {
        if (Constant.resolutionsUrls.isNotEmpty) {
          await playerProvider
              .setCurrentQuality(Constant.resolutionsUrls[0].qualityName);
        }
      } else {
        Constant.resolutionsUrls.clear();
        Constant.resolutionsUrls = [];
      }
    }
    /* *********/

    VideoPlayerController videoPlayerController;
    if (widget.playType == "Download") {
      videoPlayerController =
          VideoPlayerController.file(File(widget.videoUrl ?? ""));
    } else {
      if (widget.playType == "Video" || widget.playType != "Show") {
        if (Constant.resolutionsUrls.isNotEmpty) {
          videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(Constant.resolutionsUrls[0].qualityUrl),
          );
        } else {
          videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(widget.videoUrl ?? ""),
          );
        }
      } else {
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl ?? ""),
        );
      }
    }
    await Future.wait([videoPlayerController.initialize()]).then((value) async {
      if (mounted) {
        setState(() {
          _videoPlayerController = videoPlayerController;

          /* Chewie Controller */
          if (widget.playType == "Video" || widget.playType != "Show") {
            _setupController(
                startAt: Duration(milliseconds: widget.stopTime ?? 0));
          } else {
            _setupController(startAt: Duration.zero);
          }
        });
      }
    });

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });

    // if (widget.playType == "Video" || widget.playType != "Show") {
    /* Add Video view */
    playerProvider.getAddContentPlay(
        1, widget.videoId.toString(), 2, widget.contentID.toString());
    // }
  }

  Future<void> _loadSubtitle() async {
    if (Constant.subtitleUrls.isNotEmpty) {
      await playerProvider
          .setCurrentSubtitle(Constant.subtitleUrls[0].subtitleLang);
      debugPrint(
          "Current subtitleUrl ============> ${Constant.subtitleUrls[0].subtitleUrl}");
      subtitleController = SubtitleController(
        subtitleUrl: Constant.subtitleUrls[0].subtitleUrl,
        subtitleType: SubtitleType.srt,
        showSubtitles: true,
      );
    }
  }

  _setupController({required Duration startAt}) async {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      startAt: startAt,
      autoPlay: true,
      autoInitialize: true,
      looping: false,
      fullScreenByDefault: true,
      allowFullScreen: true,
      hideControlsTimer: const Duration(seconds: 1),
      showControls: true,
      allowedScreenSleep: false,
      zoomAndPan: true,
      transformationController: TransformationController(),
      additionalOptions: (context) {
        return <OptionItem>[
          if (!kIsWeb && Constant.subtitleUrls.isNotEmpty)
            OptionItem(
              onTap: () {
                Navigator.pop(context);
                subtitleDialog();
              },
              iconData: Icons.subtitles,
              title: 'Subtitles',
            ),
          if (Constant.resolutionsUrls.isNotEmpty)
            OptionItem(
              onTap: () {
                Navigator.pop(context);
                qualityDialog();
              },
              iconData: Icons.video_collection_rounded,
              title: 'Quality',
            ),
        ];
      },
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [
        (kIsWeb || Constant.isTV)
            ? DeviceOrientation.landscapeLeft
            : DeviceOrientation.portraitUp,
        (kIsWeb || Constant.isTV)
            ? DeviceOrientation.landscapeRight
            : DeviceOrientation.portraitDown,
      ],
      cupertinoProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: complimentryColor,
        backgroundColor: grayDark,
        bufferedColor: whiteTransparent,
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: complimentryColor,
        backgroundColor: grayDark,
        bufferedColor: whiteTransparent,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: MyText(
            color: white,
            text: errorMessage,
            textalign: TextAlign.center,
            fontsizeNormal: 14,
            fontweight: FontWeight.w600,
            fontsizeWeb: 16,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        );
      },
    );
    _videoPlayerController.addListener(() {
      playerCPosition =
          (_chewieController?.videoPlayerController.value.position)
                  ?.inMilliseconds ??
              0;
      videoDuration = (_chewieController?.videoPlayerController.value.duration)
              ?.inMilliseconds ??
          0;
      // debugPrint("playerCPosition :===> $playerCPosition");
      // debugPrint("videoDuration :=====> $videoDuration");
    });
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_chewieController != null) {
      subtitleController?.detach();
      _chewieController?.removeListener(() {});
      _chewieController?.videoPlayerController.dispose();
    }
    if (!(kIsWeb) || !(Constant.isTV)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    playerProvider.clearProvider();
    super.dispose();
  }

  void updateSubtitleUrl({required String subtitleUrl}) {
    debugPrint("new subtitleUrl ============> $subtitleUrl");
    if (subtitleController != null) {
      subtitleController?.updateSubtitleUrl(
        url: subtitleUrl,
      );
    }
  }

  void updateQualityUrl({
    required String qualityName,
    required String qualityUrl,
  }) async {
    debugPrint("new qualityUrl ============> $qualityUrl");
    debugPrint("new qualityName ===========> $qualityName");
    debugPrint("currentQuality ============> ${playerProvider.currentQuality}");
    playerCPosition = (_chewieController?.videoPlayerController.value.position)
            ?.inMilliseconds ??
        0;
    videoDuration = (_chewieController?.videoPlayerController.value.duration)
            ?.inMilliseconds ??
        0;
    debugPrint("playerCPosition ============> $playerCPosition");
    debugPrint("videoDuration ==============> $videoDuration");

    if (_chewieController != null &&
        playerProvider.currentQuality != qualityName) {
      final videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(qualityUrl),
      );
      await Future.wait([videoPlayerController.initialize()])
          .then((value) async {
        if (mounted) {
          await playerProvider.setCurrentQuality(qualityName);
          _videoPlayerController.dispose();
          _videoPlayerController = videoPlayerController;
          _chewieController?.dispose();
          _setupController(
              startAt: Duration(milliseconds: playerCPosition ?? 0));
          Future.delayed(Duration.zero).then((value) {
            if (!mounted) return;
            setState(() {});
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        onBackPressed();
      },
      child: Scaffold(
        backgroundColor: black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _buildPage(),
              ),
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

  Widget _buildPage() {
    if (_chewieController != null &&
        _chewieController?.videoPlayerController.value != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      if (kIsWeb) {
        return _buildPlayer();
      } else {
        if (subtitleController != null) {
          debugPrint("==================== With SUBTITLE ====================");
          return SubtitleWrapper(
            videoPlayerController: _chewieController!.videoPlayerController,
            subtitleController: subtitleController!,
            subtitleStyle: const SubtitleStyle(
              textColor: white,
              hasBorder: true,
            ),
            videoChild: _buildPlayer(),
          );
        } else {
          debugPrint("================== Without SUBTITLE ==================");
          return _buildPlayer();
        }
      }
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: Utils.pageLoader(),
          ),
          const SizedBox(height: 20),
          MyText(
            color: white,
            text: loading,
            textalign: TextAlign.center,
            fontsizeNormal: 14,
            fontweight: FontWeight.w600,
            fontsizeWeb: 16,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ],
      );
    }
  }

  Widget _buildPlayer() {
    return AspectRatio(
      aspectRatio: _chewieController?.aspectRatio ??
          (_chewieController?.videoPlayerController.value.aspectRatio ??
              16 / 9),
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }

  Future<void> subtitleDialog() async {
    await showCupertinoModalPopup<void>(
      context: context,
      semanticsDismissible: true,
      useRootNavigator: true,
      builder: (context) {
        return CupertinoActionSheet(
          actions: Constant.subtitleUrls
              .map(
                (option) => CupertinoActionSheetAction(
                  onPressed: () async {
                    await playerProvider
                        .setCurrentSubtitle(option.subtitleLang);
                    updateSubtitleUrl(subtitleUrl: option.subtitleUrl);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(
                    option.subtitleLang,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontStyle: FontStyle.normal,
                      color: (playerProvider.currentSubtitle ==
                              option.subtitleLang)
                          ? black
                          : black.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            isDestructiveAction: true,
            child: Text(
              "Cancel",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontStyle: FontStyle.normal,
                color: redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    ).then((value) {
      debugPrint("============= SUBTITLE =============");
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> qualityDialog() async {
    await showCupertinoModalPopup<void>(
      context: context,
      semanticsDismissible: true,
      useRootNavigator: true,
      builder: (context) {
        return CupertinoActionSheet(
          actions: Constant.resolutionsUrls
              .map(
                (option) => CupertinoActionSheetAction(
                  onPressed: () async {
                    updateQualityUrl(
                      qualityName: option.qualityName,
                      qualityUrl: option.qualityUrl,
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(
                    option.qualityName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontStyle: FontStyle.normal,
                      color:
                          (playerProvider.currentQuality == option.qualityName)
                              ? black
                              : black.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            isDestructiveAction: true,
            child: Text(
              "Cancel",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontStyle: FontStyle.normal,
                color: redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    ).then((value) {
      debugPrint("============= QUALITY =============");
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<bool> onBackPressed() async {
    if (!(kIsWeb) || !(Constant.isTV)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    debugPrint("onBackPressed playerCPosition :===> $playerCPosition");
    debugPrint("onBackPressed videoDuration :===> $videoDuration");
    debugPrint("onBackPressed playType :===> ${widget.playType}");

    // if (widget.playType == "Video" || widget.playType == "Show") {
    if ((playerCPosition ?? 0) > 0 &&
        (playerCPosition == videoDuration ||
            (playerCPosition ?? 0) > (videoDuration ?? 0))) {
      /* Remove From Continue */
      await playerProvider.removeFromContinue(
          widget.contentID, 1, "${widget.videoId}", 2);
      if (!mounted) return Future.value(false);
      Navigator.pop(context, true);
      return Future.value(true);
    } else if ((playerCPosition ?? 0) > 0) {
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
    // } else {
    // if (!mounted) return Future.value(false);
    // Navigator.pop(context, false);
    // return Future.value(true);
    // }
  }
}
