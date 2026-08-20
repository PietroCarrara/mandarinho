from django.shortcuts import get_object_or_404, render

from .models import DictionaryEntry


def index(request):
    entries = DictionaryEntry.objects.order_by("simplified_hanzi")
    return render(request, "translator/index.html", {"entries": entries})


def edit(request, entry_id):
    entry = get_object_or_404(
        DictionaryEntry.objects.prefetch_related("translation_set__example_set"),
        pk=entry_id,
    )
    return render(request, "translator/edit.html", {"entry": entry})
