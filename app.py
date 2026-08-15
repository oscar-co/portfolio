from flask import Flask, render_template


app = Flask(__name__)

TECH_AREAS = [
    {
        "number": "01",
        "title": "E2E Automation",
        "description": "Reliable and maintainable coverage for critical user flows.",
        "skills": ["Playwright", "Selenium"],
    },
    {
        "number": "02",
        "title": "Backend / API",
        "description": "API testing, service isolation and backend validation.",
        "skills": [
            "Postman",
            "REST Assured",
            "JUnit",
            "Mockito",
            "MockMvc",
            "WireMock",
            "Pytest",
        ],
    },
    {
        "number": "03",
        "title": "DevOps",
        "description": "Quality checks integrated into the delivery workflow.",
        "skills": ["GitHub Actions", "Docker", "AWS", "Linux"],
    },
    {
        "number": "04",
        "title": "Quality Engineering",
        "description": "Practical test strategy, coverage and risk assessment.",
        "skills": ["Test Strategy", "Regression", "Smoke Testing", "Test Design"],
    },
    {
        "number": "05",
        "title": "Web Development",
        "description": "Junior-level full-stack development skills and experience.",
        "skills": ["Angular", "Spring Boot", "REST APIs", "HTML", "CSS"],
    },
]

PROJECTS = [
    {
        "index": "01",
        "title": "Playwright Automation Framework",
        "subtitle": "A scalable E2E framework for complex web applications.",
        "stack": ["Playwright", "TypeScript", "GitHub Actions"],
        "features": [
            "Page Object Model and custom fixtures",
            "Authentication with storageState",
            "API interception and isolated test data",
            "Parallel execution with traces, video and screenshots",
            "Smoke and regression suites in CI",
        ],
        "status": "In progress",
    },
    {
        "index": "02",
        "title": "API Testing with Pytest",
        "subtitle": "A Python API automation framework designed to be easy to extend.",
        "stack": ["Python", "Pytest", "REST APIs"],
        "features": [
            "Reusable fixtures and helpers",
            "Factories for test data generation",
            "Clear and consistent assertions",
            "Parameterized test cases",
            "Reports ready for continuous integration",
        ],
        "status": "Planned",
    },
]


@app.get("/")
def home() -> str:
    return render_template(
        "index.html",
        tech_areas=TECH_AREAS,
        projects=PROJECTS,
    )


if __name__ == "__main__":
    app.run(debug=True)
