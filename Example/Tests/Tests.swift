import XCTest
import RxSwift
import RxBlocking
import RxAlamofire_Decodable

struct AnyDecodable: Decodable {
    var message: String
}

class Tests: XCTestCase {
    
    var response: HTTPURLResponse!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.response = HTTPURLResponse(
            url: URL(fileURLWithPath: "/"),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecodeInvalidJSONResponse() {
        let decodables = try? Observable<(HTTPURLResponse, Any)>.just((response, [:]))
            .decodable(as: AnyDecodable.self)
            .toBlocking()
            .toArray()
        XCTAssertNil(decodables)
    }
    
    func testDecodeValidJSONResponse() {
        let decodables = try? Observable<(HTTPURLResponse, Any)>.just((response, ["message": "hello"]))
            .decodable(as: AnyDecodable.self)
            .toBlocking()
            .toArray()
        XCTAssertNotNil(decodables)
        if let decodables = decodables {
            XCTAssertEqual(decodables.count, 1)
            XCTAssertEqual(decodables.first?.message, "hello")
        }
    }
}
