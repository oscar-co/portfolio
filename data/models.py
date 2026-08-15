from dataclasses import dataclass


@dataclass(frozen=True)
class Project:
    index: str
    title: str
    subtitle: str
    stack: tuple[str, ...]
    features: tuple[str, ...]
    status: str


@dataclass(frozen=True)
class TechArea:
    number: str
    title: str
    description: str
    skills: tuple[str, ...]


@dataclass(frozen=True)
class Experience:
    period: str
    role: str
    company: str
    location: str
    highlights: tuple[str, ...]
