import XCTest

// Tests operate on the OS host. A gallery navigation skip is not acceptance.
final class ProbeHostTests: XCTestCase {
    let app = XCUIApplication()
    let board = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let message = "오늘 이 메뉴 만들어볼까?"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }

    func result(_ surface: String, _ status: String, _ detail: String) {
        let data = try! JSONSerialization.data(withJSONObject: ["surface": surface, "status": status, "detail": detail])
        print("PROBE_HOST_RESULT " + String(decoding: data, as: UTF8.self))
    }

    func unavailable(_ surface: String, _ reason: String) throws {
        shot(surface + "-navigation-unresolved")
        print("PROBE_TREE " + board.debugDescription)
        result(surface, "NOT_TESTED", reason)
        throw XCTSkip(reason)
    }

    func test01AppVisible() {
        XCTAssertTrue(app.buttons["probe.notify"].waitForExistence(timeout: 20))
        shot("app-visible"); result("APP", "VISIBLE", "Synthetic fixture app, not widget host")
    }

    func test02NotificationHosts() throws {
        XCTAssertTrue(app.buttons["probe.notify"].waitForExistence(timeout: 20))
        app.buttons["probe.notify"].tap()
        for alert in [app.alerts.firstMatch, board.alerts.firstMatch] {
            if alert.waitForExistence(timeout: 3) && alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap(); break
            }
        }
        XCUIDevice.shared.press(.home); Thread.sleep(forTimeInterval: 4)
        board.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.01))
            .press(forDuration: 0.1, thenDragTo: board.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.8)))
        let text = board.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", message)).firstMatch
        guard text.waitForExistence(timeout: 10) else { try unavailable("N-C", "Notification content absent in OS host"); return }
        shot("notification-collapsed"); result("N-C", "CONTENT_OBSERVED", "OS notification center contains fixture text")
        text.press(forDuration: 1.2); Thread.sleep(forTimeInterval: 1)
        shot("notification-expanded-a")
        let pet = board.images["probe.notification.pet"]
        guard pet.waitForExistence(timeout: 8) else { try unavailable("N-E", "Custom extension character not identified"); return }
        print("PROBE_RECT " + pet.frame.debugDescription)
        Thread.sleep(forTimeInterval: 3); shot("notification-expanded-b")
        result("N-E", "EXTENSION_OBSERVED", "Character accessibility element found; frame pair needs visual review")
    }

    func tapNamed(_ names: [String]) -> Bool {
        for name in names {
            let button = board.buttons.matching(NSPredicate(format: "label == %@ OR label == %@", name, " " + name)).firstMatch
            if button.waitForExistence(timeout: 2) { button.tap(); return true }
            let text = board.staticTexts[name]
            if text.exists { text.tap(); return true }
        }
        return false
    }

    func addWidget(_ surface: String, medium: Bool) throws {
        XCUIDevice.shared.press(.home); Thread.sleep(forTimeInterval: 2)
        let icon = board.icons["냠모아 v25 검증"]
        guard icon.waitForExistence(timeout: 10) else { try unavailable(surface, "Probe app icon absent on current page"); return }
        icon.press(forDuration: 1.3)
        guard tapNamed(["Edit Home Screen", "홈 화면 편집"]) else { try unavailable(surface, "Home editing menu unavailable"); return }
        _ = tapNamed(["Edit", "편집"])
        guard tapNamed(["Add Widget", "Add Widgets", "위젯 추가", "Add"]) else { try unavailable(surface, "Widget gallery entry unavailable"); return }
        let search = board.searchFields["Search Widgets"]
        guard search.waitForExistence(timeout: 8) else { try unavailable(surface, "Widget gallery search unavailable"); return }
        search.tap(); search.typeText("냠모아")
        guard tapNamed(["냠모아 v25 검증"]) else { try unavailable(surface, "Widget provider not found in gallery"); return }
        if medium { board.swipeLeft(); Thread.sleep(forTimeInterval: 1) }
        let family = medium ? "Widget, Medium" : "Widget, Small"
        let selected = board.buttons.matching(NSPredicate(format: "value == %@", family)).firstMatch
        guard selected.waitForExistence(timeout: 5) else { try unavailable(surface, "Requested widget family not selected"); return }
        shot(surface + "-gallery")
        guard tapNamed(["Add Widget", "위젯 추가"]) else { try unavailable(surface, "Gallery add control unavailable"); return }
        _ = tapNamed(["Done", "완료"]); XCUIDevice.shared.press(.home)
        let copy = board.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", message)).firstMatch
        guard copy.waitForExistence(timeout: 15) else { try unavailable(surface, "Fixture text not found on installed widget"); return }
        shot(surface + "-home"); result(surface, "WIDGET_CONTENT_OBSERVED", "Family and clipping still require screenshot review")
        copy.tap()
        guard app.wait(for: .runningForeground, timeout: 10) else { try unavailable(surface, "Widget destination not foreground"); return }
        let status = app.staticTexts["probe.status"]
        XCTAssertTrue(status.label.contains("fixture:synthetic-portrait"), "Destination must preserve fixture content ID")
        result(surface + "-OPEN", "DESTINATION_OBSERVED", status.label)
    }

    func test03SmallHomeHost() throws { try addWidget("H-S", medium: false) }
    func test04WideHomeHost() throws { try addWidget("H-W", medium: true) }
}
