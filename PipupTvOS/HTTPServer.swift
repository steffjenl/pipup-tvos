import Foundation
import Network

class HTTPServer {
    private var listener: NWListener?
    private let port: NWEndpoint.Port = 8080
    private let queue = DispatchQueue(label: "HTTPServer")
    
    func start() throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        
        listener = try NWListener(using: parameters, on: port)
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }
        
        listener?.start(queue: queue)
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        
        receiveRequest(connection: connection)
    }
    
    private func receiveRequest(connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            
            if let error = error {
                print("Connection error: \(error)")
                connection.cancel()
                return
            }
            
            if let data = data, !data.isEmpty {
                self?.processRequest(data: data, connection: connection)
            }
            
            if isComplete {
                connection.cancel()
            } else {
                self?.receiveRequest(connection: connection)
            }
        }
    }
    
    private func processRequest(data: Data, connection: NWConnection) {
        guard let requestString = String(data: data, encoding: .utf8) else {
            sendErrorResponse(connection: connection, statusCode: 400, message: "Bad Request")
            return
        }
        
        let lines = requestString.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            sendErrorResponse(connection: connection, statusCode: 400, message: "Bad Request")
            return
        }
        
        let components = requestLine.components(separatedBy: " ")
        guard components.count >= 3 else {
            sendErrorResponse(connection: connection, statusCode: 400, message: "Bad Request")
            return
        }
        
        let method = components[0]
        let path = components[1]
        
        // Extract JSON body if present
        var jsonData: Data?
        if let bodyStart = requestString.range(of: "\r\n\r\n") {
            let bodyString = String(requestString[bodyStart.upperBound...])
            jsonData = bodyString.data(using: .utf8)
        }
        
        handleRequest(method: method, path: path, jsonData: jsonData, connection: connection)
    }
    
    private func handleRequest(method: String, path: String, jsonData: Data?, connection: NWConnection) {
        switch (method, path) {
        case ("POST", "/notify/image"):
            handleImageNotification(jsonData: jsonData, connection: connection)
        case ("POST", "/notify/video"):
            handleVideoNotification(jsonData: jsonData, connection: connection)
        default:
            sendErrorResponse(connection: connection, statusCode: 404, message: "Not Found")
        }
    }
    
    private func handleImageNotification(jsonData: Data?, connection: NWConnection) {
        guard let jsonData = jsonData else {
            sendErrorResponse(connection: connection, statusCode: 400, message: "Missing JSON body")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            guard let title = json?["title"] as? String,
                  let body = json?["body"] as? String,
                  let imageUrl = json?["imageUrl"] as? String else {
                sendErrorResponse(connection: connection, statusCode: 400, message: "Invalid JSON format")
                return
            }
            
            // Show image notification on main thread
            DispatchQueue.main.async {
                NotificationManager.shared.showImageNotification(title: title, body: body, imageUrl: imageUrl)
            }
            
            sendSuccessResponse(connection: connection, message: "Image notification sent")
            
        } catch {
            sendErrorResponse(connection: connection, statusCode: 400, message: "Invalid JSON")
        }
    }
    
    private func handleVideoNotification(jsonData: Data?, connection: NWConnection) {
        guard let jsonData = jsonData else {
            sendErrorResponse(connection: connection, statusCode: 400, message: "Missing JSON body")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            guard let title = json?["title"] as? String,
                  let body = json?["body"] as? String,
                  let rtspUrl = json?["rtspUrl"] as? String else {
                sendErrorResponse(connection: connection, statusCode: 400, message: "Invalid JSON format")
                return
            }
            
            // Show video notification on main thread
            DispatchQueue.main.async {
                NotificationManager.shared.showVideoNotification(title: title, body: body, rtspUrl: rtspUrl)
            }
            
            sendSuccessResponse(connection: connection, message: "Video notification sent")
            
        } catch {
            sendErrorResponse(connection: connection, statusCode: 400, message: "Invalid JSON")
        }
    }
    
    private func sendSuccessResponse(connection: NWConnection, message: String) {
        let responseJson = ["status": "success", "message": message]
        let responseData = try! JSONSerialization.data(withJSONObject: responseJson)
        
        let response = """
        HTTP/1.1 200 OK\r
        Content-Type: application/json\r
        Content-Length: \(responseData.count)\r
        Connection: close\r
        \r
        \(String(data: responseData, encoding: .utf8)!)
        """
        
        let data = response.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
    
    private func sendErrorResponse(connection: NWConnection, statusCode: Int, message: String) {
        let responseJson = ["status": "error", "message": message]
        let responseData = try! JSONSerialization.data(withJSONObject: responseJson)
        
        let response = """
        HTTP/1.1 \(statusCode) \(HTTPURLResponse.localizedString(forStatusCode: statusCode))\r
        Content-Type: application/json\r
        Content-Length: \(responseData.count)\r
        Connection: close\r
        \r
        \(String(data: responseData, encoding: .utf8)!)
        """
        
        let data = response.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}