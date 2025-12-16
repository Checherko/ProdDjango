from django import forms
from django.forms.widgets import FileInput

from shopapp.models import Product


class MultipleFileInput(FileInput):
    def __init__(self, attrs=None):
        if attrs is None:
            attrs = {}
        attrs['multiple'] = 'multiple'
        super().__init__(attrs)

    def value_from_datadict(self, data, files, name):
        if hasattr(files, 'getlist'):
            return files.getlist(name)
        return files.get(name)


class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = "name", "price", "description", "discount", "preview"

    images = forms.ImageField(
        widget=MultipleFileInput(),
        required=False
    )


class CSVImportForm(forms.Form):
    csv_file = forms.FileField()
