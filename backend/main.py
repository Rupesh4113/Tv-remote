"""
RemoteOne Backend API Application
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.routes import router

app = FastAPI(
    title="RemoteOne Device Profile & Sync API",
    description="Open-source device profile catalog and local-first backup service for RemoteOne",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.get("/")
def root():
    return {
        "app": "RemoteOne",
        "description": "Universal TV & Set-Top Box Remote API",
        "docs": "/docs",
        "health": "/api/v1/health",
        "status": "ready"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
