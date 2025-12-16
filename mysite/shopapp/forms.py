from django import forms
from django.forms.widgets import ClearableFileInput

from shopapp.models import Product


class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = "name", "price", "description", "discount", "preview"

    images = forms.ImageField(
        widget=forms.FileInput(),
        required=False,
    )


class CSVImportForm(forms.Form):
    csv_file = forms.FileField()
