CREATE TABLE dictionary_entries (
    id INTEGER PRIMARY KEY,
    hanzi TEXT NOT NULL,
    pinyin TEXT NOT NULL
);

CREATE TABLE translations (
    id INTEGER PRIMARY KEY,
    dictionary_entry_id INTEGER,
    portuguese TEXT,
    FOREIGN KEY(dictionary_entry_id) REFERENCES dictionary_entries(id)
);

INSERT INTO dictionary_entries(hanzi, pinyin) VALUES ('你好', 'nǐhǎo');
INSERT INTO translations(dictionary_entry_id, portuguese) VALUES (1, 'Olá');
INSERT INTO translations(dictionary_entry_id, portuguese) VALUES (1, 'Tudo bem?');
