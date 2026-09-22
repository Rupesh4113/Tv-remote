# Deploying RemoteOne as a Streamlit App

RemoteOne provides a complete, responsive **Streamlit Web Remote** application deployable to **Streamlit Community Cloud** (100% free, zero-server management, automated GitHub CI sync).

---

## 1. What the Streamlit App Provides

- **📱 Mobile Web Remote**: A realistic handheld remote interface with Power, Volume/Channel rockers, 5-way D-Pad, numeric keypad, color buttons, and smart app shortcuts.
- **📡 Device Profiles Library**: Searchable catalog of 17+ Indian DTH Set-Top Boxes (Tata Play, Airtel, Dish TV, etc.) and Smart TVs with raw HEX codes and timing specs.
- **🔬 IR Waveform Analyzer**: Interactive Plotly visualizer rendering microsecond pulse trains, carrier frequencies, mark/space intervals, and duty cycles.
- **🎙️ Voice & Macro Studio**: Natural language voice query parser and multi-device sequential automation macros.
- **📥 Android APK Download Portal**: Direct download link to `app-release.apk` from GitHub Releases with a scannable QR code for smartphones.

---

## 2. Running Locally

To test the Streamlit app on your local computer:

```bash
# 1. Install required dependencies
pip install -r requirements.txt

# 2. Launch the Streamlit Web Remote
streamlit run streamlit_app.py
```

The app will open automatically in your browser at `http://localhost:8501`.

---

## 3. One-Click Free Deployment on Streamlit Community Cloud

You can deploy this application publicly on [Streamlit Community Cloud](https://share.streamlit.io) for free:

### Step 1: Log in to Streamlit
1. Visit **[share.streamlit.io](https://share.streamlit.io)**.
2. Sign in with your **GitHub account** (`Rupesh4113`).

### Step 2: Create a New App
1. Click the **"New app"** button in the top right.
2. Fill in the repository details:
   - **Repository:** `Rupesh4113/Tv-remote`
   - **Branch:** `main`
   - **Main file path:** `streamlit_app.py` (or `app.py`)
   - **App URL (optional):** Choose a custom subdomain (e.g. `remoteone.streamlit.app`)

### Step 3: Click Deploy!
1. Click **"Deploy!"**.
2. Streamlit Cloud will read `requirements.txt`, install dependencies, and launch your live Universal Web Remote in ~60 seconds.

---

## 4. Using from Mobile Devices

Once deployed:
1. Open the public Streamlit URL on your smartphone browser (e.g. Chrome, Safari).
2. Tap **Add to Home Screen** in your mobile browser menu to run it in standalone fullscreen mode like a native app.
3. Switch between TV and Set-Top Box modes, trigger smart TV apps, and inspect real-time transmission event logs.
