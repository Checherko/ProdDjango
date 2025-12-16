from django import forms
from django.forms.widgets import ClearableFileInput

from shopapp.models import Product


class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = "name", "price", "description", "discount", "preview"

    images = forms.ImageField(
        widget=ClearableFileInput(),
        required=False,
    )
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['images'].widget.attrs.update({'multiple': True})


class CSVImportForm(forms.Form):
    csv_file = forms.FileField()
