# PipUp tvOS

A Swift-based Apple tvOS application that displays notifications and streams RTSP content on tvOS devices. This app runs an HTTP server to receive notification requests and can display them as overlays or stream video content.

## Features

- **HTTP Server**: Lightweight HTTP server for receiving notification requests
- **tvOS-Friendly UI**: Notifications displayed as overlays and modals optimized for TV viewing
- **Asynchronous Image Loading**: Efficiently loads and caches images from URLs
- **RTSP Streaming**: Stream RTSP content using AVPlayer
- **Error Handling**: Robust error handling for malformed requests and unreachable media URLs
- **Unit Tests**: Comprehensive test coverage for core components

## Requirements

- Xcode 15.0+
- tvOS 17.0+
- Swift 5.0+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/steffjenl/pipup-tvos.git
cd pipup-tvos
```

2. Open the project in Xcode:
```bash
open PipUpTVOS.xcodeproj
```

3. Build and run on tvOS Simulator or device

## API Endpoints

The HTTP server runs on port 8080 and supports the following endpoints:

### GET /
Returns server status

### GET /status
Returns detailed server status

### POST /notification
Send a notification to display on the tvOS device

**Request Body (JSON):**
```json
{
  "title": "Notification Title",
  "message": "Notification message text",
  "imageURL": "https://example.com/image.jpg" // Optional
}
```

### POST /stream
Start streaming RTSP content

**Request Body (JSON):**
```json
{
  "title": "Stream Title",
  "message": "Stream description",
  "url": "rtsp://example.com/stream",
  "imageURL": "https://example.com/thumbnail.jpg" // Optional
}
```

## Usage Examples

### Send a Simple Notification
```bash
curl -X POST http://YOUR_TVOS_IP:8080/notification \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Door Bell", 
    "message": "Someone is at the front door"
  }'
```

### Send a Notification with Image
```bash
curl -X POST http://YOUR_TVOS_IP:8080/notification \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Security Alert", 
    "message": "Motion detected in backyard",
    "imageURL": "https://example.com/camera-snapshot.jpg"
  }'
```

### Start a Video Stream
```bash
curl -X POST http://YOUR_TVOS_IP:8080/stream \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Live Camera Feed", 
    "message": "Front door camera",
    "url": "rtsp://camera.local/stream"
  }'
```

## Architecture

### Core Components

- **AppDelegate**: Main application entry point and HTTP server initialization
- **ContentViewController**: Main UI displaying server status
- **HTTPServer**: Lightweight HTTP server using Network framework
- **NotificationManager**: Manages notification display and lifecycle
- **StreamingPlayer**: Handles RTSP streaming with AVPlayer
- **NotificationView**: Custom UI component for displaying notifications

### Key Guidelines Implemented

- ✅ **Swift and tvOS SDK**: Native Swift implementation targeting tvOS 17.0+
- ✅ **Lightweight HTTP Framework**: Custom HTTP server using Network framework
- ✅ **tvOS-Friendly UI**: Notifications use overlays and modals optimized for TV
- ✅ **Async Image Loading**: Images loaded asynchronously with caching
- ✅ **AVPlayer Integration**: RTSP streaming using AVPlayer
- ✅ **Error Handling**: Comprehensive error handling throughout
- ✅ **Unit Tests**: Full test coverage for all major components

## Testing

Run the test suite in Xcode:
1. Press `Cmd+U` to run all tests
2. Or use `Product > Test` from the menu

Test coverage includes:
- HTTP server functionality
- Notification manager operations
- Streaming player validation
- Error handling scenarios

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.