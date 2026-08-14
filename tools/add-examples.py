import sqlite3

import jieba
import pandas as pd

# 333595
# 404978
# 4311079
choose_translation_id_cache = {
    '1409093+会': 16,
    '333595+工作': 3,
    '29+想': 14,
    '472590+工作': 3,
    '2879114+会': 16,
    '404978+会': 16,
    '404978+想': 12,
    '336939+想': 13,
    '344260+会': 16,
    '798184+会': 15,
    '1778255+会': 16,
    '771656+工作': 4,
    '505639+想': 13,
    '868084+想': 13,
    '811843+会': 15,
    '332869+工作': 4,
    '344133+想': 13,
    '697642+会': 15,
    '334915+会': 16,
    '407231+工作': 3,
    '881547+会': 16,
    '892413+想': 13,
    '1020700+想': 12,
    '1227124+会': 16,
    '687038+想': 13,
    '903615+想': 13,
    '332892+会': 16,
    '1455143+想': 13,
    '973034+会': 15,
    '1193313+想': 13,
    '1962854+想': 13,
    '332715+会': 15,
    '1446885+想': 13,
    '2029298+想': 13,
    '775831+会': 16,
    '2684992+工作': 4,
    '2734408+想': 12,
    '1314214+工作': 4,
    '851482+想': 13,
    '421010+会': 15,
    '4563232+想': 13,
    '4913693+想': 13,
    '4906172+想': 13,
    '4934629+工作': 3,
    '1083545+会': 15,
    '847898+工作': 3,
    '419672+想': 13,
    '4813387+会': 16,
    '4311079+会': 16,
    '4972585+想': 13,
    '5414471+工作': 4,
    '4970143+会': 16,
    '4970134+会': 16,
    '4970094+工作': 4,
    '5551032+想': 13,
    '5968189+会': 15,
    '6677955+想': 13,
    '6677978+会': 16,
    '9953323+想': 13,
    '9958558+想': 13,
    '9963202+想': 13,
    '9965537+会': 16,
    '9968742+工作': 3,
    '10325721+想': 13,
    '10478499+会': 15,
    '1883018+会': 16,
    '4265116+想': 13,
    '11825657+会': 16,
    '10966720+想': 12,
    '9992070+想': 13,
    '12278090+想': 13,
    '12278139+想': 13,
    '12278310+想': 13,
    '12278314+想': 13,
    '10260768+想': 13,
    '1579952+想': 13,
    '1780716+想': 13,
}


def choose_translation_index(cn_id, cn, word, translations):
    key = f"{cn_id}+{word}"
    if key in choose_translation_id_cache:
        cached_translation_id = choose_translation_id_cache[key]
        return next((i for i, translation in enumerate(translations) if translation[0] == cached_translation_id), None)

    print(f"Choose a translation for {word} in {cn}:")
    for i, (_, text, grammatical_class) in enumerate(translations):
        print(f"  {i}: {text} ({grammatical_class})")

    while True:
        try:
            index = int(input("Translation index: "))
            if 0 <= index < len(translations):
                choose_translation_id_cache[key] = translations[index][0]
                return index
        except ValueError:
            pass
        print(f"Enter an index from 0 to {len(translations) - 1}.")


db = sqlite3.connect("../db/dictionary.db")
csv = pd.read_csv('pt-cn.csv', header=None)
try:
    for row in csv.itertuples(index=False):
        _, pt, cn_id, cn, pinyin, pinyin_ascii, pinyin_numeric = row
        words = jieba.lcut(cn, HMM=False)
        for word in words:
            # Skip some basic chinese stop words:
            if word in ['了', '就', '开']:
                continue

            translations = db.execute("""
                SELECT t.translation_id, t.portuguese_translation, t.grammatical_class
                FROM dictionary_entries de
                INNER JOIN translations t ON de.dictionary_entry_id = t.dictionary_entry_id
                WHERE de.hanzi_simplified = ?;
            """, [word]).fetchall()

            if len(translations) > 0:
                index = 0
                if len(translations) > 1:
                    index = choose_translation_index(
                        cn_id, cn, word, translations)
                translation_id, portuguese_translation, grammatical_class = translations[index]

                db.execute("""
                    INSERT INTO examples (translation_id, example_portuguese, example_hanzi_simplified, example_pinyin, example_pinyin_ascii, example_pinyin_numeric)
                    VALUES (?, ?, ?, ?, ?, ?);
                """, [translation_id, pt, cn, pinyin, pinyin_ascii, pinyin_numeric])
                db.commit()

finally:
    print("choose_translation_id_cache = {")
    for cn_id, translation_id in choose_translation_id_cache.items():
        print(f"    {cn_id!r}: {translation_id!r},")
    print("}")
    db.close()
