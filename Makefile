APP_NAME    := FloatRec
BUILD_DIR   := build
BUNDLE      := $(BUILD_DIR)/$(APP_NAME).app
INSTALL_DIR := /Applications

SDK     := $(shell xcrun --show-sdk-path)
TARGET  := arm64-apple-macosx14.0
SOURCES := FloatRec/FloatRecApp.swift \
           FloatRec/Helpers/FloatingPanel.swift \
           FloatRec/Views/FloatingPanelView.swift \
           FloatRec/Views/SettingsPopoverView.swift \
           FloatRec/Models/RecordingState.swift \
           FloatRec/Models/RecordingSettings.swift \
           FloatRec/Services/ScreenRecorder.swift

.PHONY: build install uninstall clean run icon

icon:
	@mkdir -p $(BUILD_DIR)/AppIcon.iconset
	@swift Scripts/generate_icon.swift $(BUILD_DIR)/icon_1024.png
	@sips -z 16 16     $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_16x16.png      >/dev/null 2>&1
	@sips -z 32 32     $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_16x16@2x.png   >/dev/null 2>&1
	@sips -z 32 32     $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_32x32.png      >/dev/null 2>&1
	@sips -z 64 64     $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_32x32@2x.png   >/dev/null 2>&1
	@sips -z 128 128   $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_128x128.png    >/dev/null 2>&1
	@sips -z 256 256   $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_128x128@2x.png >/dev/null 2>&1
	@sips -z 256 256   $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_256x256.png    >/dev/null 2>&1
	@sips -z 512 512   $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_256x256@2x.png >/dev/null 2>&1
	@sips -z 512 512   $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_512x512.png    >/dev/null 2>&1
	@sips -z 1024 1024 $(BUILD_DIR)/icon_1024.png --out $(BUILD_DIR)/AppIcon.iconset/icon_512x512@2x.png >/dev/null 2>&1
	@iconutil -c icns $(BUILD_DIR)/AppIcon.iconset -o $(BUILD_DIR)/AppIcon.icns

build: icon
	@rm -rf $(BUNDLE)
	@mkdir -p $(BUNDLE)/Contents/MacOS
	@mkdir -p $(BUNDLE)/Contents/Resources
	@swiftc -target $(TARGET) -sdk $(SDK) -swift-version 5 -O \
		-o $(BUNDLE)/Contents/MacOS/$(APP_NAME) $(SOURCES)
	@cp FloatRec/Info.plist $(BUNDLE)/Contents/Info.plist
	@sed -i '' \
		-e 's/$$(PRODUCT_BUNDLE_IDENTIFIER)/com.floatrec.app/g' \
		-e 's/$$(EXECUTABLE_NAME)/$(APP_NAME)/g' \
		-e 's/$$(MACOSX_DEPLOYMENT_TARGET)/14.0/g' \
		-e 's/$$(CURRENT_PROJECT_VERSION)/1/g' \
		-e 's/$$(MARKETING_VERSION)/1.0/g' \
		$(BUNDLE)/Contents/Info.plist
	@echo -n "APPL????" > $(BUNDLE)/Contents/PkgInfo
	@cp $(BUILD_DIR)/AppIcon.icns $(BUNDLE)/Contents/Resources/AppIcon.icns
	@codesign --force --sign - $(BUNDLE)
	@echo "Built: $(BUNDLE)"

install: build
	@cp -R $(BUNDLE) $(INSTALL_DIR)/
	@echo "Installed to $(INSTALL_DIR)/$(APP_NAME).app"

uninstall:
	@rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	@echo "Uninstalled $(APP_NAME)"

run: build
	@open $(BUNDLE)

clean:
	@rm -rf $(BUILD_DIR)
