from fastapi import FastAPI


app = FastAPI(
    title="Mi portfolio",
    description="Portfolio personal creado con FastAPI.",
    version="0.1.0",
)


@app.get("/")
def home() -> dict[str, str]:
    return {"message": "¡Mi portfolio con FastAPI está funcionando!"}
