# Cloud Deployment & Mobile Installation Guide

This guide details how to deploy **RemoteOne** to free, open-source cloud hosts and download or run the mobile application directly on your phone.

---

## Option 1: Download the Native Android APK via GitHub Releases

Every push to your GitHub repository triggers GitHub Actions to automatically compile the native Android APK using [`android-build.yml`](../.github/workflows/android-build.yml).

### Steps to Download to Phone:
1. Push your code to GitHub:
   ```bash
   git push origin main
   ```
2. Navigate to your GitHub repository in your phone or PC browser:
   `https://github.com/Rupesh4113/Tv-remote/releases`
3. Download `app-release.apk` directly onto your Android device.
4. Open the `.apk` file on your phone and tap **Install**.

---

## Option 2: 1-Click Free Cloud Deployment on Render

Render offers a 100% free web service tier with automated Docker deployment and an automatic HTTPS domain.

### Steps to Deploy:
1. Sign up or log into [Render.com](https://render.com) (free account).
2. Click **New +** -> **Blueprint** or **Web Service**.
3. Select your GitHub repository: `Rupesh4113/Tv-remote`.
4. Render will automatically detect [`render.yaml`](../render.yaml) and Dockerfile.
5. Click **Apply / Deploy**.
6. Once deployed, Render will provide a free public URL (e.g. `https://remoteone.onrender.com`).

### Using from your Mobile Phone:
1. Open `https://remoteone.onrender.com` on your mobile browser (Chrome / Safari).
2. You will see the **RemoteOne Web Remote** interface.
3. Click the **⬇ APK** button to download the native application.
4. Or tap your mobile browser menu (three dots in Chrome, or Share button in Safari) -> **"Add to Home screen"**. The app will install as a standalone PWA with its own home screen icon!

---

## Option 3: Free Deployment on Hugging Face Spaces

Hugging Face Spaces provides permanent free container hosting.

### Steps to Deploy:
1. Log in to [Hugging Face](https://huggingface.co/) and click **New Space**.
2. Space SDK: Select **Docker** (Blank).
3. Connect your GitHub repository or push the repository files.
4. Your remote web application and APK download portal will be live at:
   `https://huggingface.co/spaces/<your-username>/remoteone`

---

## Option 4: Instant Local LAN Deployment with QR Code

You can run the web portal locally on your PC and access it from any phone on the same Wi-Fi network:

1. Start the server on your computer:
   ```bash
   uvicorn backend.main:app --host 0.0.0.0 --port 8000
   ```
2. Find your computer's local IP address (e.g. `192.168.1.15`).
3. Open `http://<your-ip>:8000` on your PC.
4. Click the **📷 QR** button in the top right corner.
5. Scan the QR code with your phone camera to instantly open RemoteOne on your mobile phone!
