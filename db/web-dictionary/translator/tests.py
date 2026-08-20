from django.test import TestCase
from django.urls import reverse

from .models import DictionaryEntry, Example, Translation


class EditViewTests(TestCase):
    def setUp(self):
        self.entry = DictionaryEntry.objects.create(
            simplified_hanzi="你好", pinyin_numeric="ni3 hao3"
        )

    def test_edit_page_has_no_extra_forms(self):
        response = self.client.get(
            reverse("translator:edit", args=[self.entry.pk])
        )

        self.assertEqual(response.status_code, 200)
        self.assertIn("pinyin_numeric", response.context["entry_form"].fields)
        translation_formset = response.context["translation_formset"]
        self.assertEqual(translation_formset.total_form_count(), 0)

    def test_edit_page_only_shows_examples_from_database(self):
        translation = Translation.objects.create(
            entry=self.entry,
            portuguese="olá",
            part_of_speech="expression",
        )
        Example.objects.create(
            entry=translation,
            hanzi_simplified="你好！",
            pinyin="ni3 hao3",
            portuguese="Olá!",
        )
        Example.objects.create(
            entry=translation,
            hanzi_simplified="你好吗？",
            pinyin="ni3 hao3 ma5",
            portuguese="Como você está?",
        )

        response = self.client.get(
            reverse("translator:edit", args=[self.entry.pk])
        )

        translation_formset = response.context["translation_formset"]
        self.assertEqual(translation_formset.total_form_count(), 1)
        self.assertEqual(
            translation_formset.forms[0].example_formset.total_form_count(), 2
        )
        self.assertIn(
            "pinyin", translation_formset.forms[0].example_formset.forms[0].fields
        )

    def test_post_saves_a_translation_and_its_examples(self):
        response = self.client.post(
            reverse("translator:edit", args=[self.entry.pk]),
            {
                "simplified_hanzi": "您好",
                "pinyin_numeric": "nin2 hao3",
                "translations-TOTAL_FORMS": "1",
                "translations-INITIAL_FORMS": "0",
                "translations-MIN_NUM_FORMS": "0",
                "translations-MAX_NUM_FORMS": "1000",
                "translations-0-portuguese": "olá",
                "translations-0-part_of_speech": "expression",
                "examples-0-TOTAL_FORMS": "3",
                "examples-0-INITIAL_FORMS": "0",
                "examples-0-MIN_NUM_FORMS": "0",
                "examples-0-MAX_NUM_FORMS": "1000",
                "examples-0-0-hanzi_simplified": "您好！",
                "examples-0-0-pinyin": "nin2 hao3",
                "examples-0-0-portuguese": "Olá!",
                "examples-0-1-hanzi_simplified": "",
                "examples-0-1-pinyin": "",
                "examples-0-1-portuguese": "",
                "examples-0-2-hanzi_simplified": "你好吗？",
                "examples-0-2-pinyin": "ni3 hao3 ma5",
                "examples-0-2-portuguese": "Como você está?",
            },
        )

        self.assertRedirects(
            response, reverse("translator:edit", args=[self.entry.pk])
        )
        self.entry.refresh_from_db()
        self.assertEqual(self.entry.simplified_hanzi, "您好")
        translation = Translation.objects.get(entry=self.entry)
        self.assertEqual(translation.portuguese, "olá")
        self.assertEqual(Example.objects.filter(entry=translation).count(), 2)


class CreateViewTests(TestCase):
    def test_create_page_has_default_extra_forms(self):
        response = self.client.get(reverse("translator:create"))

        self.assertEqual(response.status_code, 200)
        translation_formset = response.context["translation_formset"]
        self.assertEqual(translation_formset.total_form_count(), 1)
        self.assertEqual(
            translation_formset.forms[0].example_formset.total_form_count(), 2
        )
        self.assertNotIn("pinyin_numeric", response.context["entry_form"].fields)
        self.assertNotIn(
            "pinyin", translation_formset.forms[0].example_formset.forms[0].fields
        )

    def test_post_creates_entry_translation_and_example(self):
        response = self.client.post(
            reverse("translator:create"),
            {
                "simplified_hanzi": "谢谢",
                "pinyin_numeric": "this submitted value must be ignored",
                "translations-TOTAL_FORMS": "1",
                "translations-INITIAL_FORMS": "0",
                "translations-MIN_NUM_FORMS": "0",
                "translations-MAX_NUM_FORMS": "1000",
                "translations-0-portuguese": "obrigado",
                "translations-0-part_of_speech": "expression",
                "examples-0-TOTAL_FORMS": "2",
                "examples-0-INITIAL_FORMS": "0",
                "examples-0-MIN_NUM_FORMS": "0",
                "examples-0-MAX_NUM_FORMS": "1000",
                "examples-0-0-hanzi_simplified": "谢谢你。",
                "examples-0-0-portuguese": "Obrigado.",
                "examples-0-1-hanzi_simplified": "",
                "examples-0-1-portuguese": "",
            },
        )

        entry = DictionaryEntry.objects.get(simplified_hanzi="谢谢")
        self.assertRedirects(
            response, reverse("translator:edit", args=[entry.pk])
        )
        self.assertEqual(entry.pinyin_numeric, "")
        translation = Translation.objects.get(entry=entry)
        self.assertEqual(translation.portuguese, "obrigado")
        self.assertEqual(Example.objects.filter(entry=translation).count(), 1)
        self.assertEqual(Example.objects.get(entry=translation).pinyin, "")
