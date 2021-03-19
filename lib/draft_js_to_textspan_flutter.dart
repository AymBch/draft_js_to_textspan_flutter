library draft_js_to_textspan_flutter;

import 'package:draft_js_to_textspan_flutter/model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DraftJSFlutter extends StatelessWidget {
  final Map<String, dynamic> map;
  final double fontSize;
  DraftJSFlutter(this.map, this.fontSize);

  _launchURL(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  List<TextSpan> getTextSpans() {
    List<TextSpan> list = List();
    if (map != null) {
      DraftJsObject draftJsObject = DraftJsObject.fromJson(map);
      if (draftJsObject != null && draftJsObject.blocks != null) {
        for (int blockIndex = 0;
            blockIndex < draftJsObject.blocks.length;
            blockIndex++) {
          int textLength = draftJsObject.blocks[blockIndex].text != null
              ? draftJsObject.blocks[blockIndex].text.runes.length
              : 0;
          print('bloc index' + blockIndex.toString());
          print('text length:' + textLength.toString());

          for (int textIndex = 0; textIndex < textLength; textIndex++) {
            print('TextIndex: ' + textIndex.toString());
            Color textColor = Colors.black;
            FontWeight textFontWeight = FontWeight.w400;
            FontStyle textFontStyle = FontStyle.normal;
            TextDecoration decoration = TextDecoration.none;
            TapGestureRecognizer recognizer;
            for (int inlineStyleIndex = 0;
                inlineStyleIndex <
                    draftJsObject.blocks[blockIndex].inlineStyleRanges.length;
                inlineStyleIndex++) {
              if (draftJsObject
                  .blocks[blockIndex].inlineStyleRanges[inlineStyleIndex]
                  .contains(textIndex)) {
                print('inlineStyleIndex : ' + inlineStyleIndex.toString());
                print('inilneStyleRange : ' +
                    draftJsObject
                        .blocks[blockIndex].inlineStyleRanges[inlineStyleIndex]
                        .toString());
                print(draftJsObject.blocks[blockIndex]
                    .inlineStyleRanges[inlineStyleIndex].style);
                switch (draftJsObject.blocks[blockIndex]
                    .inlineStyleRanges[inlineStyleIndex].style) {
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
                }
              }
            }

            for (int entityRangeIndex = 0;
                entityRangeIndex <
                    draftJsObject.blocks[blockIndex].entityRanges.length;
                entityRangeIndex++) {
              if (draftJsObject
                  .blocks[blockIndex].entityRanges[entityRangeIndex]
                  .contains(textIndex)) {
                print('entityRangeIndex : ' + entityRangeIndex.toString());
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
              }
            }
            print('text to add :' +
                String.fromCharCode(draftJsObject.blocks[blockIndex].text.runes
                    .toList()[textIndex]));
            list.add(
              TextSpan(
                text: String.fromCharCode(draftJsObject
                    .blocks[blockIndex].text.runes
                    .toList()[textIndex]),
                recognizer: recognizer,
                style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontStyle: textFontStyle,
                    fontWeight: textFontWeight,
                    decoration: decoration),
              ),
            );
          }
          print('block key:' + draftJsObject.blocks[blockIndex].key);
          print('add the new line');
          list.add(TextSpan(
            text: " \n",
          ));
          // add bullet points .........................................
          final style = draftJsObject.blocks[blockIndex].type;
          print('style type : ' + style.toString());
          print('bloc object : ' + draftJsObject.blocks[blockIndex].toString());
          if (draftJsObject.blocks[blockIndex].type == "unordered-list-item") {
            print('bullet');
            print('bullet block : ' +
                draftJsObject.blocks[blockIndex].toString());
            list.add(TextSpan(
              text: "•",
            ));
          }

          // ------------------------------------------------------------
        }
      }
    }
    print(list.length);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: []..addAll(getTextSpans())));
  }
}
