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


class BootstrapFormMixin:
    """Apply Bootstrap's standard controls to Django-generated fields."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            if isinstance(field.widget, forms.CheckboxInput):
                continue
            css_class = "form-select" if isinstance(field.widget, forms.Select) else "form-control"
            field.widget.attrs["class"] = css_class


class CreateDictionaryEntryForm(BootstrapFormMixin, forms.ModelForm):
    class Meta:
        model = DictionaryEntry
        fields = ["simplified_hanzi", "hsk"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["hsk"].required = False


class EditDictionaryEntryForm(BootstrapFormMixin, forms.ModelForm):
    class Meta:
        model = DictionaryEntry
        fields = ["simplified_hanzi", "pinyin_numeric", "hsk"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["pinyin_numeric"].required = False
        self.fields["hsk"].required = False


class TranslationForm(BootstrapFormMixin, forms.ModelForm):
    class Meta:
        model = Translation
        fields = ["portuguese", "part_of_speech", "translation_notes"]
        widgets = {"part_of_speech": forms.Select(choices=PARTS_OF_SPEECH)}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["translation_notes"].required = False


class CreateExampleForm(BootstrapFormMixin, forms.ModelForm):
    class Meta:
        model = Example
        fields = ["hanzi_simplified", "portuguese"]


class EditExampleForm(BootstrapFormMixin, forms.ModelForm):
    class Meta:
        model = Example
        fields = ["hanzi_simplified", "pinyin", "portuguese"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["pinyin"].required = False


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
