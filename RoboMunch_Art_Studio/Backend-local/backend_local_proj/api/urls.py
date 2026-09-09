from django.urls import path
from .views import (
    chat_with_munch, 
    paint_image, 
)

urlpatterns = [
    path('chat', chat_with_munch, name='chat_with_munch'),
    path('paint', paint_image, name='paint_image'),
]