CREATE VIRTUAL TABLE dictionary_entry_translation_fts USING fts5(hanzi_simplified, pinyin_ascii, pinyin_numeric, portuguese_translation, content='');

INSERT INTO
    dictionary_entry_translation_fts(rowid, hanzi_simplified, pinyin_ascii, pinyin_numeric, portuguese_translation)
SELECT
    dictionary_entries.dictionary_entry_id, hanzi_simplified, pinyin_ascii, pinyin_numeric, portuguese_translation
FROM
    dictionary_entries
INNER JOIN
    translations on dictionary_entries.dictionary_entry_id = translations.dictionary_entry_id;
