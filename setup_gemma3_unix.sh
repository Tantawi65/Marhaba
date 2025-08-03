#!/bin/bash

echo "================================================"
echo "    Marhaba App - Gemma 3 Setup for macOS/Linux"
echo "================================================"
echo

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "ERROR: Ollama is not installed or not in PATH"
    echo
    echo "Please install Ollama first:"
    echo "macOS: brew install ollama"
    echo "Linux: curl -fsSL https://ollama.ai/install.sh | sh"
    echo "Or visit: https://ollama.ai/download"
    echo
    exit 1
fi

echo "✓ Ollama is installed"
echo

# Start Ollama service
echo "Starting Ollama service..."
ollama serve &
OLLAMA_PID=$!
sleep 3

# Check if Gemma 3 model is available
if ollama list | grep -q "gemma:3b"; then
    echo "✓ Gemma 3 model is already installed"
else
    echo "Gemma 3 model not found. Downloading now..."
    echo "This may take several minutes (approximately 2GB download)"
    echo
    
    if ! ollama pull gemma:3b; then
        echo "ERROR: Failed to download Gemma 3 model"
        echo "Please check your internet connection and try again"
        kill $OLLAMA_PID 2>/dev/null
        exit 1
    fi
    
    echo "✓ Gemma 3 model downloaded successfully"
fi

# Test the model
echo
echo "Testing Gemma 3 model..."
echo
if echo "Hello, how can you help refugees?" | ollama run gemma:3b; then
    echo "✓ Model test successful"
else
    echo "WARNING: Model test failed, but installation appears complete"
fi

echo
echo "================================================"
echo "           Setup Complete!"
echo "================================================"
echo
echo "Gemma 3 is now ready for the Marhaba app."
echo "You can now launch the Flutter app."
echo
echo "The app will work completely offline once this setup is complete."
echo

# Keep Ollama running
echo "Ollama will continue running in the background."
echo "Press Ctrl+C to stop this script, but leave Ollama running."
echo

wait $OLLAMA_PID
