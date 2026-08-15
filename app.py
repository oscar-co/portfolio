from flask import Flask, render_template

from data.experience import EXPERIENCE
from data.projects import PROJECTS
from data.skills import TECH_AREAS


app = Flask(__name__)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/")
def home() -> str:
    return render_template(
        "index.html",
        experience=EXPERIENCE,
        tech_areas=TECH_AREAS,
        projects=PROJECTS,
    )


if __name__ == "__main__":
    app.run(debug=True)
