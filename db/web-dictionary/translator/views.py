from django.db import transaction
from django.shortcuts import get_object_or_404, redirect, render

from translator.pinyin import compute_pinyin

from .forms import (
    CreateExampleFormSet,
    CreateTranslationFormSet,
    CreateDictionaryEntryForm,
    EditDictionaryEntryForm,
    EditExampleFormSet,
    EditTranslationFormSet,
    NewEditExampleFormSet,
    TranslationForm,
)
from .models import DictionaryEntry


def index(request):
    entries = DictionaryEntry.objects.order_by("simplified_hanzi")
    return render(request, "translator/index.html", {"entries": entries})


def _entry_form_view(request, entry, template_name, *, is_create):
    translation_formset_class = (
        CreateTranslationFormSet if is_create else EditTranslationFormSet
    )
    example_formset_class = (
        CreateExampleFormSet if is_create else EditExampleFormSet
    )
    new_example_formset_class = (
        CreateExampleFormSet if is_create else NewEditExampleFormSet
    )
    entry_form_class = (
        CreateDictionaryEntryForm if is_create else EditDictionaryEntryForm
    )
    entry_form = entry_form_class(request.POST or None, instance=entry)
    translation_formset = translation_formset_class(
        request.POST or None, instance=entry, prefix="translations"
    )

    example_formsets = []
    for index, translation_form in enumerate(translation_formset.forms):
        example_formset = example_formset_class(
            request.POST or None,
            instance=translation_form.instance,
            prefix=f"examples-{index}",
        )
        translation_form.example_formset = example_formset
        example_formsets.append(example_formset)

    if request.method == "POST":
        entry_is_valid = entry_form.is_valid()
        translations_are_valid = translation_formset.is_valid()
        examples_are_valid = all(
            [formset.is_valid() for formset in example_formsets]
        )
        if entry_is_valid and translations_are_valid and examples_are_valid:
            with transaction.atomic():
                entry = entry_form.save(commit=False)
                if is_create:
                    entry.pinyin_numeric = compute_pinyin(
                        entry.simplified_hanzi)
                entry.save()
                for translation_form, example_formset in zip(
                    translation_formset.forms, example_formsets
                ):
                    if (
                        not translation_form.instance.pk
                        and not translation_form.has_changed()
                    ):
                        continue
                    translation = translation_form.save(commit=False)
                    translation.entry = entry
                    translation.save()
                    example_formset.instance = translation
                    examples = example_formset.save(commit=False)
                    for example in examples:
                        example.entry = translation
                        if is_create:
                            example.pinyin = compute_pinyin(
                                example.hanzi_simplified
                            )
                        example.save()
            return redirect("translator:edit", entry_id=entry.pk)

    empty_translation_form = TranslationForm(
        prefix="translations-__translation_prefix__"
    )
    empty_example_formset = new_example_formset_class(
        instance=empty_translation_form.instance,
        prefix="examples-__translation_prefix__",
    )

    return render(
        request,
        template_name,
        {
            "entry": entry,
            "entry_form": entry_form,
            "translation_formset": translation_formset,
            "empty_translation_form": empty_translation_form,
            "empty_example_formset": empty_example_formset,
        },
    )


def create(request):
    return _entry_form_view(
        request, DictionaryEntry(), "translator/create.html", is_create=True
    )


def edit(request, entry_id):
    entry = get_object_or_404(
        DictionaryEntry.objects.prefetch_related(
            "translation_set__example_set"),
        pk=entry_id,
    )
    return _entry_form_view(
        request, entry, "translator/edit.html", is_create=False
    )
