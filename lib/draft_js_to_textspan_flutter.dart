library draft_js_to_textspan_flutter;

import 'package:draft_js_to_textspan_flutter/model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DraftJSFlutter extends StatelessWidget {
  final Map<String, dynamic> map;
  final double fontSize;
  Color color;
  DraftJSFlutter(this.map, this.fontSize, this.color);

  Color get getColor => color;
  set setColor(Color color) {
    this.color = color;
  }

  _launchURL(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  List<Widget> getTextSpans() {
    List<Widget> list = List();
    List<TextSpan> temporary = List();
    Color textColor = color;
    FontWeight textFontWeight;
    FontStyle textFontStyle;
    TextDecoration decoration;
    TapGestureRecognizer recognizer;
    if (map != null) {
      print(map);
      DraftJsObject draftJsObject = DraftJsObject.fromJson(map);
      int currentIndex = 0;
      if (draftJsObject != null && draftJsObject.blocks != null) {
        for (int blockIndex = 0;
            blockIndex < draftJsObject.blocks.length;
            blockIndex++) {
          String text = draftJsObject.blocks[blockIndex].text;
          // int textLength = draftJsObject.blocks[blockIndex].text != null
          //     ? draftJsObject.blocks[blockIndex].text.runes.length
          //     : 0;

          // for (int textIndex = 0; textIndex < textLength; textIndex++) {
          //   print('TextIndex: ' + textIndex.toString());
          textColor = color;
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
            list.add(Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Align(
                      alignment: Alignment.topCenter,
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
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: RichText(
                    text: TextSpan(
                      text: text,
                      recognizer: recognizer,
                      style: TextStyle(
                          fontSize: fontSize,
                          color: textColor,
                          fontStyle: textFontStyle,
                          fontWeight: textFontWeight,
                          decoration: decoration),
                    ),
                  ),
                ),
              ],
            ));
          } else {
            list.add(
              RichText(
                text: TextSpan(
                  text: text,
                  recognizer: recognizer,
                  style: TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                      fontStyle: textFontStyle,
                      fontWeight: textFontWeight,
                      decoration: decoration),
                ),
              ),
            );
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
    final widgets = getTextSpans();
    return Column(
      children: widgets,
    );
  }
}
