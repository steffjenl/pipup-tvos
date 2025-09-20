# PipUp tvOS

A tvOS application that provides HTTP endpoints for displaying notifications with images and launching video streams.

## Features

- **HTTP Server**: Local HTTP server running on port 8080
- **Image Notifications**: POST to `/notify/image` to display notifications with images
- **Video Notifications**: POST to `/notify/video` to display notifications and launch RTSP video streams
- **tvOS UI**: Custom notification overlays designed for Apple TV interface

## API Endpoints

### POST /notify/image

Display a notification with an image.

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
  "status": "success",
  "message": "Image notification sent"
}
```

### POST /notify/video

Display a notification and launch video player for RTSP stream.

**Request Body:**
```json
{
  "title": "Video Alert",
  "body": "Incoming video stream",
  "rtspUrl": "rtsp://example.com/stream"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Video notification sent"
}
```

## Building and Running

1. Open `PipupTvOS.xcodeproj` in Xcode
2. Set the deployment target to Apple TV
3. Build and run the project
4. The HTTP server will start automatically on port 8080

## Testing the API

You can test the endpoints using curl:

```bash
# Test image notification
curl -X POST http://apple-tv-ip:8080/notify/image \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Image",
    "body": "This is a test image notification",
    "imageUrl": "https://picsum.photos/400/300"
  }'

# Test video notification
curl -X POST http://apple-tv-ip:8080/notify/video \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Video",
    "body": "This is a test video notification",
    "rtspUrl": "rtsp://sample-videos.com/zip/10mb/mp4/SampleVideo_1280x720_1mb.mp4"
  }'
```

## Requirements

- tvOS 15.0 or later
- Xcode 15.0 or later
- Apple TV device or simulator

## Architecture

- **AppDelegate**: Main application entry point, sets up HTTP server
- **ViewController**: Main UI displaying server status
- **HTTPServer**: Custom HTTP server using Network framework
- **NotificationManager**: Manages display of notification overlays
- **VideoPlayerManager**: Handles RTSP video playback using AVPlayer
- **ImageNotificationView**: Custom UI for image notifications
- **VideoNotificationView**: Custom UI for video notifications

## Error Handling

- Malformed JSON requests return 400 Bad Request
- Invalid URLs return appropriate error messages
- Network errors are handled gracefully
- Video playback errors show user-friendly alerts