import XCTest
import AVFoundation
@testable import PipUpTVOS

class StreamingPlayerTests: XCTestCase {
    
    var streamingPlayer: StreamingPlayer!
    
    override func setUpWithError() throws {
        streamingPlayer = StreamingPlayer()
    }
    
    override func tearDownWithError() throws {
        streamingPlayer.stop()
        streamingPlayer = nil
    }
    
    func testStreamingPlayerInitialization() throws {
        XCTAssertNotNil(streamingPlayer)
    }
    
    func testValidateStreamURL() throws {
        // Test valid HTTP URL
        XCTAssertTrue(streamingPlayer.validateStreamURL("http://example.com/stream.m3u8"))
        
        // Test valid HTTPS URL
        XCTAssertTrue(streamingPlayer.validateStreamURL("https://example.com/stream.m3u8"))
        
        // Test valid RTSP URL
        XCTAssertTrue(streamingPlayer.validateStreamURL("rtsp://example.com/stream"))
        
        // Test valid RTMP URL
        XCTAssertTrue(streamingPlayer.validateStreamURL("rtmp://example.com/stream"))
        
        // Test invalid URL
        XCTAssertFalse(streamingPlayer.validateStreamURL("invalid-url"))
        
        // Test unsupported scheme
        XCTAssertFalse(streamingPlayer.validateStreamURL("ftp://example.com/file.mp4"))
        
        // Test empty URL
        XCTAssertFalse(streamingPlayer.validateStreamURL(""))
    }
    
    func testPlayerControls() throws {
        // Test that player controls don't crash
        XCTAssertNoThrow(streamingPlayer.play())
        XCTAssertNoThrow(streamingPlayer.pause())
        XCTAssertNoThrow(streamingPlayer.stop())
        XCTAssertNoThrow(streamingPlayer.setVolume(0.5))
    }
    
    func testPlayerState() throws {
        // Initially, player should not be playing
        XCTAssertFalse(streamingPlayer.isPlaying)
        
        // Current time and duration should be nil initially
        XCTAssertNil(streamingPlayer.currentTime)
        XCTAssertNil(streamingPlayer.duration)
    }
    
    func testStreamConnectivityWithValidHTTPURL() throws {
        let expectation = self.expectation(description: "Stream connectivity test")
        
        // Use a known working test URL
        streamingPlayer.testStreamConnectivity("https://httpbin.org/status/200") { isReachable in
            XCTAssertTrue(isReachable)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    
    func testStreamConnectivityWithInvalidHTTPURL() throws {
        let expectation = self.expectation(description: "Stream connectivity test with invalid URL")
        
        // Use a URL that should return 404
        streamingPlayer.testStreamConnectivity("https://httpbin.org/status/404") { isReachable in
            XCTAssertFalse(isReachable)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    
    func testStreamConnectivityWithRTSPURL() throws {
        let expectation = self.expectation(description: "RTSP connectivity test")
        
        // RTSP URLs should return true (assuming they're valid for this test)
        streamingPlayer.testStreamConnectivity("rtsp://example.com/stream") { isReachable in
            XCTAssertTrue(isReachable) // RTSP is assumed valid in our implementation
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testSetupPlayerWithValidURL() throws {
        let containerView = UIView()
        
        // Test that setup doesn't crash with valid URL
        XCTAssertNoThrow(streamingPlayer.setupPlayer(in: containerView, with: "https://example.com/stream.m3u8"))
    }
    
    func testSetupPlayerWithInvalidURL() throws {
        let containerView = UIView()
        
        // Test that setup handles invalid URL gracefully
        XCTAssertNoThrow(streamingPlayer.setupPlayer(in: containerView, with: "invalid-url"))
    }
    
    func testSetupPlayerViewControllerWithValidURL() throws {
        let containerView = UIView()
        
        // Test that setup doesn't crash with valid URL
        XCTAssertNoThrow(streamingPlayer.setupPlayerViewController(in: containerView, with: "https://example.com/stream.m3u8"))
    }
}