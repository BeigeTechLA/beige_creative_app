.PHONY: build-dev build-dev-ios build-dev-android build-dev-aab \
        build-prod build-prod-ios build-prod-android build-prod-aab \
        upload-dev-android upload-prod-android upload-dev-ios upload-prod-ios \
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
	# Auto-upload to TestFlight disabled for now. Run `make upload-dev-ios` manually if needed.
	# $(MAKE) upload-dev-ios

build-dev-android:
	flutter clean && flutter pub get && \
	  flutter build apk --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release
	# Auto-upload to Firebase App Distribution disabled for now. Run `make upload-dev-android` manually if needed.
	# ./scripts/upload_firebase_android.sh dev build/app/outputs/flutter-apk/app-dev-release.apk

build-dev-aab:
	flutter clean && flutter pub get && \
	  flutter build appbundle --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release

build-prod:
	./scripts/build_prod.sh

build-prod-ios:
	flutter clean && flutter pub get && \
	  flutter build ipa --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release
	# Auto-upload to TestFlight disabled for now. Run `make upload-prod-ios` manually if needed.
	# $(MAKE) upload-prod-ios

build-prod-android:
	flutter clean && flutter pub get && \
	  flutter build apk --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release
	# Auto-upload to Firebase App Distribution disabled for now. Run `make upload-prod-android` manually if needed.
	# ./scripts/upload_firebase_android.sh prod build/app/outputs/flutter-apk/app-prod-release.apk

build-prod-aab:
	flutter clean && flutter pub get && \
	  flutter build appbundle --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release

upload-dev-android:
	./scripts/upload_firebase_android.sh dev build/app/outputs/flutter-apk/app-dev-release.apk

upload-prod-android:
	./scripts/upload_firebase_android.sh prod build/app/outputs/flutter-apk/app-prod-release.apk

upload-dev-ios:
	./scripts/upload_testflight.sh "$$(find build/ios/ipa -name '*.ipa' | head -n1)"

upload-prod-ios:
	./scripts/upload_testflight.sh "$$(find build/ios/ipa -name '*.ipa' | head -n1)"

clean:
	flutter clean

pub:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test
