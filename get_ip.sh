#!/bin/bash

# Script to automatically get local IP
echo "🔍 Searching for local IP..."

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    echo "📍 Local IP: $IP"
    echo "🌐 Server URL: http://$IP:8080"
    echo ""
    echo "📝 Update frontend/lib/config/api_config.dart:"
    echo "   static String get _developmentBaseUrl => 'http://$IP:8080';"
    echo ""
    echo "🚀 To run the server:"
    echo "   cd server && dart run bin/telegram_server.dart"
    echo ""
    echo "📱 To run the Flutter app:"
    echo "   cd frontend && flutter run -t lib/main_development.dart"

# Linux
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    IP=$(hostname -I | awk '{print $1}')
    echo "📍 Local IP: $IP"
    echo "🌐 Server URL: http://$IP:8080"

# Windows
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    IP=$(ipconfig | grep "IPv4" | awk '{print $NF}' | head -1)
    echo "📍 Local IP: $IP"
    echo "🌐 Server URL: http://$IP:8080"

else
    echo "❌ This OS is not supported"
    exit 1
fi

echo ""
echo "✅ Copy the above IP to update the config!"
