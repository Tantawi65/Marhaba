# Marhaba App - Gemma 3 Offline Setup Guide

This guide will help you set up Gemma 3 model with Ollama to run the Marhaba app completely offline.

## Prerequisites

1. **Install Ollama** (if not already installed):
   - Visit: https://ollama.ai/download
   - Download and install Ollama for your operating system
   - Make sure Ollama is running in the background

## Setting up Gemma 3 Model

### Option 1: Automatic Setup (Recommended)
The app will automatically attempt to download Gemma 3 when you first run it. This may take some time depending on your internet connection.

### Option 2: Manual Setup
If automatic setup doesn't work, you can manually install the model:

1. **Open Command Prompt/Terminal**
2. **Pull Gemma 3 model:**
   ```bash
   ollama pull gemma:3b
   ```
   
   This will download approximately 2GB of data. Ensure you have:
   - Stable internet connection for download
   - At least 4GB of free disk space
   - At least 8GB of RAM for optimal performance

3. **Verify installation:**
   ```bash
   ollama list
   ```
   You should see `gemma:3b` in the list.

4. **Test the model:**
   ```bash
   ollama run gemma:3b "Hello, how can you help refugees?"
   ```

## Offline Usage

Once Gemma 3 is installed:

1. **Make sure Ollama is running:**
   - On Windows: Ollama should start automatically after installation
   - On macOS/Linux: Run `ollama serve` if needed

2. **Launch the Marhaba app:**
   - The app will automatically detect if Gemma 3 is available
   - Green indicator = Gemma 3 is ready
   - Red indicator = Using offline fallback responses

3. **Fully Offline Operation:**
   - Once Gemma 3 is downloaded, the app works completely offline
   - No internet connection required for AI responses
   - All processing happens locally on your device

## Troubleshooting

### Gemma 3 Not Detected
- Ensure Ollama service is running
- Verify the model is installed: `ollama list`
- Restart the Marhaba app
- Check app logs for error messages

### Performance Issues
- Ensure you have at least 8GB RAM
- Close other memory-intensive applications
- Consider using `gemma:2b` for devices with limited RAM:
  ```bash
  ollama pull gemma:2b
  ```

### Model Download Issues
- Check internet connection
- Ensure sufficient disk space
- Try downloading during off-peak hours
- Use `ollama pull gemma:3b --insecure` if needed

## System Requirements

### Minimum Requirements:
- 4GB RAM (8GB recommended)
- 4GB free disk space
- 64-bit operating system

### Optimal Performance:
- 16GB RAM or more
- SSD storage
- Modern multi-core processor

## Security & Privacy

✅ **Fully Private**: All conversations stay on your device  
✅ **No Data Sent**: Nothing is transmitted to external servers  
✅ **Offline First**: Works without internet connection  
✅ **Local Processing**: All AI responses generated locally  

## Support

If you encounter issues:

1. Check Ollama is running: Visit http://localhost:11434 in your browser
2. Verify model installation: `ollama list`
3. Restart both Ollama and the Marhaba app
4. Check system requirements are met

For additional help, consult the Ollama documentation: https://github.com/jmorganca/ollama
