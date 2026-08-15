from data.models import TechArea


TECH_AREAS: tuple[TechArea, ...] = (
    TechArea(
        number="01",
        title="E2E Automation",
        description="Reliable and maintainable coverage for critical user flows.",
        skills=("Playwright", "Selenium"),
    ),
    TechArea(
        number="02",
        title="Backend / API",
        description="API testing, service isolation and backend validation.",
        skills=(
            "Postman",
            "REST Assured",
            "JUnit",
            "Mockito",
            "MockMvc",
            "WireMock",
            "Pytest",
        ),
    ),
    TechArea(
        number="03",
        title="DevOps",
        description="Quality checks integrated into the delivery workflow.",
        skills=("GitHub Actions", "Docker", "AWS", "Linux"),
    ),
    TechArea(
        number="04",
        title="Quality Engineering",
        description="Practical test strategy, coverage and risk assessment.",
        skills=("Test Strategy", "Regression", "Smoke Testing", "Test Design"),
    ),
    TechArea(
        number="05",
        title="Web Development",
        description="Junior-level full-stack development skills and experience.",
        skills=("Angular", "Spring Boot", "REST APIs", "HTML", "CSS"),
    ),
)
