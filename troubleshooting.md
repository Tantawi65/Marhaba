# Marhaba Troubleshooting Guide

## Common Issues and Solutions

### 🔴 Gemma 3 Not Detected

**Symptoms:**
- App shows "Offline Mode" indicator
- Voice responses use fallback instead of AI

**Solutions:**
1. **Check Ollama Service:**
   ```bash
   # Test if Ollama is running
   curl http://localhost:11434/api/tags
   ```

2. **Verify Model Installation:**
   ```bash
   ollama list
   ```
   Should show `gemma:3b` in the list

3. **Restart Services:**
   ```bash
   # Stop Ollama
   pkill ollama
   
   # Start Ollama
   ollama serve
   
   # Restart the Marhaba app
   ```

4. **Re-pull Model:**
   ```bash
   ollama pull gemma:3b
   ```

### 🔴 Performance Issues

**Symptoms:**
- Slow AI responses
- App freezing or crashing
- High memory usage

**Solutions:**
1. **Check System Resources:**
   - Ensure 8GB+ RAM available
   - Close other memory-intensive apps
   - Monitor CPU usage

2. **Use Lighter Model (if needed):**
   ```bash
   ollama pull gemma:2b
   ```
   Then update `ollama_service.dart`:
   ```dart
   static const String _model = 'gemma:2b';
   ```

3. **Optimize Ollama Settings:**
   ```bash
   # Reduce context window for better performance
   ollama run gemma:3b --num-ctx 1024
   ```

### 🔴 Voice Recognition Not Working

**Symptoms:**
- Microphone permission denied
- No speech detected
- Speech recognition errors

**Solutions:**
1. **Check Permissions:**
   - Android: Settings > Apps > Marhaba > Permissions > Microphone
   - iOS: Settings > Privacy > Microphone > Marhaba

2. **Test Microphone:**
   - Try other voice apps
   - Check system audio settings
   - Ensure microphone is not muted

3. **Restart App:**
   - Close and reopen Marhaba
   - Grant permissions when prompted

### 🔴 Text-to-Speech Issues

**Symptoms:**
- No audio output
- Robotic or unclear speech
- TTS errors in logs

**Solutions:**
1. **Check System TTS:**
   - Android: Settings > Accessibility > Text-to-speech
   - iOS: Settings > Accessibility > Spoken Content
   - Windows: Settings > Time & Language > Speech

2. **Install TTS Voices:**
   - Download additional language packs
   - Ensure English (US) voice is installed

3. **Adjust TTS Settings:**
   - Lower speech rate if unclear
   - Increase volume if too quiet

### 🔴 Model Download Issues

**Symptoms:**
- Download fails or times out
- Insufficient disk space errors
- Network connectivity issues

**Solutions:**
1. **Check Internet Connection:**
   ```bash
   ping ollama.ai
   ```

2. **Free Disk Space:**
   - Ensure 4GB+ free space
   - Clean temporary files
   - Move other files if needed

3. **Resume Download:**
   ```bash
   # Try downloading again
   ollama pull gemma:3b
   
   # Or use insecure flag if SSL issues
   ollama pull gemma:3b --insecure
   ```

4. **Alternative Download:**
   - Try downloading during off-peak hours
   - Use a different network if available

### 🔴 App Crashes or Errors

**Symptoms:**
- App closes unexpectedly
- Flutter errors in console
- Unresponsive UI

**Solutions:**
1. **Check Flutter Version:**
   ```bash
   flutter --version
   ```
   Ensure version 3.3.0 or higher

2. **Clean and Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Check Dependencies:**
   ```bash
   flutter pub deps
   ```

4. **View Logs:**
   ```bash
   flutter logs
   ```

## 📊 System Diagnostics

### Check All Components:

```bash
# 1. Flutter
flutter doctor

# 2. Ollama
ollama --version

# 3. Models
ollama list

# 4. Ollama API
curl http://localhost:11434/api/tags

# 5. Test AI
ollama run gemma:3b "test message"
```

## 🆘 Still Need Help?

If you're still experiencing issues:

1. **Check System Requirements:**
   - RAM: 8GB+ recommended
   - Storage: 4GB+ free space
   - OS: Recent version supported

2. **Update Everything:**
   - Update Flutter SDK
   - Update Ollama
   - Update the Marhaba app

3. **Reset Configuration:**
   - Uninstall and reinstall Ollama
   - Re-pull the Gemma 3 model
   - Clear app data and restart

4. **Alternative Solutions:**
   - Use the app in offline-only mode
   - Try a different AI model
   - Contact support with logs

## 📝 Reporting Issues

When reporting problems, please include:
- Operating system and version
- RAM and storage available
- Flutter version (`flutter --version`)
- Ollama version (`ollama --version`)
- Error messages or logs
- Steps to reproduce the issue

This helps us provide better support and improve the app for everyone!
