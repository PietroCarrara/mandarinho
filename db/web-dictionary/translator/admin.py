from django.contrib import admin

from translator.models import DictionaryEntry, Example, Translation

admin.site.register(DictionaryEntry)
admin.site.register(Translation)
admin.site.register(Example)
