rm dictionary.db
sqlite3 dictionary.db -cmd '.read 01.create_tables.sql' '.read 02.hsk1.sql' '.read 03.hsk2.sql' '.read 04.hsk3.sql' '.read 05.hsk4.sql' '.read 06.hsk5.sql' '.read 07.more_words.sql' '.read 08.translations.sql'
sqlite3 dictionary.db