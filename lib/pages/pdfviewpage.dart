import 'package:dtpocketfm/provider/novelsectiondataprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatefulWidget {
  final String? pdfLink, title;
  final dynamic novelChapterID, contentID;
  const PdfViewPage(
      {super.key,
      required this.pdfLink,
      required this.title,
      required this.contentID,
      required this.novelChapterID});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late NovelSectionDataProvider novelpovider;
  late PdfViewerController _pdfViewerController;
  @override
  void initState() {
    debugPrint("widget.pdfLink == ${widget.pdfLink}");
    novelpovider =
        Provider.of<NovelSectionDataProvider>(context, listen: false);
    _pdfViewerController = PdfViewerController();
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    await novelpovider.getAddContentPlay(
        2, widget.novelChapterID.toString(), 0, widget.contentID.toString());

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (_pdfViewerController.pageNumber != _pdfViewerController.pageCount) {
          await novelpovider.addToContinue(
              widget.contentID,
              2,
              "${_pdfViewerController.pageNumber}",
              "${widget.novelChapterID}",
              0);
          if (!context.mounted) return;
          Navigator.pop(context);
          return;
        } else {
          Navigator.pop(context);
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBgColor,
          leading: InkWell(
            onTap: () async {
              if (_pdfViewerController.pageNumber !=
                  _pdfViewerController.pageCount) {
                await novelpovider.addToContinue(
                    widget.contentID,
                    2,
                    "${_pdfViewerController.pageNumber}",
                    "${widget.novelChapterID}",
                    0);
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MyImage(imagePath: "backwith_bg.png"),
            ),
          ),
          title: MyText(
            fontsizeWeb: 18,
            color: white,
            text: widget.title.toString(),
            fontsizeNormal: 18,
            fontweight: FontWeight.w600,
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.bookmark,
                color: white,
                semanticLabel: 'Bookmark',
              ),
              onPressed: () {
                _pdfViewerKey.currentState?.openBookmarkView();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.first_page,
                color: white,
              ),
              onPressed: () {
                _pdfViewerController.firstPage();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.last_page,
                color: white,
              ),
              onPressed: () {
                _pdfViewerController.lastPage();
              },
            ),
          ],
        ),
        body: SfPdfViewer.network(
          widget.pdfLink.toString(),
          controller: _pdfViewerController,
          key: _pdfViewerKey,
          onPageChanged: (details) {
            _pdfViewerController.pageNumber;
            debugPrint("Current Page nO -- ${_pdfViewerController.pageNumber}");
            debugPrint(
                "Current Page pageCount -- ${_pdfViewerController.pageCount}");
          },
        ),
      ),
    );
  }
}
