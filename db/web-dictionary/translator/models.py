from django.db import models


class DictionaryEntry(models.Model):
    id = models.AutoField(primary_key=True)
    simplified_hanzi = models.TextField()
    pinyin_numeric = models.TextField()


class Translation(models.Model):
    entry = models.ForeignKey(DictionaryEntry, on_delete=models.CASCADE)
    id = models.AutoField(primary_key=True)
    portuguese = models.TextField()
    part_of_speech = models.TextField()
    translation_notes = models.TextField(null=True)

    class Meta:
        constraints = [
            models.CheckConstraint(
                condition=models.Q(part_of_speech__in=[
                                   'verb', 'noun', 'adjective', 'adverb', 'particle', 'expression', 'number', 'classifier']),
                name='part_of_speech_must_be_in_allowed_list',
            )
        ]


class Example(models.Model):
    entry = models.ForeignKey(Translation, on_delete=models.CASCADE)
    id = models.AutoField(primary_key=True)
    portuguese = models.TextField()
    hanzi_simplified = models.TextField()
    pinyin = models.TextField()
