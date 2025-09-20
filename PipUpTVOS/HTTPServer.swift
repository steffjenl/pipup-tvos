import Foundation
import Network

class HTTPServer {
    private var listener: NWListener?
    private let port: UInt16 = 8080
    private let queue = DispatchQueue(label: "HTTPServer")
    var notificationManager: NotificationManager?
    
    func start() throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        
        listener = try NWListener(using: parameters, on: NWEndpoint.Port(port)!)
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }
        
        listener?.start(queue: queue)
        print("HTTP Server listening on port \(port)")
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        
        receiveRequest(on: connection) { [weak self] request in
            self?.processRequest(request, on: connection)
        }
    }
    
    private func receiveRequest(on connection: NWConnection, completion: @escaping (HTTPRequest?) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { data, _, isComplete, error in
            
            if let error = error {
                print("Error receiving data: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let requestString = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            let request = self.parseHTTPRequest(requestString)
            completion(request)
        }
    }
    
    private func parseHTTPRequest(_ requestString: String) -> HTTPRequest? {
        let lines = requestString.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else { return nil }
        
        let components = firstLine.components(separatedBy: " ")
        guard components.count >= 3 else { return nil }
        
        let method = components[0]
        let path = components[1]
        
        var headers: [String: String] = [:]
        var bodyIndex = 0
        
        for (index, line) in lines.enumerated() {
            if index == 0 { continue }
            if line.isEmpty {
                bodyIndex = index + 1
                break
            }
            
            let headerComponents = line.components(separatedBy: ": ")
            if headerComponents.count == 2 {
                headers[headerComponents[0]] = headerComponents[1]
            }
        }
        
        var body: String?
        if bodyIndex < lines.count {
            let bodyLines = Array(lines[bodyIndex...])
            body = bodyLines.joined(separator: "\r\n")
        }
        
        return HTTPRequest(method: method, path: path, headers: headers, body: body)
    }
    
    private func processRequest(_ request: HTTPRequest?, on connection: NWConnection) {
        guard let request = request else {
            sendResponse(HTTPResponse.badRequest(), on: connection)
            return
        }
        
        print("Received \(request.method) \(request.path)")
        
        switch (request.method, request.path) {
        case ("GET", "/"):
            sendResponse(HTTPResponse.ok("PipUp tvOS Server is running"), on: connection)
            
        case ("POST", "/notification"):
            handleNotificationRequest(request, on: connection)
            
        case ("POST", "/stream"):
            handleStreamRequest(request, on: connection)
            
        case ("GET", "/status"):
            sendResponse(HTTPResponse.ok("Server Status: Active"), on: connection)
            
        default:
            sendResponse(HTTPResponse.notFound(), on: connection)
        }
    }
    
    private func handleNotificationRequest(_ request: HTTPRequest, on connection: NWConnection) {
        guard let body = request.body, !body.isEmpty else {
            sendResponse(HTTPResponse.badRequest("Missing notification data"), on: connection)
            return
        }
        
        do {
            guard let data = body.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                sendResponse(HTTPResponse.badRequest("Invalid JSON"), on: connection)
                return
            }
            
            let notification = NotificationData(from: json)
            notificationManager?.showNotification(notification)
            sendResponse(HTTPResponse.ok("Notification sent"), on: connection)
            
        } catch {
            print("Error parsing notification: \(error)")
            sendResponse(HTTPResponse.badRequest("Failed to parse notification"), on: connection)
        }
    }
    
    private func handleStreamRequest(_ request: HTTPRequest, on connection: NWConnection) {
        guard let body = request.body, !body.isEmpty else {
            sendResponse(HTTPResponse.badRequest("Missing stream data"), on: connection)
            return
        }
        
        do {
            guard let data = body.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let urlString = json["url"] as? String else {
                sendResponse(HTTPResponse.badRequest("Invalid stream data"), on: connection)
                return
            }
            
            // Handle stream request through notification manager
            let streamNotification = NotificationData(
                title: json["title"] as? String ?? "Stream",
                message: json["message"] as? String ?? "Playing stream",
                imageURL: json["imageURL"] as? String,
                streamURL: urlString
            )
            
            notificationManager?.showNotification(streamNotification)
            sendResponse(HTTPResponse.ok("Stream started"), on: connection)
            
        } catch {
            print("Error parsing stream request: \(error)")
            sendResponse(HTTPResponse.badRequest("Failed to parse stream request"), on: connection)
        }
    }
    
    private func sendResponse(_ response: HTTPResponse, on connection: NWConnection) {
        let responseString = response.toString()
        let data = responseString.data(using: .utf8)!
        
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending response: \(error)")
            }
            connection.cancel()
        })
    }
}

// MARK: - Helper Structures

struct HTTPRequest {
    let method: String
    let path: String
    let headers: [String: String]
    let body: String?
}

struct HTTPResponse {
    let statusCode: Int
    let statusText: String
    let headers: [String: String]
    let body: String
    
    static func ok(_ body: String = "") -> HTTPResponse {
        return HTTPResponse(
            statusCode: 200,
            statusText: "OK",
            headers: ["Content-Type": "text/plain"],
            body: body
        )
    }
    
    static func badRequest(_ body: String = "Bad Request") -> HTTPResponse {
        return HTTPResponse(
            statusCode: 400,
            statusText: "Bad Request",
            headers: ["Content-Type": "text/plain"],
            body: body
        )
    }
    
    static func notFound(_ body: String = "Not Found") -> HTTPResponse {
        return HTTPResponse(
            statusCode: 404,
            statusText: "Not Found",
            headers: ["Content-Type": "text/plain"],
            body: body
        )
    }
    
    func toString() -> String {
        var response = "HTTP/1.1 \(statusCode) \(statusText)\r\n"
        
        for (key, value) in headers {
            response += "\(key): \(value)\r\n"
        }
        
        response += "Content-Length: \(body.utf8.count)\r\n"
        response += "Connection: close\r\n"
        response += "\r\n"
        response += body
        
        return response
    }
}