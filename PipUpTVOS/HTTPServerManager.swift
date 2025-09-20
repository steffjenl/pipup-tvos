import Foundation
import Swifter

class HTTPServerManager {
    private var server: HttpServer?
    private let port: UInt16 = 8080
    
    func startServer() {
        server = HttpServer()
        
        setupRoutes()
        
        do {
            try server?.start(port)
            print("✅ HTTP Server started on port \(port)")
            print("📡 Image notifications: POST http://localhost:\(port)/notify/image")
            print("📹 Video notifications: POST http://localhost:\(port)/notify/video")
        } catch {
            print("❌ Failed to start server: \(error)")
        }
    }
    
    func stopServer() {
        server?.stop()
        print("🛑 HTTP Server stopped")
    }
    
    private func setupRoutes() {
        // Image notification endpoint
        server?["/notify/image"] = { request in
            return self.handleImageNotification(request: request)
        }
        
        // Video notification endpoint
        server?["/notify/video"] = { request in
            return self.handleVideoNotification(request: request)
        }
        
        // Health check endpoint
        server?["/health"] = { request in
            return .ok(.json(["status": "ok", "service": "PipUp tvOS Server"]))
        }
    }
    
    private func handleImageNotification(request: HttpRequest) -> HttpResponse {
        // Only accept POST requests
        guard request.method == "POST" else {
            return .badRequest(.json(["error": "Only POST method is allowed"]))
        }
        
        // Parse JSON body
        guard let bodyData = Data(request.body),
              let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
            return .badRequest(.json(["error": "Invalid JSON body"]))
        }
        
        // Validate required fields
        guard let title = json["title"] as? String,
              let body = json["body"] as? String,
              let imageUrl = json["imageUrl"] as? String else {
            return .badRequest(.json([
                "error": "Missing required fields: title, body, imageUrl"
            ]))
        }
        
        // Validate image URL format
        guard URL(string: imageUrl) != nil else {
            return .badRequest(.json(["error": "Invalid imageUrl format"]))
        }
        
        // Send notification to main thread
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowImageNotification"),
                object: nil,
                userInfo: [
                    "title": title,
                    "body": body,
                    "imageUrl": imageUrl
                ]
            )
        }
        
        print("📸 Image notification received: \(title)")
        
        return .ok(.json([
            "success": true,
            "message": "Image notification sent",
            "data": [
                "title": title,
                "body": body,
                "imageUrl": imageUrl
            ]
        ]))
    }
    
    private func handleVideoNotification(request: HttpRequest) -> HttpResponse {
        // Only accept POST requests
        guard request.method == "POST" else {
            return .badRequest(.json(["error": "Only POST method is allowed"]))
        }
        
        // Parse JSON body
        guard let bodyData = Data(request.body),
              let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
            return .badRequest(.json(["error": "Invalid JSON body"]))
        }
        
        // Validate required fields
        guard let title = json["title"] as? String,
              let body = json["body"] as? String,
              let rtspUrl = json["rtspUrl"] as? String else {
            return .badRequest(.json([
                "error": "Missing required fields: title, body, rtspUrl"
            ]))
        }
        
        // Validate RTSP URL format
        guard URL(string: rtspUrl) != nil else {
            return .badRequest(.json(["error": "Invalid rtspUrl format"]))
        }
        
        // Send notification to main thread
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowVideoNotification"),
                object: nil,
                userInfo: [
                    "title": title,
                    "body": body,
                    "rtspUrl": rtspUrl
                ]
            )
        }
        
        print("📹 Video notification received: \(title)")
        
        return .ok(.json([
            "success": true,
            "message": "Video notification sent",
            "data": [
                "title": title,
                "body": body,
                "rtspUrl": rtspUrl
            ]
        ]))
    }
}

// Extension to handle Data conversion from HttpRequest body
extension Data {
    init(_ uint8Array: [UInt8]) {
        self = uint8Array.withUnsafeBufferPointer { buffer in
            Data(buffer: buffer)
        }
    }
}