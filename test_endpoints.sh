#!/bin/bash

# Test script for PipUp tvOS HTTP server endpoints
# Usage: ./test_endpoints.sh [APPLE_TV_IP]

APPLE_TV_IP=${1:-"localhost"}
PORT=8080
BASE_URL="http://${APPLE_TV_IP}:${PORT}"

echo "🧪 Testing PipUp tvOS Server at ${BASE_URL}"
echo "============================================"

# Test health endpoint
echo "1️⃣  Testing health endpoint..."
curl -s -X GET "${BASE_URL}/health" | jq '.' || echo "Health check failed"
echo ""

# Test image notification endpoint
echo "2️⃣  Testing image notification endpoint..."
curl -s -X POST "${BASE_URL}/notify/image" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Image Notification",
    "body": "This is a test notification with an image",
    "imageUrl": "https://via.placeholder.com/400x300.png?text=Test+Image"
  }' | jq '.' || echo "Image notification failed"
echo ""

# Test video notification endpoint
echo "3️⃣  Testing video notification endpoint..."
curl -s -X POST "${BASE_URL}/notify/video" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Video Notification",
    "body": "This is a test notification with video",
    "rtspUrl": "rtsp://wowzaec2demo.streamlock.net/vod-multitrack/_definst_/mp4:ElephantsDream/elephants_dream.mp4"
  }' | jq '.' || echo "Video notification failed"
echo ""

# Test invalid request
echo "4️⃣  Testing invalid request (missing fields)..."
curl -s -X POST "${BASE_URL}/notify/image" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Incomplete Request"
  }' | jq '.' || echo "Invalid request test failed"
echo ""

# Test invalid method
echo "5️⃣  Testing invalid method (GET instead of POST)..."
curl -s -X GET "${BASE_URL}/notify/image" | jq '.' || echo "Invalid method test failed"
echo ""

echo "✅ Testing completed!"
echo ""
echo "💡 To test with your Apple TV:"
echo "   1. Find your Apple TV's IP address in Settings > General > About > Network"
echo "   2. Run: ./test_endpoints.sh YOUR_APPLE_TV_IP"