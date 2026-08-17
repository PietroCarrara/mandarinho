import 'package:flutter/material.dart';
import 'package:mandarinho/components/pinyin.dart';

class Hanzi extends StatelessWidget {
  final String hanzi;
  final String pinyinNumeric;
  final TextStyle? style;

  const Hanzi({
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

    final zipped = _zip(chars, tones);

    final widgets = zipped
        .map((zip) => Text(zip.$1, style: toneStyles[zip.$2 - 1].merge(style)))
        .toList();

    return Wrap(children: widgets);
  }

  static List<(T, U)> _zip<T, U>(List<T> it1, List<U> it2) {
    assert(it1.length == it2.length);

    return List.generate(it1.length, (i) {
      return (it1[i], it2[i]);
    });
  }
}
