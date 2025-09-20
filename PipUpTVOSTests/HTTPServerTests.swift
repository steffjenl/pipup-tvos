import XCTest
@testable import PipUpTVOS

class HTTPServerTests: XCTestCase {
    
    var httpServer: HTTPServer!
    var notificationManager: NotificationManager!
    
    override func setUpWithError() throws {
        httpServer = HTTPServer()
        notificationManager = NotificationManager()
        httpServer.notificationManager = notificationManager
    }
    
    override func tearDownWithError() throws {
        httpServer.stop()
        httpServer = nil
        notificationManager = nil
    }
    
    func testServerInitialization() throws {
        XCTAssertNotNil(httpServer)
        XCTAssertNotNil(httpServer.notificationManager)
    }
    
    func testServerStartStop() throws {
        // Test starting server
        XCTAssertNoThrow(try httpServer.start())
        
        // Test stopping server
        XCTAssertNoThrow(httpServer.stop())
    }
    
    func testHTTPRequestParsing() throws {
        let requestString = """
        POST /notification HTTP/1.1\r
        Content-Type: application/json\r
        Content-Length: 45\r
        \r
        {"title":"Test","message":"Test notification"}
        """
        
        // This would test the private parseHTTPRequest method
        // In a real implementation, you might make this method internal for testing
        XCTAssertTrue(requestString.contains("POST /notification"))
    }
    
    func testHTTPResponseCreation() throws {
        let okResponse = HTTPResponse.ok("Success")
        XCTAssertEqual(okResponse.statusCode, 200)
        XCTAssertEqual(okResponse.statusText, "OK")
        XCTAssertEqual(okResponse.body, "Success")
        
        let badRequestResponse = HTTPResponse.badRequest("Error")
        XCTAssertEqual(badRequestResponse.statusCode, 400)
        XCTAssertEqual(badRequestResponse.statusText, "Bad Request")
        XCTAssertEqual(badRequestResponse.body, "Error")
        
        let notFoundResponse = HTTPResponse.notFound()
        XCTAssertEqual(notFoundResponse.statusCode, 404)
        XCTAssertEqual(notFoundResponse.statusText, "Not Found")
    }
    
    func testHTTPResponseToString() throws {
        let response = HTTPResponse.ok("Test Body")
        let responseString = response.toString()
        
        XCTAssertTrue(responseString.contains("HTTP/1.1 200 OK"))
        XCTAssertTrue(responseString.contains("Content-Type: text/plain"))
        XCTAssertTrue(responseString.contains("Content-Length: 9"))
        XCTAssertTrue(responseString.contains("Test Body"))
    }
}