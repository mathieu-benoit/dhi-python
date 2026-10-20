# syntax=docker/dockerfile:1

## -----------------------------------------------------
## Build stage: use the '-dev' DHI variant, which includes pip and build tools
FROM dhi.io/python:3.14-debian13-dev AS build-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/app/venv/bin:$PATH"

WORKDIR /app

# Create a virtual environment and install dependencies into it
RUN python -m venv /app/venv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

## -----------------------------------------------------
## Final stage: use the minimal, hardened DHI runtime image
FROM dhi.io/python:3.14-debian13

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/app/venv/bin:$PATH"

WORKDIR /app

# Copy the virtual environment with installed dependencies from the build stage
COPY --from=build-stage /app/venv /app/venv

# Copy application code
COPY . .

# Expose the port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]