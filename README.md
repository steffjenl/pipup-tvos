# PipUp tvOS - HTTP Notification Server

A tvOS application that runs a lightweight HTTP server for receiving and displaying notifications with images and video streaming capabilities.

## Features

- **Lightweight HTTP Server**: Runs locally on tvOS using the Swifter framework
- **Image Notifications**: Display notifications with images loaded asynchronously
- **Video Streaming**: Stream RTSP content using AVPlayer
- **tvOS-Friendly UI**: Beautiful overlay presentations optimized for tvOS
- **Error Handling**: Robust error handling for malformed requests and unreachable media URLs
- **Auto-Dismiss**: Notifications automatically dismiss after a timeout

## Endpoints

### POST `/notify/image`
Displays a notification with an image.

**Request Body:**
```json
{
  "title": "Notification Title",
  "body": "Notification message body",
  "imageUrl": "https://example.com/image.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Image notification sent",
  "data": {
    "title": "Notification Title",
    "body": "Notification message body",
    "imageUrl": "https://example.com/image.jpg"
  }
}
```

### POST `/notify/video`
Displays a notification and launches a video player for RTSP streaming.

**Request Body:**
```json
{
  "title": "Video Stream",
  "body": "Starting video stream...",
  "rtspUrl": "rtsp://example.com/stream"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Video notification sent",
  "data": {
    "title": "Video Stream",
    "body": "Starting video stream...",
    "rtspUrl": "rtsp://example.com/stream"
  }
}
```

### GET `/health`
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "service": "PipUp tvOS Server"
}
```

## Building and Running

### Prerequisites
- Xcode 15.0 or later
- tvOS 15.0 or later
- Apple TV (4th generation or later)

### Build Instructions

1. Clone the repository:
```bash
git clone https://github.com/steffjenl/pipup-tvos.git
cd pipup-tvos
```

2. Open the project in Xcode:
```bash
open PipUpTVOS.xcodeproj
```

3. Select your Apple TV as the target device
4. Build and run the project (⌘+R)

### Swift Package Manager

This project can also be used as a Swift Package:

```swift
dependencies: [
    .package(url: "https://github.com/steffjenl/pipup-tvos.git", from: "1.0.0")
]
```

## Usage Examples

### Using curl to send notifications

**Image notification:**
```bash
curl -X POST http://YOUR_APPLE_TV_IP:8080/notify/image \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Security Alert",
    "body": "Motion detected at front door",
    "imageUrl": "https://example.com/camera-snapshot.jpg"
  }'
```

**Video notification:**
```bash
curl -X POST http://YOUR_APPLE_TV_IP:8080/notify/video \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Live Camera Feed",
    "body": "Viewing front door camera",
    "rtspUrl": "rtsp://camera.local/stream"
  }'
```

### Using JavaScript/Node.js

```javascript
const axios = require('axios');

// Send image notification
await axios.post('http://YOUR_APPLE_TV_IP:8080/notify/image', {
  title: 'Doorbell',
  body: 'Someone is at the door',
  imageUrl: 'https://example.com/doorbell.jpg'
});

// Send video notification
await axios.post('http://YOUR_APPLE_TV_IP:8080/notify/video', {
  title: 'Security Camera',
  body: 'Live feed from camera 1',
  rtspUrl: 'rtsp://192.168.1.100/stream'
});
```

## Configuration

The server runs on port **8080** by default. You can find your Apple TV's IP address in Settings > General > About > Network.

## Error Handling

The application includes comprehensive error handling for:

- Invalid JSON payloads
- Missing required fields
- Invalid URL formats
- Network connectivity issues
- Media loading failures
- RTSP stream connection problems

## Architecture

- **AppDelegate**: Manages application lifecycle and HTTP server startup
- **ViewController**: Main UI controller handling notifications
- **HTTPServerManager**: Manages HTTP server and endpoint routing
- **NotificationOverlay**: Custom UI component for displaying notifications
- **VideoPlayerController**: Enhanced AVPlayerViewController for RTSP streaming

## Dependencies

- [Swifter](https://github.com/httpswift/swifter): Lightweight HTTP server framework
- AVKit: Apple's video playback framework
- AVFoundation: Media framework for audio/video handling

## License

MIT License - see [LICENSE](LICENSE) file for details.