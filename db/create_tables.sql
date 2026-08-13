CREATE TABLE dictionary_entries (
    dictionary_entry_id INTEGER PRIMARY KEY,
    hanzi_simplified TEXT NOT NULL,
    pinyin TEXT NOT NULL,
    pinyin_ascii TEXT NOT NULL,
    pinyin_numeric TEXT NOT NULL,
    hsk INTEGER
);

CREATE TABLE translations (
    translation_id INTEGER PRIMARY KEY,
    dictionary_entry_id INTEGER,
    portuguese TEXT,
    FOREIGN KEY(dictionary_entry_id) REFERENCES dictionary_entries(dictionary_entry_id)
);

INSERT INTO dictionary_entries(hanzi_simplified, pinyin, pinyin_numeric, pinyin_ascii) VALUES ('你好', 'nǐhǎo', 'ni3hao3', 'nihao');
INSERT INTO translations(dictionary_entry_id, portuguese) VALUES (1, 'Olá');
INSERT INTO translations(dictionary_entry_id, portuguese) VALUES (1, 'Tudo bem?');
