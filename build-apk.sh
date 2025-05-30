#!/bin/bash

echo "🚀 Building EA Matrix APK..."

# First, let's build the web assets
echo "📦 Building web application..."
npm run build

# Create a simplified mobile app structure
echo "📱 Creating mobile app structure..."
mkdir -p ea-matrix-mobile/app/src/main/{java/com/eamatrix,assets/www,res/drawable}

# Copy the built web assets
echo "📂 Copying web assets..."
cp -r dist/* ea-matrix-mobile/app/src/main/assets/www/

# Create Android manifest
cat > ea-matrix-mobile/app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.eamatrix.trading">
    
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    
    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="EA Matrix"
        android:theme="@style/AppTheme">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/AppTheme.NoActionBar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# Create MainActivity
cat > ea-matrix-mobile/app/src/main/java/com/eamatrix/MainActivity.java << 'EOF'
package com.eamatrix;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings;

public class MainActivity extends Activity {
    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        webView = new WebView(this);
        setContentView(webView);
        
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setAllowFileAccess(true);
        
        webView.setWebViewClient(new WebViewClient());
        webView.loadUrl("file:///android_asset/www/index.html");
    }
    
    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
EOF

# Create basic Gradle build files
echo "🔧 Creating build configuration..."
mkdir -p ea-matrix-mobile/app

cat > ea-matrix-mobile/build.gradle << 'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.0.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

cat > ea-matrix-mobile/app/build.gradle << 'EOF'
apply plugin: 'com.android.application'

android {
    compileSdkVersion 30
    defaultConfig {
        applicationId "com.eamatrix.trading"
        minSdkVersion 21
        targetSdkVersion 30
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
        }
    }
}
EOF

# Copy app icon
cp generated-icon.png ea-matrix-mobile/app/src/main/res/drawable/ic_launcher.png

echo "✅ Mobile app structure created!"
echo "📱 To build the APK, you'll need Android Studio or the Android SDK installed locally."
echo "📁 The mobile app files are ready in: ea-matrix-mobile/"

# Create installation instructions
cat > MOBILE_BUILD_INSTRUCTIONS.md << 'EOF'
# EA Matrix Mobile App Build Instructions

## Option 1: Using Android Studio
1. Open Android Studio
2. Open the `ea-matrix-mobile` folder as a project
3. Wait for Gradle sync to complete
4. Click Build > Build Bundle(s) / APK(s) > Build APK(s)
5. The APK will be generated in `app/build/outputs/apk/`

## Option 2: Using Command Line (requires Android SDK)
```bash
cd ea-matrix-mobile
./gradlew assembleRelease
```

## Option 3: Online Build Service
Upload the `ea-matrix-mobile` folder to an online Android build service like:
- BuildBot
- Bitrise
- GitHub Actions with Android workflow

## APK Location
After building, find your APK at:
`ea-matrix-mobile/app/build/outputs/apk/release/app-release.apk`
EOF

echo "📋 Build instructions created: MOBILE_BUILD_INSTRUCTIONS.md"