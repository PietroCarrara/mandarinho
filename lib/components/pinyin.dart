import 'package:flutter/material.dart';

class PinyinStyle extends ThemeExtension<PinyinStyle> {
  final Color tone1Color;
  final Color tone2Color;
  final Color tone3Color;
  final Color tone4Color;
  final Color tone5Color;

  PinyinStyle({
    required this.tone1Color,
    required this.tone2Color,
    required this.tone3Color,
    required this.tone4Color,
    required this.tone5Color,
  });

  @override
  ThemeExtension<PinyinStyle> copyWith({
    Color? tone1Color,
    Color? tone2Color,
    Color? tone3Color,
    Color? tone4Color,
    Color? tone5Color,
  }) {
    return PinyinStyle(
      tone1Color: tone1Color ?? this.tone1Color,
      tone2Color: tone2Color ?? this.tone2Color,
      tone3Color: tone3Color ?? this.tone3Color,
      tone4Color: tone4Color ?? this.tone4Color,
      tone5Color: tone5Color ?? this.tone5Color,
    );
  }

  @override
  ThemeExtension<PinyinStyle> lerp(
    covariant ThemeExtension<PinyinStyle>? other,
    double t,
  ) {
    if (other is! PinyinStyle) {
      return this;
    }

    return PinyinStyle(
      tone1Color: Color.lerp(tone1Color, other.tone1Color, t) ?? tone1Color,
      tone2Color: Color.lerp(tone2Color, other.tone2Color, t) ?? tone2Color,
      tone3Color: Color.lerp(tone3Color, other.tone3Color, t) ?? tone3Color,
      tone4Color: Color.lerp(tone4Color, other.tone4Color, t) ?? tone4Color,
      tone5Color: Color.lerp(tone5Color, other.tone5Color, t) ?? tone5Color,
    );
  }
}

class Pinyin extends StatelessWidget {
  static final regExp = RegExp(r'([a-zü]+[1-5])');

  final String pinyinNumeric;
  final TextStyle? style;

  const Pinyin({super.key, required this.pinyinNumeric, this.style});

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

    final words = pinyinNumeric.split(" ");
    final wordsSplitBySyllables = words
        .map(
          (word) =>
              regExp.allMatches(word).map((match) => match.group(0)!).toList(),
        )
        .toList();
    final wordsSplitBySyllablesTonal = wordsSplitBySyllables
        .map((syllables) => fromNumericSyllablesToTonal(syllables))
        .toList();

    final widgets = wordsSplitBySyllablesTonal
        .expand(
          (syllables) => syllables.map(
            ((syllable) => Text(
              syllable.pinyinTonal,
              style: toneStyles[syllable.tone - 1].merge(style),
            )),
          ),
        )
        .toList();

    return Row(children: widgets);
  }

  static List<PinyinSyllable> fromNumericSyllablesToTonal(
    List<String> numerics,
  ) {
    return numerics.map((numeric) {
      numeric = numeric.replaceAll('v', 'ü');

      final tone = int.parse(
        numeric[numeric.length - 1],
      ); // Get last character (tonal number indicator)
      final toneless = numeric.substring(
        0,
        numeric.length - 1,
      ); // Remove last character

      if (toneless.contains('a')) {
        final toned = toneless.replaceFirst('a', addTone('a', tone));

        return PinyinSyllable(
          pinyinNumeric: numeric,
          pinyinTonal: toned,
          tone: tone,
        );
      } else if (toneless.contains('e')) {
        final toned = toneless.replaceFirst('e', addTone('e', tone));

        return PinyinSyllable(
          pinyinNumeric: numeric,
          pinyinTonal: toned,
          tone: tone,
        );
      } else if (toneless.contains('ou')) {
        final toned = toneless.replaceFirst('ou', '${addTone('o', tone)}u');

        return PinyinSyllable(
          pinyinNumeric: numeric,
          pinyinTonal: toned,
          tone: tone,
        );
      } else {
        final vowelsIndexes = [
          ('i', toneless.lastIndexOf('i')),
          ('o', toneless.lastIndexOf('o')),
          ('u', toneless.lastIndexOf('u')),
          ('ü', toneless.lastIndexOf('ü')),
        ];
        vowelsIndexes.sort((a, b) => a.$2 - b.$2);
        final (lastVowel, lastVowelIndex) =
            vowelsIndexes[vowelsIndexes.length - 1];
        final toned = toneless.replaceRange(
          lastVowelIndex,
          lastVowelIndex + 1,
          addTone(lastVowel, tone),
        );

        return PinyinSyllable(
          pinyinNumeric: numeric,
          pinyinTonal: toned,
          tone: tone,
        );
      }
    }).toList();
  }

  static String addTone(String toneless, int tone) {
    return switch ((toneless, tone)) {
      ('a', 1) => 'ā',
      ('a', 2) => 'á',
      ('a', 3) => 'ǎ',
      ('a', 4) => 'à',
      ('a', 5) => 'a',

      ('e', 1) => 'ē',
      ('e', 2) => 'é',
      ('e', 3) => 'ě',
      ('e', 4) => 'è',
      ('e', 5) => 'e',

      ('i', 1) => 'ī',
      ('i', 2) => 'í',
      ('i', 3) => 'ǐ',
      ('i', 4) => 'ì',
      ('i', 5) => 'i',

      ('o', 1) => 'ō',
      ('o', 2) => 'ó',
      ('o', 3) => 'ǒ',
      ('o', 4) => 'ò',
      ('o', 5) => 'o',

      ('u', 1) => 'ū',
      ('u', 2) => 'ú',
      ('u', 3) => 'ǔ',
      ('u', 4) => 'ù',
      ('u', 5) => 'u',

      ('ü', 1) => 'ǖ',
      ('ü', 2) => 'ǘ',
      ('ü', 3) => 'ǚ',
      ('ü', 4) => 'ǜ',
      ('ü', 5) => 'ü',

      (_, _) => throw 'invalid pinyin',
    };
  }
}

class PinyinSyllable {
  final String pinyinNumeric;
  final String pinyinTonal;
  final int tone;

  PinyinSyllable({
    required this.pinyinNumeric,
    required this.pinyinTonal,
    required this.tone,
  });
}
