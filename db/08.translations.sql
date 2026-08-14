INSERT INTO translations(dictionary_entry_id, portuguese_translation, grammatical_class, usage_notes) VALUES
(98, 'água', 'noun', NULL), -- 水
(128, 'estudar, aprender', 'verb', 'Para indicar que o aprendizado está concluído e o conteúdo aprendido, use [学会].'), -- 学习
(33, 'trabalho', 'noun', NULL),
(33, 'trabalhar', 'verb', 'É mais comum se usar [上班] para o verbo "trabalhar".'), -- 工作
(50, 'olhar, assistir', 'verb', NULL), -- 看
(2502, 'ler', 'verb', 'Usado apenas para livros. Para ler outros materiais, use outros verbos.'), -- 看书
(49, 'abrir', 'verb', NULL), -- 开
(49, 'ligar, operar', 'verb', NULL),
(2501, 'bater, quebrar', 'verb', NULL), -- 打
(13, 'fazer um telefonema', 'verb', NULL), -- 打电话
(166, 'fazer um telefonema', 'verb', NULL), -- 打篮球
(120, 'pensar', 'verb', 'Usado para indicar que você está pensando sobre algo. Para expressar opiniões, use [觉得].'), -- 想
(120, 'querer, desejar algo', 'verb', 'Se quer ser mais enfático, use [想要] ou [要].'),
(120, 'sentir saudades', 'verb', NULL),
(43, 'saber fazer, conseguir fazer algo', 'verb', 'Usado apenas para habilidades aprendidas. Para expressar a capacidade de fazer algo (como terminar a refeição, ou chegar a tempo na reunião), use [能].'), -- 会
(43, 'indica que algo acontecerá no futuro', 'adverb', NULL),
(55, 'indica que uma ação está completa', 'particle', 'A ação deve ser completável, como [买], [吃] ou [问]. Para ações não-completáveis, use [已经].'), -- 了
(55, 'indica uma mudança de situação', 'particle', NULL),
(200, 'quando precedido de uma suposição, indica uma conclusão (se...então...)', 'adverb', NULL), -- 就
(200, 'indica que uma ação será feita imediatamente, ou logo após uma outra', 'adverb', NULL)
;

INSERT INTO examples(translation_id, example_portuguese, example_hanzi_simplified, example_pinyin, example_pinyin_ascii, example_pinyin_numeric) VALUES
(2, 'Estudar chinês', '学习中文', 'xuéxí zhōngwén', 'xuexi zhongwen', 'xue2xi2 zhong1wen2')
;