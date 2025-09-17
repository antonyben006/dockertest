# Use official Python runtime as base image
FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Create a simple requirements.txt if none exists
RUN echo "flask==2.3.3" > requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create a simple app.py if none exists
RUN echo 'from flask import Flask, jsonify\n\
app = Flask(__name__)\n\
\n\
@app.route("/")\n\
def home():\n\
    return jsonify({"message": "Hello World", "status": "running"})\n\
\n\
@app.route("/health")\n\
def health():\n\
    return jsonify({"status": "healthy"}), 200\n\
\n\
if __name__ == "__main__":\n\
    app.run(host="0.0.0.0", port=8000, debug=False)' > app.py

# Copy any existing project files (this will overwrite the defaults above)
COPY . .

# Install from requirements.txt if it exists in the project
RUN if [ -f "requirements.txt" ]; then pip install --no-cache-dir -r requirements.txt; fi

# Create non-root user
RUN adduser --disabled-password --gecos '' --uid 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Run the application
CMD ["python", "app.py"]
