import 'package:dtpocketfm/provider/avatarprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myusernetworkimg.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  late AvatarProvider avatarProvider;
  String? pickedImageUrl;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _getData() async {
    avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    await avatarProvider.getAvatar();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    avatarProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        onBackPressed();
      },
      child: Scaffold(
        backgroundColor: appBgColor,
        appBar:
            Utils.myAppBarWithBack(context, "changeprofileimage", true, true),
        body: SafeArea(
          child: SingleChildScrollView(
            child: _buildPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (avatarProvider.loading) {
      return ShimmerUtils.buildAvatarGrid(
          context, 77, MediaQuery.of(context).size.width, 4, 50);
    } else {
      if (avatarProvider.avatarModel.status == 200 &&
          avatarProvider.avatarModel.result != null) {
        if ((avatarProvider.avatarModel.result?.length ?? 0) > 0) {
          return RefreshIndicator(
            backgroundColor: white,
            color: complimentryColor,
            displacement: 80,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 1500))
                  .then((value) {
                avatarProvider.setLoading(true);
                Future.delayed(Duration.zero).then((value) {
                  if (!mounted) return;
                  setState(() {});
                });
                _getData();
              });
            },
            child: AlignedGridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemCount: (avatarProvider.avatarModel.result?.length ?? 0),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int position) {
                return InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    debugPrint("Clicked position =====> $position");
                    pickedImageUrl = avatarProvider
                            .avatarModel.result?[position].image
                            .toString() ??
                        "";
                    debugPrint("pickedImageUrl =====> $pickedImageUrl");
                    onBackPressed();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 77,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: MyUserNetworkImage(
                        imageUrl: avatarProvider
                                .avatarModel.result?[position].image
                                .toString() ??
                            "",
                        fit: BoxFit.cover,
                        imgHeight: MediaQuery.of(context).size.height,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const NoData(title: 'nodata', subTitle: '');
        }
      } else {
        return const NoData(title: 'nodata', subTitle: '');
      }
    }
  }

  Future<bool> onBackPressed() async {
    debugPrint("pickedImageUrl ====> $pickedImageUrl");
    Navigator.pop(context, pickedImageUrl);
    return Future.value(true);
  }
}
