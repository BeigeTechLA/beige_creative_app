.PHONY: build-dev build-dev-ios build-dev-android build-dev-aab \
        build-prod build-prod-ios build-prod-android build-prod-aab \
        run-dev run-prod clean pub analyze test

DEV_ENV  := env/dev.json
PROD_ENV := env/prod.json

run-dev:
	flutter run --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart

run-prod:
	flutter run --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart

build-dev:
	./scripts/build_dev.sh

build-dev-ios:
	flutter clean && flutter pub get && \
	  flutter build ipa --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release

build-dev-android:
	flutter clean && flutter pub get && \
	  flutter build apk --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release

build-dev-aab:
	flutter clean && flutter pub get && \
	  flutter build appbundle --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release

build-prod:
	./scripts/build_prod.sh

build-prod-ios:
	flutter clean && flutter pub get && \
	  flutter build ipa --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release

build-prod-android:
	flutter clean && flutter pub get && \
	  flutter build apk --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release

build-prod-aab:
	flutter clean && flutter pub get && \
	  flutter build appbundle --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release

clean:
	flutter clean

pub:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test
