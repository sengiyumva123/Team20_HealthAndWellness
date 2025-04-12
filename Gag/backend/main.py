from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import dreams, audio, health
from database import engine, Base

app = FastAPI(title="Dream Journal API", version="1.0")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create database tables
Base.metadata.create_all(bind=engine)

# Include routers
app.include_router(dreams.router, prefix="/api/dreams", tags=["dreams"])
app.include_router(audio.router, prefix="/api/audio", tags=["audio"])
app.include_router(health.router, prefix="/api/health", tags=["health"])

@app.get("/")
def read_root():
    return {"message": "Dream Journal API"}