import 'package:dtpocketfm/pages/audiobook.dart';
import 'package:dtpocketfm/pages/home.dart';
import 'package:dtpocketfm/pages/music.dart';
import 'package:dtpocketfm/pages/novel.dart';
import 'package:dtpocketfm/pages/threads.dart';
import 'package:dtpocketfm/provider/generalprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
const double playerMinHeight = kIsWeb ? 100 : 70;
const miniplayerPercentageDeclaration = 0.7;

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> {
  SharedPre sharedPre = SharedPre();
  int selectedIndex = 0;
  DateTime? currentBackPressTime;

  static List<Widget> widgetOptions = <Widget>[
    const Home(pageName: ""),
    const AudioBooks(
      pageName: '',
    ),
    const Novel(
      pageName: '',
    ),
    const Threads(),
    const Music(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (Constant.userID != null) {
      await profileProvider.getProfile(context);
    } else {
      Utils.updatePremium("0");
      Utils.loadAds(context);
    }
    if (!mounted) return;
    await generalsetting.getGeneralsetting(context);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _onItemTapped(int index) {
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      setState(() {
        selectedIndex = index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        onBackPressed();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Center(
            child: widgetOptions[selectedIndex],
          ),
          selectedIndex == 3
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Utils.buildMusicPanel(context)),
        ]),
        bottomNavigationBar: BottomAppBar(
          color: appBgColor,
          padding: const EdgeInsets.all(5),
          elevation: 5,
          child: BottomNavigationBar(
            backgroundColor: appBgColor,
            selectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 10,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              color: primaryDark,
            ),
            unselectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 10,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              color: primaryDark,
            ),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 5,
            currentIndex: selectedIndex,
            unselectedItemColor: gray,
            selectedItemColor: primaryDark,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView1,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_home', iconColor: primaryDark),
                icon: _buildBottomNavIcon(iconName: 'ic_home', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView2,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_audiobook', iconColor: primaryDark),
                icon: _buildBottomNavIcon(
                    iconName: 'ic_audiobook', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView3,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_novel', iconColor: primaryDark),
                icon:
                    _buildBottomNavIcon(iconName: 'ic_novel', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView4,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_thread', iconColor: primaryDark),
                icon:
                    _buildBottomNavIcon(iconName: 'ic_thread', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView5,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_music', iconColor: primaryDark),
                icon:
                    _buildBottomNavIcon(iconName: 'ic_music', iconColor: gray),
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavIcon(
      {required String iconName, required Color? iconColor}) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          "assets/images/$iconName.png",
          width: 22,
          height: 22,
          color: iconColor,
        ),
      ),
    );
  }

  Future<bool> onBackPressed() async {
    if (selectedIndex == 0) {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        Utils.showSnackbar(context, "", "exit_warning", true);
        return Future.value(false);
      }
      SystemNavigator.pop();
      return Future.value(true);
    } else {
      _onItemTapped(0);
      return Future.value(false);
    }
  }
}
