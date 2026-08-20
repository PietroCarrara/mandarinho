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
    ("classifier", "Classifier"),
]


class CreateDictionaryEntryForm(forms.ModelForm):
    class Meta:
        model = DictionaryEntry
        fields = ["simplified_hanzi"]


class EditDictionaryEntryForm(forms.ModelForm):
    class Meta:
        model = DictionaryEntry
        fields = ["simplified_hanzi", "pinyin_numeric"]


class TranslationForm(forms.ModelForm):
    class Meta:
        model = Translation
        fields = ["portuguese", "part_of_speech"]
        widgets = {"part_of_speech": forms.Select(choices=PARTS_OF_SPEECH)}


class CreateExampleForm(forms.ModelForm):
    class Meta:
        model = Example
        fields = ["hanzi_simplified", "portuguese"]


class EditExampleForm(forms.ModelForm):
    class Meta:
        model = Example
        fields = ["hanzi_simplified", "pinyin", "portuguese"]


CreateTranslationFormSet = inlineformset_factory(
    DictionaryEntry, Translation, form=TranslationForm, extra=1, can_delete=False
)

EditTranslationFormSet = inlineformset_factory(
    DictionaryEntry, Translation, form=TranslationForm, extra=0, can_delete=False
)

CreateExampleFormSet = inlineformset_factory(
    Translation, Example, form=CreateExampleForm, extra=2, can_delete=False
)

EditExampleFormSet = inlineformset_factory(
    Translation, Example, form=EditExampleForm, extra=0, can_delete=False
)

NewEditExampleFormSet = inlineformset_factory(
    Translation, Example, form=EditExampleForm, extra=2, can_delete=False
)
