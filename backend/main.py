"""
RemoteOne Backend API & Mobile Web Remote Portal
"""

from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from .api.routes import router

STATIC_DIR = Path(__file__).resolve().parent / "static"
APK_PATH = Path(__file__).resolve().parent.parent / "mobile" / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
GITHUB_RELEASE_APK_URL = "https://github.com/Rupesh4113/Tv-remote/releases/latest/download/app-release.apk"

app = FastAPI(
    title="RemoteOne Device Profile & Web Remote API",
    description="Open-source universal remote control application and device profile catalog",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if STATIC_DIR.exists():
    app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

app.include_router(router)


@app.get("/")
def web_remote():
    """Serves the Mobile Web Remote interface directly on phone browsers."""
    index_file = STATIC_DIR / "index.html"
    if index_file.exists():
        return FileResponse(str(index_file))
    return {
        "app": "RemoteOne",
        "description": "Universal TV & Set-Top Box Remote API",
        "docs": "/docs",
        "health": "/api/v1/health",
        "status": "ready"
    }


@app.get("/download/apk")
def download_apk():
    """
    Downloads the compiled Android APK directly to the phone.
    Falls back to GitHub Release binary if not yet built locally.
    """
    if APK_PATH.exists():
        return FileResponse(
            str(APK_PATH),
            media_type="application/vnd.android.package-archive",
            filename="RemoteOne-Universal-Remote.apk"
        )
    return RedirectResponse(url=GITHUB_RELEASE_APK_URL)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
