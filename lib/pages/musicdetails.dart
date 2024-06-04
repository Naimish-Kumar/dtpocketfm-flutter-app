import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dtpocketfm/pages/bottombar.dart';
import 'package:dtpocketfm/provider/musicdetailprovider.dart';
import 'package:dtpocketfm/provider/musicprovider.dart';
import 'package:dtpocketfm/subscription/audiobuy.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/musicmanager.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/musicutils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mymarqueetext.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:rxdart/rxdart.dart';

AudioPlayer audioPlayer = AudioPlayer();
late MusicManager musicManager;

Stream<PositionData> get positionDataStream {
  return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero))
      .asBroadcastStream();
}

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

class MusicDetails extends StatefulWidget {
  final bool ishomepage;
  final dynamic contentid;
  final String episodeid, contenttype, stoptime;
  const MusicDetails({
    super.key,
    required this.ishomepage,
    required this.contenttype,
    required this.contentid,
    required this.episodeid,
    required this.stoptime,
  });

  @override
  State<MusicDetails> createState() => _MusicDetailsState();
}

class _MusicDetailsState extends State<MusicDetails>
    with WidgetsBindingObserver {
  late ScrollController _scrollcontroller;
  late MusicDetailProvider musicDetailProvider;
  late MusicProvider musicProvider;
  int currentstoptime = 0;

  @override
  void initState() {
    debugPrint("contentid == ${widget.episodeid}");
    ambiguate(WidgetsBinding.instance)?.addObserver(this);
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);

    _scrollcontroller = ScrollController();

    getApi();

    super.initState();
    _scrollcontroller.addListener(_scrollListener);
  }

  getApi() async {
    debugPrint(
        "(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre = ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.displayDescription}");
    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre ==
        "3") {
      _fetchDataPlaylist(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.album
                  .toString() ??
              "",
          musicDetailProvider.podcastcurrentPage ?? 0);
    } else {
      await _fetchDataPodcast(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                  ?.album
                  .toString() ??
              "",
          musicDetailProvider.podcastcurrentPage ?? 0);
    }
  }

  _checkPremiumPlayPause() async {
    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['is_audio_paid'] ==
            1 &&
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['is_buy'] ==
            0) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AudioBuy(
            coins: (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['is_audio_coin'],
            contentid: widget.contentid,
            episodeName:
                (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['name'],
            episodeid: widget.episodeid,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
    } else {
      if (audioPlayer.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
    }
  }

  _scrollListener() async {
    if (!_scrollcontroller.hasClients) return;
    if (_scrollcontroller.offset >=
            _scrollcontroller.position.maxScrollExtent &&
        !_scrollcontroller.position.outOfRange) {
      await musicDetailProvider.setLoadMore(true);
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "3") {
        if ((musicDetailProvider.playlistcurrentPage ?? 0) <
            (musicDetailProvider.playlisttotalPage ?? 0)) {
          _fetchDataPlaylist(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.playlistcurrentPage);
        }
      } else {
        if ((musicDetailProvider.podcastcurrentPage ?? 0) <
            (musicDetailProvider.podcasttotalPage ?? 0)) {
          _fetchDataPodcast(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.podcastcurrentPage);
        }
      }
    }
  }

  Future<void> _fetchDataPodcast(podcastId, int? nextPage) async {
    debugPrint("isMorePage  ======> ${musicDetailProvider.podcastisMorePage}");
    debugPrint("currentPage ======> ${musicDetailProvider.podcastcurrentPage}");
    debugPrint("totalPage   ======> ${musicDetailProvider.podcasttotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.setLoadMore(true);

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.displayDescription
            .toString() ==
        "searchMusic") {
      musicDetailProvider.getSearchVideo((nextPage ?? 0) + 1);
    } else {
      await musicDetailProvider.getEpisodeByPodcast(
          podcastId, (nextPage ?? 0) + 1);
    }
  }

  Future<void> _fetchDataPlaylist(podcastId, int? nextPage) async {
    debugPrint("nextpage   ======> $nextPage");

    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.setLoadMore(true);
    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.displayDescription
            .toString() ==
        "author") {
      await musicDetailProvider.getEpisodeByAuthorMusic(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.artist,
          (nextPage ?? 0) + 1);
    } else {
      await musicDetailProvider.getEpisodeByMusic(
          Constant.musicsectionId, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() async {
    musicDetailProvider.clearProvider();
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder<PositionData>(
    //     stream: positionDataStream,
    //     builder: (context, snapshot) {
    //       final positionData = snapshot.data;
    //       currentstoptime = positionData?.position.inMilliseconds ?? 0;
    //       return Builder(builder: (context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: kIsWeb ? 500 : MediaQuery.of(context).size.height,
      child: Miniplayer(
        valueNotifier: playerExpandProgress,
        minHeight: playerMinHeight,
        duration: const Duration(seconds: 1),
        maxHeight: MediaQuery.of(context).size.height,
        controller: controller,
        elevation: 4,
        backgroundColor: transparentColor,
        onDismiss: () {},
        onDismissed: () async {
          currentlyPlaying.value = null;

          if (Constant.userID != null) {
            await musicDetailProvider.addToContinue(
                widget.contentid, widget.contenttype, currentstoptime, 0, 0);
          }

          currentlyPlaying.value = null;
          await audioPlayer.pause();
          await audioPlayer.stop();
          await audioPlayer.dispose();
          audioPlayer = AudioPlayer();
          if (mounted) {
            setState(() {});
          }

          musicManager.clearMusicPlayer();
          musicDetailProvider.clearProvider();
        },
        curve: Curves.easeInOutCubicEmphasized,
        builder: (height, percentage) {
          final bool miniplayer = percentage < miniplayerPercentageDeclaration;

          if (!miniplayer) {
            return Scaffold(
              backgroundColor: appBgColor,
              body: SafeArea(
                bottom: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: appBgColor,
                  ),
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                          child:
                              kIsWeb ? webBuildMusicPage() : buildMusicPage()),
                    ],
                  ),
                ),
              ),
            );
          }

          //Miniplayer
          final percentageMiniplayer = percentageFromValueInRange(
              min: playerMinHeight,
              max: MediaQuery.of(context).size.height,
              value: height);

          final elementOpacity = 1 - 1 * percentageMiniplayer;
          final progressIndicatorHeight = 2 - 2 * percentageMiniplayer;

          return Builder(builder: (context) {
            return Scaffold(
              body: _buildMusicPanel(
                  height, elementOpacity, progressIndicatorHeight),
            );
          });
        },
      ),
    );
    //   });
    // });
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FittedBox(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 11,
                  child: MyImage(
                    height: 25,
                    width: 25,
                    imagePath: "backwith_bg.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: MyText(
              fontsizeWeb: 16,
              color: white,
              text: "playingstart",
              maxline: 1,
              fontsizeNormal: 16,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget buildMusicPage() {
    return NestedScrollView(
      controller: _scrollcontroller,
      floatHeaderSlivers: false,
      physics: const ScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.vertical,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          /* UserProfile Section */
          SliverAppBar(
            floating: false,
            forceElevated: false,
            snap: false,
            elevation: 0,
            expandedHeight: MediaQuery.of(context).size.height * 0.72,
            automaticallyImplyLeading: false,
            backgroundColor: appBgColor,
            flexibleSpace: FlexibleSpaceBar(
              background: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Music Image With Song Title
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          StreamBuilder<SequenceState?>(
                              stream: audioPlayer.sequenceStateStream,
                              builder: (context, snapshot) {
                                if ((audioPlayer.sequenceState?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.extras?['is_audio_paid'] ==
                                        1 &&
                                    (audioPlayer.sequenceState?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.extras?['is_buy'] ==
                                        0) {
                                  audioPlayer.pause();
                                } else {
                                  audioPlayer.play();
                                }
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(width: 3.0, color: white),
                                      bottom:
                                          BorderSide(width: 3.0, color: white),
                                    ),
                                  ),
                                  child: MyNetworkImage(
                                    imgWidth: MediaQuery.of(context).size.width,
                                    imgHeight:
                                        MediaQuery.of(context).size.height *
                                            0.30,
                                    imageUrl: ((audioPlayer
                                                .sequenceState
                                                ?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.artUri)
                                        .toString(),
                                    fit: BoxFit.fill,
                                  ),
                                );
                              }),
                          const SizedBox(height: 15),
                          StreamBuilder<SequenceState?>(
                              stream: audioPlayer.sequenceStateStream,
                              builder: (context, snapshot) {
                                return Container(
                                  height: 35,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: MyMarqueeText(
                                      text: ((audioPlayer
                                                  .sequenceState
                                                  ?.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.title)
                                          .toString(),
                                      fontsize: Dimens.textBig,
                                      color: white),
                                );
                              }),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // All Buttons
                    Container(
                      // height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            child: StreamBuilder<PositionData>(
                              stream: positionDataStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data;
                                return ProgressBar(
                                  progress:
                                      positionData?.position ?? Duration.zero,
                                  buffered: positionData?.bufferedPosition ??
                                      Duration.zero,
                                  total:
                                      positionData?.duration ?? Duration.zero,
                                  progressBarColor: white,
                                  baseBarColor: colorAccent,
                                  bufferedBarColor: gray,
                                  thumbColor: white,
                                  barHeight: 2.0,
                                  thumbRadius: 5.0,
                                  timeLabelPadding: 5.0,
                                  timeLabelType: TimeLabelType.totalTime,
                                  timeLabelTextStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontStyle: FontStyle.normal,
                                    color: white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSeek: (duration) {
                                    audioPlayer.seek(duration);
                                  },
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Privious Audio Setup
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) => IconButton(
                                  iconSize: 40,
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasPrevious
                                      ? audioPlayer.seekToPrevious
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // 10 Second Privious
                              StreamBuilder<PositionData>(
                                stream: positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;
                                  return InkWell(
                                      onTap: () {
                                        tenSecNextOrPrevious(
                                            positionData?.position.inSeconds
                                                    .toString() ??
                                                "",
                                            false);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: MyImage(
                                            width: 30,
                                            height: 30,
                                            imagePath: "ic_tenprevious.png"),
                                      ));
                                },
                              ),
                              const SizedBox(width: 15),
                              // Pause and Play Controll
                              StreamBuilder<PlayerState>(
                                stream: audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  final playerState = snapshot.data;
                                  final processingState =
                                      playerState?.processingState;
                                  final playing = playerState?.playing;
                                  if (processingState ==
                                          ProcessingState.loading ||
                                      processingState ==
                                          ProcessingState.buffering) {
                                    return Container(
                                      margin: const EdgeInsets.all(8.0),
                                      width: 50.0,
                                      height: 50.0,
                                      child: const CircularProgressIndicator(
                                        color: colorAccent,
                                      ),
                                    );
                                  } else if (playing != true) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: colorAccent,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: white,
                                        ),
                                        color: white,
                                        iconSize: 50.0,
                                        // onPressed: audioPlayer.play,

                                        onPressed: () {
                                          // if (kIsWeb == false) {
                                          _checkPremiumPlayPause();
                                          // } else {
                                          //   audioPlayer.play();
                                          // }
                                        },
                                      ),
                                    );
                                  } else if (processingState !=
                                      ProcessingState.completed) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: colorAccent,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.pause_rounded,
                                          color: white,
                                        ),
                                        iconSize: 50.0,
                                        color: white,
                                        // onPressed: audioPlayer.pause,
                                        onPressed: () {
                                          // if (kIsWeb == false) {
                                          _checkPremiumPlayPause();
                                          // } else {
                                          //   audioPlayer.pause();
                                          // }
                                        },
                                      ),
                                    );
                                  } else {
                                    return IconButton(
                                      icon: const Icon(
                                        Icons.replay_rounded,
                                        color: white,
                                      ),
                                      iconSize: 60.0,
                                      onPressed: () => audioPlayer.seek(
                                          Duration.zero,
                                          index: audioPlayer
                                              .effectiveIndices!.first),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 15),
                              // 10 Second Next
                              StreamBuilder<PositionData>(
                                stream: positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;

                                  return InkWell(
                                      onTap: () {
                                        tenSecNextOrPrevious(
                                            positionData?.position.inSeconds
                                                    .toString() ??
                                                "",
                                            true);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: MyImage(
                                            width: 30,
                                            height: 30,
                                            imagePath: "ic_tennext.png"),
                                      ));
                                },
                              ),
                              const SizedBox(width: 15),
                              // Next Audio Play
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) => IconButton(
                                  iconSize: 40.0,
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasNext
                                      ? audioPlayer.seekToNext
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            decoration: const BoxDecoration(
                                // color: colorAccent,
                                ),
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Volumn Costome Set
                                IconButton(
                                  iconSize: 30.0,
                                  icon: const Icon(Icons.volume_up),
                                  color: white,
                                  onPressed: () {
                                    showSliderDialog(
                                      context: context,
                                      title: "Adjust volume",
                                      divisions: 10,
                                      min: 0.0,
                                      max: 2.0,
                                      value: audioPlayer.volume,
                                      stream: audioPlayer.volumeStream,
                                      onChanged: audioPlayer.setVolume,
                                    );
                                  },
                                ),
                                // Audio Speed Costomized
                                StreamBuilder<double>(
                                  stream: audioPlayer.speedStream,
                                  builder: (context, snapshot) => IconButton(
                                    icon: Text(
                                      overflow: TextOverflow.ellipsis,
                                      "${snapshot.data?.toStringAsFixed(1)}x",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: white,
                                          fontSize: 14),
                                    ),
                                    onPressed: () {
                                      showSliderDialog(
                                        context: context,
                                        title: "Adjust speed",
                                        divisions: 10,
                                        min: 0.5,
                                        max: 2.0,
                                        value: audioPlayer.speed,
                                        stream: audioPlayer.speedStream,
                                        onChanged: audioPlayer.setSpeed,
                                      );
                                    },
                                  ),
                                ),
                                // Loop Node Button
                                StreamBuilder<LoopMode>(
                                  stream: audioPlayer.loopModeStream,
                                  builder: (context, snapshot) {
                                    final loopMode =
                                        snapshot.data ?? LoopMode.off;
                                    const icons = [
                                      Icon(Icons.repeat,
                                          color: white, size: 30.0),
                                      Icon(Icons.repeat,
                                          color: colorAccent, size: 30.0),
                                      Icon(Icons.repeat_one,
                                          color: colorAccent, size: 30.0),
                                    ];
                                    const cycleModes = [
                                      LoopMode.off,
                                      LoopMode.all,
                                      LoopMode.one,
                                    ];
                                    final index = cycleModes.indexOf(loopMode);
                                    return IconButton(
                                      icon: icons[index],
                                      onPressed: () {
                                        audioPlayer.setLoopMode(cycleModes[
                                            (cycleModes.indexOf(loopMode) + 1) %
                                                cycleModes.length]);
                                      },
                                    );
                                  },
                                ),
                                // Suffle Button
                                StreamBuilder<bool>(
                                  stream: audioPlayer.shuffleModeEnabledStream,
                                  builder: (context, snapshot) {
                                    final shuffleModeEnabled =
                                        snapshot.data ?? false;
                                    return IconButton(
                                      iconSize: 30.0,
                                      icon: shuffleModeEnabled
                                          ? const Icon(Icons.shuffle,
                                              color: colorAccent)
                                          : const Icon(Icons.shuffle,
                                              color: white),
                                      onPressed: () async {
                                        final enable = !shuffleModeEnabled;
                                        if (enable) {
                                          await audioPlayer.shuffle();
                                        }
                                        await audioPlayer
                                            .setShuffleModeEnabled(enable);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // Bottom Sheet
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre)
                  .toString() ==
              "2"
          ? const SizedBox.shrink()
          : Consumer<MusicDetailProvider>(
              builder: (context, seactionprovider, child) {
              return Container(
                decoration: const BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  seactionprovider.changeMusicTab("episode");
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  // height: 50,
                                  alignment: Alignment.center,
                                  // color: colorAccent,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          fontsizeWeb: Dimens.textDesc,
                                          color: white,
                                          text: "listofaudio",
                                          multilanguage: true,
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textDesc,
                                          // inter: false,
                                          maxline: 6,
                                          fontweight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                      seactionprovider.istype == "episode"
                                          ? Container(
                                              width: 100,
                                              height: 1,
                                              color: colorAccent,
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildPodcastEpisode()
                    ],
                  ),
                ),
              );
            }),
    );
  }

  Widget webBuildMusicPage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              // Music Image With Song Title
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    StreamBuilder<SequenceState?>(
                      stream: audioPlayer.sequenceStateStream,
                      builder: (context, snapshot) {
                        if ((audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.extras?['is_audio_paid'] ==
                                1 &&
                            (audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.extras?['is_buy'] ==
                                0) {
                          audioPlayer.pause();
                        } else {
                          audioPlayer.playing
                              ? audioPlayer.play()
                              : audioPlayer.pause();
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            // border: Border(
                            //   top: BorderSide(width: 3.0, color: white),
                            //   bottom: BorderSide(width: 3.0, color: white),
                            // ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: MyNetworkImage(
                              imgWidth:
                                  MediaQuery.of(context).size.width * 0.35,
                              imgHeight:
                                  MediaQuery.of(context).size.height * 0.35,
                              imageUrl: ((audioPlayer.sequenceState
                                          ?.currentSource?.tag as MediaItem?)
                                      ?.artUri)
                                  .toString(),
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) {
                          return Container(
                            height: 35,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: MyMarqueeText(
                                text: ((audioPlayer.sequenceState?.currentSource
                                            ?.tag as MediaItem?)
                                        ?.title)
                                    .toString(),
                                fontsize: Dimens.textBig,
                                color: white),
                          );
                        }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return ProgressBar(
                            progress: positionData?.position ?? Duration.zero,
                            buffered:
                                positionData?.bufferedPosition ?? Duration.zero,
                            total: positionData?.duration ?? Duration.zero,
                            progressBarColor: white,
                            baseBarColor: colorAccent,
                            bufferedBarColor: gray,
                            thumbColor: white,
                            barHeight: 2.0,
                            thumbRadius: 5.0,
                            timeLabelPadding: 5.0,
                            timeLabelType: TimeLabelType.totalTime,
                            timeLabelTextStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                              color: white,
                              fontWeight: FontWeight.w700,
                            ),
                            onSeek: (duration) {
                              audioPlayer.seek(duration);
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Privious Audio Setup
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) => IconButton(
                            iconSize: 40,
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              color: white,
                            ),
                            onPressed: audioPlayer.hasPrevious
                                ? audioPlayer.seekToPrevious
                                : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // 10 Second Privious
                        StreamBuilder<PositionData>(
                          stream: positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;
                            return InkWell(
                                onTap: () {
                                  tenSecNextOrPrevious(
                                      positionData?.position.inSeconds
                                              .toString() ??
                                          "",
                                      false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: MyImage(
                                      width: 30,
                                      height: 30,
                                      imagePath: "ic_tenprevious.png"),
                                ));
                          },
                        ),
                        const SizedBox(width: 15),
                        // Pause and Play Controll
                        StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState =
                                playerState?.processingState;
                            final playing = playerState?.playing;
                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                width: 50.0,
                                height: 50.0,
                                child: const CircularProgressIndicator(
                                  color: colorAccent,
                                ),
                              );
                            } else if (playing != true) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: colorAccent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: white,
                                  ),
                                  color: white,
                                  iconSize: 50.0,
                                  // onPressed: audioPlayer.play,

                                  onPressed: () {
                                    // if (kIsWeb == false) {
                                    _checkPremiumPlayPause();
                                    // } else {
                                    //   audioPlayer.play();
                                    // }
                                  },
                                ),
                              );
                            } else if (processingState !=
                                ProcessingState.completed) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: colorAccent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.pause_rounded,
                                    color: white,
                                  ),
                                  iconSize: 50.0,
                                  color: white,
                                  // onPressed: audioPlayer.pause,
                                  onPressed: () {
                                    // if (kIsWeb == false) {
                                    _checkPremiumPlayPause();
                                    // } else {
                                    //   audioPlayer.pause();
                                    // }
                                  },
                                ),
                              );
                            } else {
                              return IconButton(
                                icon: const Icon(
                                  Icons.replay_rounded,
                                  color: white,
                                ),
                                iconSize: 60.0,
                                onPressed: () => audioPlayer.seek(Duration.zero,
                                    index: audioPlayer.effectiveIndices!.first),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 15),
                        // 10 Second Next
                        StreamBuilder<PositionData>(
                          stream: positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;

                            return InkWell(
                                onTap: () {
                                  tenSecNextOrPrevious(
                                      positionData?.position.inSeconds
                                              .toString() ??
                                          "",
                                      true);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: MyImage(
                                      width: 30,
                                      height: 30,
                                      imagePath: "ic_tennext.png"),
                                ));
                          },
                        ),
                        const SizedBox(width: 15),
                        // Next Audio Play
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) => IconButton(
                            iconSize: 40.0,
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: white,
                            ),
                            onPressed: audioPlayer.hasNext
                                ? audioPlayer.seekToNext
                                : null,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      decoration: BoxDecoration(
                          color: colorAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30)),
                      margin:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Volumn Costome Set
                          IconButton(
                            iconSize: 30.0,
                            icon: const Icon(Icons.volume_up),
                            color: white,
                            onPressed: () {
                              showSliderDialog(
                                context: context,
                                title: "Adjust volume",
                                divisions: 10,
                                min: 0.0,
                                max: 2.0,
                                value: audioPlayer.volume,
                                stream: audioPlayer.volumeStream,
                                onChanged: audioPlayer.setVolume,
                              );
                            },
                          ),
                          // Audio Speed Costomized
                          StreamBuilder<double>(
                            stream: audioPlayer.speedStream,
                            builder: (context, snapshot) => IconButton(
                              icon: Text(
                                overflow: TextOverflow.ellipsis,
                                "${snapshot.data?.toStringAsFixed(1)}x",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: white,
                                    fontSize: 14),
                              ),
                              onPressed: () {
                                showSliderDialog(
                                  context: context,
                                  title: "Adjust speed",
                                  divisions: 10,
                                  min: 0.5,
                                  max: 2.0,
                                  value: audioPlayer.speed,
                                  stream: audioPlayer.speedStream,
                                  onChanged: audioPlayer.setSpeed,
                                );
                              },
                            ),
                          ),
                          // Loop Node Button
                          StreamBuilder<LoopMode>(
                            stream: audioPlayer.loopModeStream,
                            builder: (context, snapshot) {
                              final loopMode = snapshot.data ?? LoopMode.off;
                              const icons = [
                                Icon(Icons.repeat, color: white, size: 30.0),
                                Icon(Icons.repeat,
                                    color: colorAccent, size: 30.0),
                                Icon(Icons.repeat_one,
                                    color: colorAccent, size: 30.0),
                              ];
                              const cycleModes = [
                                LoopMode.off,
                                LoopMode.all,
                                LoopMode.one,
                              ];
                              final index = cycleModes.indexOf(loopMode);
                              return IconButton(
                                icon: icons[index],
                                onPressed: () {
                                  audioPlayer.setLoopMode(cycleModes[
                                      (cycleModes.indexOf(loopMode) + 1) %
                                          cycleModes.length]);
                                },
                              );
                            },
                          ),
                          // Suffle Button
                          StreamBuilder<bool>(
                            stream: audioPlayer.shuffleModeEnabledStream,
                            builder: (context, snapshot) {
                              final shuffleModeEnabled = snapshot.data ?? false;
                              return IconButton(
                                iconSize: 30.0,
                                icon: shuffleModeEnabled
                                    ? const Icon(Icons.shuffle,
                                        color: colorAccent)
                                    : const Icon(Icons.shuffle, color: white),
                                onPressed: () async {
                                  final enable = !shuffleModeEnabled;
                                  if (enable) {
                                    await audioPlayer.shuffle();
                                  }
                                  await audioPlayer
                                      .setShuffleModeEnabled(enable);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                          ?.genre)
                      .toString() ==
                  "2"
              ? const SizedBox.shrink()
              : Consumer<MusicDetailProvider>(
                  builder: (context, seactionprovider, child) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: colorPrimaryDark,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollcontroller,
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      seactionprovider
                                          .changeMusicTab("episode");
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      // height: 50,
                                      alignment: Alignment.center,
                                      // color: colorAccent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MyText(
                                              fontsizeWeb: Dimens.textDesc,
                                              color: white,
                                              text: "listofaudio",
                                              multilanguage: true,
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textDesc,
                                              // inter: false,
                                              maxline: 6,
                                              fontweight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          seactionprovider.istype == "episode"
                                              ? Container(
                                                  width: 100,
                                                  height: 1,
                                                  color: colorAccent,
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildPodcastEpisode()
                        ],
                      ),
                    ),
                  );
                }),
        )
      ],
    );
  }

  Widget _buildMusicPanel(
      dynamicPanelHeight, elementOpacity, progressIndicatorHeight) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: appBgColor,
      ),
      child: Column(
        children: [
          Expanded(
            child: Opacity(
              opacity: elementOpacity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Music Image */
                  StreamBuilder<SequenceState?>(
                    stream: audioPlayer.sequenceStateStream,
                    builder: (context, snapshot) {
                      if ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.extras?['is_audio_paid'] ==
                              1 &&
                          (audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.extras?['is_buy'] ==
                              0) {
                        audioPlayer.pause();
                      } else {
                        audioPlayer.playing
                            ? audioPlayer.play()
                            : audioPlayer.pause();
                      }
                      return Container(
                        width: kIsWeb ? 120 : 80,
                        height: dynamicPanelHeight,
                        padding: const EdgeInsets.fromLTRB(10, 3, 5, 3),
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: MyNetworkImage(
                            imgWidth: MediaQuery.of(context).size.width,
                            imgHeight: MediaQuery.of(context).size.height,
                            imageUrl: ((audioPlayer.sequenceState?.currentSource
                                        ?.tag as MediaItem?)
                                    ?.artUri)
                                .toString(),
                            fit: kIsWeb ? BoxFit.fill : BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                child: MyMarqueeText(
                                    text: ((audioPlayer
                                                .sequenceState
                                                ?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.title)
                                        .toString(),
                                    fontsize: Dimens.textBig,
                                    color: white),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              MyText(
                                  color: white,
                                  text: ((audioPlayer
                                              .sequenceState
                                              ?.currentSource
                                              ?.tag as MediaItem?)
                                          ?.displaySubtitle)
                                      .toString(),
                                  textalign: TextAlign.left,
                                  fontsizeNormal: 12,
                                  fontsizeWeb: 12,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontweight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          );
                        }),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              if (audioPlayer.hasPrevious) {
                                return IconButton(
                                  iconSize: 25.0,
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasPrevious
                                      ? audioPlayer.seekToPrevious
                                      : null,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        /* Play/Pause */
                        StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 35.0,
                                  height: 35.0,
                                  child: Utils.pageLoader(),
                                );
                              } else if (playing != true) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: white,
                                    ),
                                    color: white,
                                    iconSize: 25.0,
                                    // onPressed: audioPlayer.play,

                                    onPressed: () {
                                      // if (kIsWeb == false) {
                                      _checkPremiumPlayPause();
                                      // } else {
                                      //   audioPlayer.play();
                                      // }
                                    },
                                  ),
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.pause_rounded,
                                      color: white,
                                    ),
                                    iconSize: 25.0,
                                    color: white,
                                    // onPressed: audioPlayer.pause,
                                    onPressed: () async {
                                      debugPrint("_checkPremiumPlayPause");
                                      // if (kIsWeb == false) {
                                      await _checkPremiumPlayPause();
                                      // } else {
                                      //   audioPlayer.pause();
                                      // }
                                    },
                                  ),
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(
                                    Icons.replay_rounded,
                                    color: white,
                                  ),
                                  iconSize: 35.0,
                                  onPressed: () => audioPlayer.seek(
                                      Duration.zero,
                                      index:
                                          audioPlayer.effectiveIndices!.first),
                                );
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        /* Next */
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              if (audioPlayer.hasNext) {
                                return IconButton(
                                  iconSize: 25.0,
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasNext
                                      ? audioPlayer.seekToNext
                                      : null,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        const SizedBox(
                          width: kIsWeb ? 100 : 0,
                        )
                      ],
                    ),
                  ),
                  /* Previous */
                ],
              ),
            ),
          ),
          Opacity(
            opacity: elementOpacity,
            child: StreamBuilder<PositionData>(
              stream: positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  progressBarColor: white,
                  baseBarColor: colorAccent,
                  bufferedBarColor: white.withOpacity(0.24),
                  barCapShape: BarCapShape.square,
                  barHeight: progressIndicatorHeight,
                  thumbRadius: 0.0,
                  timeLabelLocation: TimeLabelLocation.none,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPodcastEpisode() {
    return Consumer<MusicDetailProvider>(
        builder: (context, musicDetailProvider, child) {
      if (musicDetailProvider.loading &&
          musicDetailProvider.loadmore == false) {
        return Container();
      } else {
        if (musicDetailProvider.epidoseByPodcastModel.status == 200 &&
            musicDetailProvider.podcastEpisodeList != null) {
          if ((musicDetailProvider.podcastEpisodeList?.length ?? 0) > 0) {
            return ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 10,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  musicDetailProvider.podcastEpisodeList?.length ?? 0, (index) {
                debugPrint(
                    "buildPodcastEpisode buildPodcastEpisode = ${musicDetailProvider.podcastEpisodeList?.length}");
                return InkWell(
                  onTap: () async {
                    audioPlayer.pause();

                    if (musicDetailProvider
                            .podcastEpisodeList?[index].isAudioPaid ==
                        1) {
                      if (musicDetailProvider
                              .podcastEpisodeList?[index].isBuy ==
                          1) {
                        musicManager.setInitialMusic(
                            index,
                            musicDetailProvider
                                    .podcastEpisodeList?[index].contentType
                                    .toString() ??
                                "",
                            musicDetailProvider.podcastEpisodeList,
                            musicDetailProvider
                                    .podcastEpisodeList?[index].contentId
                                    .toString() ??
                                "",
                            addView(
                              musicDetailProvider
                                      .podcastEpisodeList?[index].contentType
                                      .toString() ??
                                  "",
                              ((audioPlayer.sequenceState?.currentSource?.tag
                                          as MediaItem?)
                                      ?.id)
                                  .toString(),
                              musicDetailProvider
                                      .podcastEpisodeList?[index].contentId
                                      .toString() ??
                                  "",
                            ),
                            false,
                            0,
                            musicDetailProvider.podcastEpisodeList?[index]
                                        .contentType ==
                                    3
                                ? 1.toString()
                                : (audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.extras?['is_buy']
                                        .toString() ??
                                    '',
                            musicDetailProvider
                                    .podcastEpisodeList?[index].isAudioPaid ??
                                0,
                            "music",
                            "0");
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AudioBuy(
                                      coins: musicDetailProvider
                                          .podcastEpisodeList?[index]
                                          .isAudioCoin,
                                      contentid: musicDetailProvider
                                          .podcastEpisodeList?[index].contentId
                                          .toString(),
                                      episodeName: musicDetailProvider
                                          .podcastEpisodeList?[index].name,
                                      episodeid: musicDetailProvider
                                          .podcastEpisodeList?[index].id
                                          .toString(),
                                    )));
                      }
                    } else {
                      musicManager.setInitialMusic(
                          index,
                          musicDetailProvider
                                  .podcastEpisodeList?[index].contentType
                                  .toString() ??
                              "",
                          musicDetailProvider.podcastEpisodeList,
                          musicDetailProvider
                                  .podcastEpisodeList?[index].contentId
                                  .toString() ??
                              "",
                          addView(
                            musicDetailProvider
                                    .podcastEpisodeList?[index].contentType
                                    .toString() ??
                                "",
                            ((audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.id)
                                .toString(),
                            musicDetailProvider
                                    .podcastEpisodeList?[index].contentId
                                    .toString() ??
                                "",
                          ),
                          false,
                          0,
                          musicDetailProvider
                                      .podcastEpisodeList?[index].contentType ==
                                  3
                              ? 1.toString()
                              : (audioPlayer.sequenceState?.currentSource?.tag
                                          as MediaItem?)
                                      ?.extras?['is_buy']
                                      .toString() ??
                                  '',
                          musicDetailProvider
                                  .podcastEpisodeList?[index].isAudioPaid ??
                              0,
                          "music",
                          "0");
                    }
                  },
                  child: Container(
                    color: ((audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.id)
                                .toString() ==
                            musicDetailProvider.podcastEpisodeList?[index].id
                                .toString()
                        ? colorAccent.withOpacity(0.10)
                        : colorPrimaryDark,
                    height: 75,
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Row(children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorAccent),
                            ),
                            child: MyNetworkImage(
                              fit: BoxFit.fill,
                              imgWidth: 70,
                              imageUrl: ((musicDetailProvider
                                          .podcastEpisodeList?[index]
                                          .portraitImg) ==
                                      null)
                                  ? (musicDetailProvider
                                          .podcastEpisodeList?[index].image
                                          .toString() ??
                                      "")
                                  : musicDetailProvider
                                          .podcastEpisodeList?[index]
                                          .portraitImg
                                          .toString() ??
                                      "",
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: ((audioPlayer.sequenceState?.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.id)
                                          .toString() ==
                                      musicDetailProvider
                                          .podcastEpisodeList?[index].id
                                          .toString()
                                  ? MyImage(
                                      width: 30,
                                      height: 30,
                                      imagePath: "music.gif")
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                                fontsizeWeb: Dimens.textMedium,
                                color: white,
                                multilanguage: false,
                                text: ((musicDetailProvider
                                            .podcastEpisodeList?[index].name) ==
                                        null)
                                    ? (musicDetailProvider
                                            .podcastEpisodeList?[index].title
                                            .toString() ??
                                        "")
                                    : musicDetailProvider
                                            .podcastEpisodeList?[index].name
                                            .toString() ??
                                        "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                // inter: false,
                                maxline: 1,
                                fontweight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: musicDetailProvider
                                        .podcastEpisodeList?[index].description
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textSmall,
                                // inter: false,
                                fontsizeWeb: Dimens.textSmall,
                                maxline: 1,
                                fontweight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ]),
                  ),
                );
              }),
            );
          } else {
            debugPrint(
                "buildPodcastEpisode buildPodcastEpisode = ${musicDetailProvider.podcastEpisodeList?.length}");
            return const NoData(title: "", subTitle: "");
          }
        } else {
          debugPrint(
              "buildPodcastEpisode buildPodcastEpisode = ${musicDetailProvider.podcastEpisodeList?.length}");
          return const NoData(title: "", subTitle: "");
        }
      }
    });
  }

  Widget detailItemPodcast() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textBig,
              // inter: false,
              fontsizeWeb: Dimens.textBig,
              maxline: 5,
              fontweight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textMedium,
              // inter: false,
              maxline: 100,
              fontsizeWeb: Dimens.textMedium,
              fontweight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              fontsizeWeb: Dimens.textTitle,
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['podcasts_name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textTitle,
              // inter: false,
              maxline: 2,
              fontweight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }

  Widget detailItemRadioPlaylist() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['title'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textBig,
              fontsizeWeb: Dimens.textBig,
              // inter: false,
              maxline: 5,
              fontweight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textMedium,
              fontsizeWeb: Dimens.textMedium,
              // inter: false,
              maxline: 100,
              fontweight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre)
                      .toString() ==
                  "playlist"
              ? MyText(
                  color: white,
                  text: (audioPlayer.sequenceState?.currentSource?.tag
                          as MediaItem?)
                      ?.extras?['channel_name'],
                  multilanguage: false,
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textMedium,
                  fontsizeWeb: Dimens.textMedium,
                  // inter: false,
                  maxline: 100,
                  fontweight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

/* 10 Second Next And Previous Functionality */
// bool isnext = true > next Audio Seek
// bool isnext = false > previous Audio Seek
  tenSecNextOrPrevious(String audioposition, bool isnext) {
    dynamic firstHalf = Duration(seconds: int.parse(audioposition));
    const secondHalf = Duration(seconds: 10);
    Duration movePosition;
    if (isnext == true) {
      movePosition = firstHalf + secondHalf;
    } else {
      movePosition = firstHalf - secondHalf;
    }

    musicManager.seek(movePosition);
  }

  addView(contentType, episodeID, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.getAddContentPlay(3, episodeID, 1, contentId);
  }

/* Music And PodcastEpisode Like */
  like() async {}
}
