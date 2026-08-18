import 'package:flutter/material.dart';
import 'package:mandarinho/components/pinyin.dart';

class Hanzi extends StatelessWidget {
  final String hanzi;
  final String pinyinNumeric;
  final TextStyle baseStyle = TextStyle(fontFamily: 'NotoSerifSC');
  final TextStyle? style;

  Hanzi({
    super.key,
    required this.pinyinNumeric,
    required this.hanzi,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final pinyinStyle = Theme.of(context).extension<PinyinStyle>()!;
    final toneStyles = [
      TextStyle(color: pinyinStyle.tone1Color),
      TextStyle(color: pinyinStyle.tone2Color),
      TextStyle(color: pinyinStyle.tone3Color),
      TextStyle(color: pinyinStyle.tone4Color),
      TextStyle(color: pinyinStyle.tone5Color),
    ];

    final chars = hanzi.split('');
    final tones = PinyinWordExtensions.wordsFromNumeric(pinyinNumeric)
        .expand((syllables) => syllables.map((syllable) => syllable.tone))
        .toList();

    final List<(String, int?)> charactersAndTones = [];
    final nonHanziChars = RegExp(r"[ .!,?()。！，？（）]");
    var toneCounter = 0;
    for (final char in chars) {
      if (nonHanziChars.hasMatch(char)) {
        charactersAndTones.add((char, null));
      } else {
        charactersAndTones.add((char, tones[toneCounter]));
        toneCounter++;
      }
    }

    return Text.rich(
      TextSpan(
        style: baseStyle.merge(style),
        children: charactersAndTones.map((cm) {
          final (char, tone) = cm;
          return TextSpan(
            text: char,
            style: tone != null ? toneStyles[tone - 1] : null,
          );
        }).toList(),
      ),
    );
  }
}
