CREATE TABLE dictionary_entries (
    dictionary_entry_id INTEGER PRIMARY KEY,
    hanzi_simplified TEXT NOT NULL,
    pinyin TEXT NOT NULL,
    pinyin_ascii TEXT NOT NULL,
    pinyin_numeric TEXT NOT NULL,
    hsk INTEGER
);


CREATE INDEX dictionary_entries_hanzi_simplified_index ON dictionary_entries (hanzi_simplified);
CREATE INDEX dictionary_entries_pinyin_index ON dictionary_entries (pinyin);
CREATE INDEX dictionary_entries_pinyin_ascii_index ON dictionary_entries (pinyin_ascii);
CREATE INDEX dictionary_entries_pinyin_numeric_index ON dictionary_entries (pinyin_numeric);


CREATE TABLE translations (
    translation_id INTEGER PRIMARY KEY,
    dictionary_entry_id INTEGER NOT NULL,
    portuguese_translation TEXT NOT NULL,
    grammatical_class TEXT NOT NULL CHECK(grammatical_class in ('verb', 'noun', 'adjective', 'adverb', 'particle', 'expression')),
    usage_notes TEXT,
    FOREIGN KEY(dictionary_entry_id) REFERENCES dictionary_entries(dictionary_entry_id)
);

CREATE INDEX translations_portuguese_translation_index ON translations (portuguese_translation);


CREATE TABLE examples (
    example_id INTEGER PRIMARY KEY,
    translation_id INTEGER NOT NULL,
    example_portuguese TEXT NOT NULL,
    example_hanzi_simplified TEXT NOT NULL,
    example_pinyin TEXT NOT NULL,
    example_pinyin_ascii TEXT NOT NULL,
    example_pinyin_numeric TEXT NOT NULL,
    FOREIGN KEY(translation_id) REFERENCES translations(translation_id)
)

-- INSERT INTO dictionary_entries(hanzi_simplified, pinyin, pinyin_numeric, pinyin_ascii) VALUES ('你好', 'nǐhǎo', 'ni3hao3', 'nihao');
-- INSERT INTO translations(dictionary_entry_id, portuguese) VALUES (1, 'Olá');
-- INSERT INTO translations(dictionary_entry_id, portuguese) VALUES (1, 'Tudo bem?');
