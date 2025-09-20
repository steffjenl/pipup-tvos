import XCTest
@testable import PipUpTVOS

class NotificationManagerTests: XCTestCase {
    
    var notificationManager: NotificationManager!
    
    override func setUpWithError() throws {
        notificationManager = NotificationManager()
    }
    
    override func tearDownWithError() throws {
        notificationManager = nil
    }
    
    func testNotificationManagerInitialization() throws {
        XCTAssertNotNil(notificationManager)
    }
    
    func testNotificationDataCreation() throws {
        let notification = NotificationData(
            title: "Test Title",
            message: "Test Message",
            imageURL: "https://example.com/image.jpg",
            streamURL: "rtsp://example.com/stream"
        )
        
        XCTAssertEqual(notification.title, "Test Title")
        XCTAssertEqual(notification.message, "Test Message")
        XCTAssertEqual(notification.imageURL, "https://example.com/image.jpg")
        XCTAssertEqual(notification.streamURL, "rtsp://example.com/stream")
    }
    
    func testNotificationDataFromJSON() throws {
        let json: [String: Any] = [
            "title": "JSON Title",
            "message": "JSON Message",
            "imageURL": "https://example.com/image.png",
            "streamURL": "https://example.com/stream.m3u8"
        ]
        
        let notification = NotificationData(from: json)
        
        XCTAssertEqual(notification.title, "JSON Title")
        XCTAssertEqual(notification.message, "JSON Message")
        XCTAssertEqual(notification.imageURL, "https://example.com/image.png")
        XCTAssertEqual(notification.streamURL, "https://example.com/stream.m3u8")
    }
    
    func testNotificationDataFromIncompleteJSON() throws {
        let json: [String: Any] = [
            "message": "Only Message"
        ]
        
        let notification = NotificationData(from: json)
        
        XCTAssertEqual(notification.title, "Notification") // Default value
        XCTAssertEqual(notification.message, "Only Message")
        XCTAssertNil(notification.imageURL)
        XCTAssertNil(notification.streamURL)
    }
    
    func testNotificationDataFromEmptyJSON() throws {
        let json: [String: Any] = [:]
        
        let notification = NotificationData(from: json)
        
        XCTAssertEqual(notification.title, "Notification") // Default value
        XCTAssertEqual(notification.message, "") // Default value
        XCTAssertNil(notification.imageURL)
        XCTAssertNil(notification.streamURL)
    }
    
    func testShowNotificationWithValidData() throws {
        let notification = NotificationData(
            title: "Test Notification",
            message: "This is a test"
        )
        
        // This test would ideally mock the UI components
        XCTAssertNoThrow(notificationManager.showNotification(notification))
    }
    
    func testShowNotificationWithImageURL() throws {
        let notification = NotificationData(
            title: "Image Notification",
            message: "This has an image",
            imageURL: "https://httpbin.org/image/png"
        )
        
        XCTAssertNoThrow(notificationManager.showNotification(notification))
    }
    
    func testShowNotificationWithStreamURL() throws {
        let notification = NotificationData(
            title: "Stream Notification",
            message: "This has a stream",
            streamURL: "https://example.com/stream.m3u8"
        )
        
        XCTAssertNoThrow(notificationManager.showNotification(notification))
    }
}