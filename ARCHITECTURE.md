# PipUp tvOS - Project Structure

## Overview
Complete tvOS application with HTTP server for displaying notifications and video playback.

## Project Structure

```
PipupTvOS.xcodeproj/
├── project.pbxproj                 # Xcode project configuration
└── project.xcworkspace/
    └── contents.xcworkspacedata

PipupTvOS/                          # Main application source
├── AppDelegate.swift               # App entry point, HTTP server setup
├── ViewController.swift            # Main UI controller
├── HTTPServer.swift                # Custom HTTP server using Network framework
├── NotificationManager.swift       # Notification overlay management
├── VideoPlayerManager.swift       # RTSP video playback with AVPlayer
├── Info.plist                      # App configuration
├── Assets.xcassets/                # App icons and assets
│   ├── Contents.json
│   ├── AccentColor.colorset/
│   └── App Icon & Top Shelf Image.brandassets/
└── Base.lproj/
    └── LaunchScreen.storyboard     # Launch screen

tests/                              # API testing scripts
├── test_endpoints.sh               # Bash test script
└── test_endpoints.py               # Python test script
```

## Key Features Implemented

### 1. HTTP Server (HTTPServer.swift)
- Uses Network framework for lightweight HTTP server
- Runs on port 8080
- Handles POST requests with JSON payloads
- Proper error handling and response formatting

### 2. Image Notifications (NotificationManager.swift)
- POST `/notify/image` endpoint
- Custom tvOS-friendly overlay UI
- Asynchronous image loading from URLs
- Auto-dismiss after 10 seconds
- Smooth animations and proper focus handling

### 3. Video Notifications (VideoPlayerManager.swift)
- POST `/notify/video` endpoint  
- RTSP video stream support using AVPlayer
- Full-screen video player presentation
- Error handling for invalid URLs or playback failures
- Automatic cleanup when video ends

### 4. tvOS UI Components
- Custom notification overlays designed for TV interface
- Large, readable fonts optimized for viewing distance
- Focus-friendly button layouts
- Proper constraint-based layouts for different screen sizes

### 5. Error Handling
- Malformed JSON requests return 400 Bad Request
- Invalid endpoints return 404 Not Found
- Network and media errors show user-friendly messages
- Graceful fallback for all error conditions

## API Endpoints

### POST /notify/image
```json
{
  "title": "Notification Title",
  "body": "Message body", 
  "imageUrl": "https://example.com/image.jpg"
}
```

### POST /notify/video
```json
{
  "title": "Video Alert",
  "body": "Video message",
  "rtspUrl": "rtsp://example.com/stream"
}
```

## Building Instructions

1. Open `PipupTvOS.xcodeproj` in Xcode
2. Set deployment target to tvOS 15.0+
3. Select Apple TV simulator or device
4. Build and run (⌘+R)
5. HTTP server starts automatically on port 8080

## Testing

Use the provided test scripts:
- `./tests/test_endpoints.sh` - Bash version
- `./tests/test_endpoints.py` - Python version

Both scripts test valid requests, error cases, and edge conditions.