#!/bin/bash

# Test script for PipUp tvOS HTTP endpoints
# Run this script while the tvOS app is running to test the API endpoints

HOST="localhost:8080"  # Change to your Apple TV IP when testing on device

echo "Testing PipUp tvOS HTTP Endpoints"
echo "=================================="

# Test 1: Image notification endpoint
echo "Test 1: Image notification"
echo "Sending POST request to /notify/image..."

response=$(curl -s -X POST "http://$HOST/notify/image" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Image Notification",
    "body": "This is a test image notification from the API test script",
    "imageUrl": "https://picsum.photos/400/300?random=1"
  }')

echo "Response: $response"
echo ""

# Test 2: Video notification endpoint
echo "Test 2: Video notification"
echo "Sending POST request to /notify/video..."

response=$(curl -s -X POST "http://$HOST/notify/video" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Video Notification", 
    "body": "This is a test video notification from the API test script",
    "rtspUrl": "https://sample-videos.com/zip/10mb/mp4/SampleVideo_1280x720_1mb.mp4"
  }')

echo "Response: $response"
echo ""

# Test 3: Invalid endpoint (should return 404)
echo "Test 3: Invalid endpoint (should return 404)"
echo "Sending POST request to /invalid..."

response=$(curl -s -X POST "http://$HOST/invalid" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}')

echo "Response: $response"
echo ""

# Test 4: Malformed JSON (should return 400)
echo "Test 4: Malformed JSON (should return 400)"
echo "Sending POST request with invalid JSON..."

response=$(curl -s -X POST "http://$HOST/notify/image" \
  -H "Content-Type: application/json" \
  -d '{"title": "Missing fields"}')

echo "Response: $response"
echo ""

# Test 5: Missing JSON body (should return 400)
echo "Test 5: Missing JSON body (should return 400)"
echo "Sending POST request without body..."

response=$(curl -s -X POST "http://$HOST/notify/image" \
  -H "Content-Type: application/json")

echo "Response: $response"
echo ""

echo "Test completed!"
echo "Check your Apple TV screen for the notifications that should have appeared."