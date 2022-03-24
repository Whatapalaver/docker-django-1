from django.conf.urls import include, url
from rest_framework import routers
from rest_framework.documentation import include_docs_urls

from tutorial.quickstart import views

router = routers.DefaultRouter()
router.register(r"users", views.UserViewSet)
router.register(r"groups", views.GroupViewSet)

# Wire up our API using automatic URL routing.
# Additionally, we include login URLs for the browsable API.
urlpatterns = [
    url(r"^", include(router.urls)),
    url(r"^api-auth/", include("rest_framework.urls", namespace="rest_framework")),
    url(r"^docs/", include_docs_urls(title="My API title", public=False)),
]
