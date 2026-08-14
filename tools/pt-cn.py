# Go to https://tatoeba.org/pt-br/downloads and download pt-cn.tsv (from pt to zh)
import re

import pandas as pd
import chinese_converter
import jieba
from pypinyin import pinyin as get_pinyin, Style


def simplify(row):
    row[3] = chinese_converter\
        .to_simplified(row[3])\
        .replace("什麽", "什么")\
        .replace("夢", "梦")
    return row


def filter_out(row):
    pt_id, pt, _, cn = row

    # Tatoeba warning sentence
    if pt_id == 375073:
        return 'Tatoeba warning sentence'

    # Chinese text with ascii characters: presence of some foreign language.
    if bool(re.search(r"[a-zA-Z]+", cn)):
        return 'foreign language'

    if len(cn) <= 3:
        return 'too short'

    # Repeated phrase
    # TODO: Maybe in the future we could keep phrases which have their chinese and portuguese parts exactly the same, keeping just one copy.
    # Maybe for other cases we could interactively display the offenders and ask for input about which one to keep
    if (phrases[1] == pt).sum() >= 2 or (phrases[3] == cn).sum() >= 2:
        return 'repeated'

    return 0


def preprocess_pinyin(text, style):
    words = jieba.lcut(text, HMM=False)
    result = ""
    for word in words:
        # Get first reading of each word.
        # HACK: Is this correct? I don't know the order in which the lib returns them
        pinyin = "".join(
            list(map(lambda readings: readings[0], get_pinyin(word, style=style))))

        space = " " if pinyin not in [
            '!', '.', '?', '?', '。', '？', '！'] and result != "" else ""
        result += space + pinyin

    return result


def pinyin(style):
    return lambda row: preprocess_pinyin(row[3], style)


phrases = pd.read_csv('pt-cn.tsv', sep='\t', header=None)
phrases = phrases.apply(simplify, axis=1)
phrases['filter_reason'] = phrases.apply(filter_out, axis=1)
phrases = phrases[phrases['filter_reason'] == 0].drop(columns='filter_reason')
phrases['pinyin'] = phrases.apply(pinyin(Style.TONE), axis=1)
phrases['pinyin_ascii'] = phrases.apply(pinyin(Style.NORMAL), axis=1)
phrases['pinyin_numeric'] = phrases.apply(pinyin(Style.TONE3), axis=1)
phrases.to_csv('pt-cn.csv', index=False, header=False)
