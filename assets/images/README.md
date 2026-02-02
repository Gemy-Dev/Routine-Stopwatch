# App Icon Setup Instructions

## Steps to Set Up Your Logo as App Icon:

1. **Save your logo image** to this directory (`assets/images/`) with the filename `app_icon.png`
   - Recommended size: 1024x1024 pixels (square)
   - Format: PNG with transparent background (if applicable)
   - The logo should be centered and have some padding around it

2. **Run the icon generator**:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **Rebuild your app** to see the new icons:
   ```bash
   flutter clean
   flutter build apk
   ```

## Notes:
- The `flutter_launcher_icons` package will automatically generate all required icon sizes for Android and iOS
- Make sure your logo image is square (1:1 aspect ratio) for best results
- The adaptive icon background is set to white - you can change this in `pubspec.yaml` if needed

