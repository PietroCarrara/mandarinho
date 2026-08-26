import re

import pkuseg
from pypinyin import TONE3, pinyin

seg = pkuseg.pkuseg()


def compute_pinyin(text):
    # TODO: Use this to label part of speech as well? https://github.com/lancopku/pkuseg-python/blob/master/tags.txt
    words = seg.cut(text)
    result = ""
    for word in words:
        # Get first reading of each word.
        # HACK: Is this correct? I don't know the order in which the lib returns them
        pinyin_parts = list(map(lambda readings: readings[0],
                                pinyin(word, style=TONE3, neutral_tone_with_five=True)))

        pinyin_parts = list(map(monospace_to_ascii, pinyin_parts))

        # Sometimes, numbers or foreign words get grouped together with other characters (eg. seg('现在8点') -> ['现在','8点'])
        # Then we'll do map(['现在','8点']) -> [['xian4', 'zai4'], ['8', 'dian3']]. Here, pinyin_parts would be = ['8', 'dian3'].
        # When generating pinyin for these edge cases, we should add a space in between the foreign characters (which will be
        # converted 1:1) and the actual pinyin
        pinyin_parts = list(map(space_for_edge_case, enumerate(pinyin_parts)))

        pinyin_numeric = "".join(pinyin_parts)
        space = " " if result != "" and pinyin_numeric not in [
            '!', '.', '?', '?', ',', ')'] and result[-1] not in ['('] else ""
        result += space + pinyin_numeric

    return result


def space_for_edge_case(index_and_pinyin_part):
    index, pinyin_part = index_and_pinyin_part
    # No tonal mark? Foreign word!
    if pinyin_part not in ['!', '.', '?', ';', ',', ':', '(', ')', '"'] and pinyin_part[-1] not in ['1', '2', '3', '4', '5']:
        if index == 0:
            return pinyin_part + " "
        else:
            return " " + pinyin_part

    return pinyin_part


def monospace_to_ascii(string: str):
    return string.replace("！", "!")\
                 .replace("。", ".")\
                 .replace("？", "?")\
                 .replace("；", ";")\
                 .replace("，", ",")\
                 .replace("、", ",")\
                 .replace("：", ":")\
                 .replace("（", "(")\
                 .replace("）", ")")\
                 .replace("“", '"')\
                 .replace("”", '"')


compute_pinyin("（兴奋）你和我们一起来吧！（不开心）好吧")
