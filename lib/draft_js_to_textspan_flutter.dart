library draft_js_to_textspan_flutter;

import 'package:draft_js_to_textspan_flutter/model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DraftJSFlutter extends StatefulWidget {
  final Map<String, dynamic> map;
  final double fontSize;
  Color color;
  DraftJSFlutter(this.map, this.fontSize, this.color);

  Color get getColor => color;

  set setColor(Color color) {
    this.color = color;
  }

  @override
  _DraftJSFlutterState createState() => _DraftJSFlutterState();
}

class _DraftJSFlutterState extends State<DraftJSFlutter> {
  double subtreeHeight;

  bool _offstage = true;

  _launchURL(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  void _getWidgetHeight(GlobalKey key) {
    if (subtreeHeight == null) {
      RenderBox renderBox = key.currentContext.findRenderObject();
      subtreeHeight = renderBox.size.height;
    }
    setState(() {
      _offstage = false;
    });
  }

  List<Widget> getTextSpans(BuildContext context) {
    List<Widget> list = List();
    List<TextSpan> temporary = List();
    Color textColor = widget.color;
    FontWeight textFontWeight;
    FontStyle textFontStyle;
    TextDecoration decoration;
    TapGestureRecognizer recognizer;
    Alignment textAlign = Alignment.centerLeft;
    if (widget.map != null) {
      print(widget.map);
      DraftJsObject draftJsObject = DraftJsObject.fromJson(widget.map);
      int currentIndex = 0;
      if (draftJsObject != null && draftJsObject.blocks != null) {
        for (int blockIndex = 0;
            blockIndex < draftJsObject.blocks.length;
            blockIndex++) {
          String text = draftJsObject.blocks[blockIndex].text;
          GlobalKey key = GlobalKey();
          // int textLength = draftJsObject.blocks[blockIndex].text != null
          //     ? draftJsObject.blocks[blockIndex].text.runes.length
          //     : 0;

          // for (int textIndex = 0; textIndex < textLength; textIndex++) {
          //   print('TextIndex: ' + textIndex.toString());
          textColor = widget.color;
          textFontWeight = FontWeight.w400;
          textFontStyle = FontStyle.normal;
          decoration = TextDecoration.none;

          for (int inlineStyleIndex = 0;
              inlineStyleIndex <
                  draftJsObject.blocks[blockIndex].inlineStyleRanges.length;
              inlineStyleIndex++) {
            // if (draftJsObject
            //     .blocks[blockIndex].inlineStyleRanges[inlineStyleIndex]
            //     .contains(textIndex)) {
            switch (draftJsObject
                .blocks[blockIndex].inlineStyleRanges[inlineStyleIndex].style) {
              case "BOLD":
                textFontWeight = FontWeight.w700;
                break;
              case "ITALIC":
                textFontStyle = FontStyle.italic;
                break;
              case "UNDERLINE":
                decoration = TextDecoration.underline;
                break;
              case "STRIKETHROUGH":
                decoration = TextDecoration.lineThrough;
                break;

              // }
            }
          }

          for (int entityRangeIndex = 0;
              entityRangeIndex <
                  draftJsObject.blocks[blockIndex].entityRanges.length;
              entityRangeIndex++) {
            // if (draftJsObject
            //     .blocks[blockIndex].entityRanges[entityRangeIndex]
            //     .contains(textIndex)) {
            textColor = Colors.blue;
            decoration = TextDecoration.underline;
            recognizer = TapGestureRecognizer()
              ..onTap = () {
                String key = draftJsObject
                    .blocks[blockIndex].entityRanges[entityRangeIndex].key
                    .toString();
                EntityMap entityMap = draftJsObject.entityMap[key];
                _launchURL(entityMap.data.url);
              };
            // }
          }
          if (draftJsObject.blocks[blockIndex]?.data?.text_align != null) {
            switch (draftJsObject.blocks[blockIndex].data.text_align) {
              case "left":
                textAlign = Alignment.centerLeft;
                break;
              case "right":
                textAlign = Alignment.centerRight;
                break;
              case "center":
                textAlign = Alignment.center;
                break;
              default:
                textAlign = Alignment.centerLeft;
            }
          } else {
            textAlign = Alignment.centerLeft;
          }

          // }
          // if (draftJsObject.blocks[blockIndex].type ==
          //         "unordered-list-item" &&
          //     currentIndex != blockIndex) {
          //   list.add(
          //     Row(
          //       children: [
          //         Text(
          //           "• ",
          //           style: TextStyle(
          //               fontSize: 15.0,
          //               color: textColor,
          //               fontStyle: textFontStyle,
          //               fontWeight: textFontWeight,
          //               decoration: decoration),
          //         ),
          //         RichText(
          //           text: TextSpan(
          //             text: "• ",
          //             recognizer: recognizer,
          //             style: TextStyle(
          //                 fontSize: 15.0,
          //                 color: textColor,
          //                 fontStyle: textFontStyle,
          //                 fontWeight: textFontWeight,
          //                 decoration: decoration),
          //           ),
          //         ),
          //       ],
          //     ),
          //   );
          //   currentIndex = blockIndex;
          // }
          // list.add(
          //   RichText(
          //     text: TextSpan(
          //       text: String.fromCharCode(draftJsObject
          //           .blocks[blockIndex].text.runes
          //           .toList()[textIndex]),
          //       recognizer: recognizer,
          //       style: TextStyle(
          //           fontSize: fontSize,
          //           color: textColor,
          //           fontStyle: textFontStyle,
          //           fontWeight: textFontWeight,
          //           decoration: decoration),
          //     ),
          //   ),
          // );
          //}
          if (draftJsObject.blocks[blockIndex].type == "unordered-list-item" &&
              currentIndex != blockIndex) {
            list.add(Offstage(
              offstage: _offstage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    key: key,
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (context, size) {
                        _getWidgetHeight(key);
                        // final bottomPadding = boxConstraints.maxHeight / 2 - 5;
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: subtreeHeight),
                            child: Text(
                              "• ",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: textColor,
                                  fontStyle: textFontStyle,
                                  fontWeight: FontWeight.bold,
                                  decoration: decoration),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: RichText(
                      text: TextSpan(
                        text: text,
                        recognizer: recognizer,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          color: textColor,
                          fontStyle: textFontStyle,
                          fontWeight: textFontWeight,
                          decoration: decoration,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
          } else if (text.isNotEmpty) {
            list.add(
              Align(
                alignment: textAlign,
                child: RichText(
                  text: TextSpan(
                    text: text,
                    recognizer: recognizer,
                    style: TextStyle(
                        fontSize: widget.fontSize,
                        color: textColor,
                        fontStyle: textFontStyle,
                        fontWeight: textFontWeight,
                        decoration: decoration),
                  ),
                ),
              ),
            );
          } else {
            // list.add(SizedBox(
            //   height: 3,
            // ));
          }

          list.add(
            RichText(
                text: TextSpan(
              text: " \n",
            )),
          );
        }
      }
    }
    print(list.length);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final widgets = getTextSpans(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
