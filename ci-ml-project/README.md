# Projekt CI-ML

Ten projekt demonstruje pełny pipeline CI/CD dla modelu ML w GitHub Actions. 🚀

## 🧩 Continuous Integration – GitHub Actions

Workflow **CI-ML**:
- uruchamia się automatycznie na push, PR lub manualnie,
- instaluje zależności z plików `requirements*.txt`,
- wykonuje lint (flake8) i format check (black),
- uruchamia testy pytest,
- trenuje model ML (Logistic Regression),
- publikuje model jako artefakt (`model-dev` / `model-prod`),
- korzysta z Variables i Secrets repozytorium.

## Autor
Imię i nazwisko (tu wpisz swoje)

## Cel
Tworzenie i uruchamianie pipeline CI dla projektu Python ML.
