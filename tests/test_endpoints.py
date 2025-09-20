#!/usr/bin/env python3

"""
Python test script for PipUp tvOS HTTP endpoints
This script tests both valid and invalid requests to ensure proper error handling
"""

import requests
import json
import time

def test_endpoints():
    base_url = "http://localhost:8080"  # Change to your Apple TV IP when testing on device
    
    print("Testing PipUp tvOS HTTP Endpoints")
    print("=" * 40)
    
    # Test 1: Valid image notification
    print("\nTest 1: Valid image notification")
    image_payload = {
        "title": "Python Test Image",
        "body": "This is a test image notification sent from Python",
        "imageUrl": "https://picsum.photos/600/400?random=2"
    }
    
    try:
        response = requests.post(
            f"{base_url}/notify/image", 
            json=image_payload,
            timeout=5
        )
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
    
    time.sleep(2)  # Wait between requests
    
    # Test 2: Valid video notification
    print("\nTest 2: Valid video notification")
    video_payload = {
        "title": "Python Test Video",
        "body": "This is a test video notification sent from Python", 
        "rtspUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    }
    
    try:
        response = requests.post(
            f"{base_url}/notify/video",
            json=video_payload,
            timeout=5
        )
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
    
    time.sleep(2)
    
    # Test 3: Invalid endpoint
    print("\nTest 3: Invalid endpoint (404 expected)")
    try:
        response = requests.post(
            f"{base_url}/invalid",
            json={"test": "data"},
            timeout=5
        )
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
    
    # Test 4: Missing required fields
    print("\nTest 4: Missing required fields (400 expected)")
    invalid_payload = {
        "title": "Missing fields"
        # Missing 'body' and 'imageUrl'
    }
    
    try:
        response = requests.post(
            f"{base_url}/notify/image",
            json=invalid_payload,
            timeout=5
        )
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
    
    # Test 5: Invalid JSON
    print("\nTest 5: Invalid content type (400 expected)")
    try:
        response = requests.post(
            f"{base_url}/notify/image",
            data="not json",
            headers={"Content-Type": "text/plain"},
            timeout=5
        )
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
    
    print("\n" + "=" * 40)
    print("Test completed!")
    print("Check your Apple TV screen for the notifications.")

if __name__ == "__main__":
    test_endpoints()