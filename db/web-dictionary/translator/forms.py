from django import forms
from django.forms import inlineformset_factory

from .models import DictionaryEntry, Example, Translation


PARTS_OF_SPEECH = [
    ("", "---------"),
    ("verb", "Verb"),
    ("noun", "Noun"),
    ("adjective", "Adjective"),
    ("adverb", "Adverb"),
    ("particle", "Particle"),
    ("expression", "Expression"),
    ("number", "Number"),
]


class DictionaryEntryForm(forms.ModelForm):
    class Meta:
        model = DictionaryEntry
        fields = ["simplified_hanzi", "pinyin_numeric"]


class TranslationForm(forms.ModelForm):
    class Meta:
        model = Translation
        fields = ["portuguese", "part_of_speech"]
        widgets = {"part_of_speech": forms.Select(choices=PARTS_OF_SPEECH)}


class ExampleForm(forms.ModelForm):
    class Meta:
        model = Example
        fields = ["hanzi_simplified", "portuguese"]


TranslationFormSet = inlineformset_factory(
    DictionaryEntry, Translation, form=TranslationForm, extra=1, can_delete=False
)

ExampleFormSet = inlineformset_factory(
    Translation, Example, form=ExampleForm, extra=2, can_delete=False
)
