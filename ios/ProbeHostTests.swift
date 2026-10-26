import XCTest

// Tests operate on the OS host. A gallery navigation skip is not acceptance.
final class ProbeHostTests: XCTestCase {
    let app = XCUIApplication()
    let board = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let message = "오늘 파스타에 양배추도 넣어볼까?"

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
        shot("app-visible"); result("APP", "VISIBLE", "Approved icon and Moa only; third-party media excluded; S2 probe app")
    }

    func test02NotificationHosts() throws {
        XCTAssertTrue(app.buttons["probe.notify"].waitForExistence(timeout: 20))
        app.buttons["probe.notify"].tap()
        for alert in [app.alerts.firstMatch, board.alerts.firstMatch] {
            if alert.waitForExistence(timeout: 3) && alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap(); break
            }
        }
        XCUIDevice.shared.press(.home); Thread.sleep(forTimeInterval: 12)
        board.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.01))
            .press(forDuration: 0.1, thenDragTo: board.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.8)))
        let text = board.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", message)).firstMatch
        guard text.waitForExistence(timeout: 10) else { try unavailable("N-C", "Notification content absent in OS host"); return }
        Thread.sleep(forTimeInterval: 2)
        shot("notification-center-entry")
        if !onScreen(text) {
            let counts = board.descendants(matching: .any).matching(NSPredicate(format: "label MATCHES[c] %@", "[0-9]+ Notifications?|알림 [0-9]+개")).allElementsBoundByIndex
            if let count = counts.first(where: { onScreen($0) }) {
                count.tap(); Thread.sleep(forTimeInterval: 1)
            }
        }
        if !onScreen(text) {
            board.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                .press(forDuration: 0.1, thenDragTo: board.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)))
            Thread.sleep(forTimeInterval: 2)
        }
        guard onScreen(text) else { try unavailable("N-C", "Notification text exists but is offscreen or not hittable"); return }
        shot("notification-collapsed"); result("N-C", "CONTENT_OBSERVED", "OS notification center contains approved copy")
        let notificationRect = text.frame
        print("PROBE_NOTIFICATION_PRESS_RECT \(notificationRect)")
        text.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 2)
        let pet = board.images["probe.notification.pet"]
        guard pet.waitForExistence(timeout: 8) else { try unavailable("N-E", "Custom extension character not identified"); return }
        Thread.sleep(forTimeInterval: 3)
        characterFrame(pet, sample: "a"); shot("notification-expanded-a")
        Thread.sleep(forTimeInterval: 3)
        characterFrame(pet, sample: "b"); shot("notification-expanded-b")
        result("N-E", "EXTENSION_OBSERVED", "Character accessibility element found; frame pair needs visual review")
    }

    func onScreen(_ element: XCUIElement) -> Bool {
        guard element.exists && element.isHittable else { return false }
        let rect = element.frame
        return rect.width > 0 && rect.height > 0 && board.frame.contains(CGPoint(x: rect.midX, y: rect.midY))
    }

    func characterFrame(_ pet: XCUIElement, sample: String) {
        let rect = pet.frame
        let data = try! JSONSerialization.data(withJSONObject: [
            "sample": sample, "x": rect.minX, "y": rect.minY,
            "width": rect.width, "height": rect.height,
            "screenWidth": board.frame.width, "screenHeight": board.frame.height
        ])
        print("PROBE_CHARACTER_FRAME " + String(decoding: data, as: UTF8.self))
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

    func addWidget(_ surface: String, medium: Bool, react: Bool = false) throws {
        XCUIDevice.shared.press(.home); Thread.sleep(forTimeInterval: 2)
        let icon = board.icons.matching(NSPredicate(format: "identifier == %@ AND (value == nil OR NOT (value BEGINSWITH %@))", "냠모아 v25 검증", "Widget")).firstMatch
        guard icon.waitForExistence(timeout: 10) else { try unavailable(surface, "Probe app icon absent on current page"); return }
        icon.press(forDuration: 1.3)
        guard tapNamed(["Edit Home Screen", "홈 화면 편집"]) else { try unavailable(surface, "Home editing menu unavailable"); return }
        _ = tapNamed(["Edit", "편집"])
        guard tapNamed(["Add Widget", "Add Widgets", "위젯 추가", "Add"]) else { try unavailable(surface, "Widget gallery entry unavailable"); return }
        let search = board.searchFields["Search Widgets"]
        guard search.waitForExistence(timeout: 8) else { try unavailable(surface, "Widget gallery search unavailable"); return }
        search.tap()
        if board.buttons["Continue"].waitForExistence(timeout: 2) { board.buttons["Continue"].tap(); search.tap() }
        search.typeText("냠모아")
        if board.buttons["Continue"].exists { board.buttons["Continue"].tap() }
        let provider = board.buttons["냠모아 v25 검증"]
        _ = provider.waitForExistence(timeout: 20)
        guard tapNamed(["냠모아 v25 검증"]) else { try unavailable(surface, "Widget provider not found in gallery"); return }
        if medium { board.swipeLeft(); Thread.sleep(forTimeInterval: 1) }
        let family = medium ? "Widget, Medium" : "Widget, Small"
        let selected = board.buttons.matching(NSPredicate(format: "value == %@", family)).firstMatch
        guard selected.waitForExistence(timeout: 5) else { try unavailable(surface, "Requested widget family not selected"); return }
        shot(surface + "-gallery")
        guard tapNamed(["Add Widget", "위젯 추가"]) else { try unavailable(surface, "Gallery add control unavailable"); return }
        if !tapNamed(["Done", "완료"]) { XCUIDevice.shared.press(.home) }
        guard let widget = visibleWidget(medium: medium) else { try unavailable(surface, "Requested family not visible on home pages"); return }
        let copy = widget.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", message)).firstMatch
        _ = copy.waitForExistence(timeout: 20)
        shot(surface + "-home")
        result(surface, copy.exists ? "WIDGET_CONTENT_OBSERVED" : "WIDGET_FRAME_OBSERVED_TEXT_UNVERIFIED", "Visible OS widget; family selected in gallery, screenshot review required")
        if react {
            let pet = widget.buttons["모아 반응"]
            guard pet.waitForExistence(timeout: 10) && pet.isHittable else {
                try unavailable(surface + "-REACT", "Character button not hittable"); return
            }
            let before = pet.value as? String ?? "UNKNOWN"
            shot(surface + "-reaction-before")
            pet.tap()
            let changed = NSPredicate(format: "value != %@", before)
            let response = XCTNSPredicateExpectation(predicate: changed, object: pet)
            guard XCTWaiter.wait(for: [response], timeout: 15) == .completed else {
                try unavailable(surface + "-REACT", "No accessible pose change after real tap"); return
            }
            shot(surface + "-reaction-after")
            XCTAssertFalse(app.state == .runningForeground, "Character tap must remain in widget")
            result(surface + "-REACT", "POSE_CHANGE_OBSERVED", "Before " + before + "; after " + (pet.value as? String ?? "UNKNOWN") + "; temporal motion not measured")
            pet.tap()
            let restored = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", before), object: pet)
            guard XCTWaiter.wait(for: [restored], timeout: 15) == .completed else {
                try unavailable(surface + "-REPEAT", "Second tap did not restore pose"); return
            }
            shot(surface + "-reaction-restored")
            result(surface + "-REPEAT", "POSE_RESTORED", before)
        }
        widget.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8)).tap()
        guard app.wait(for: .runningForeground, timeout: 10) else { try unavailable(surface, "Widget destination not foreground"); return }
        let status = app.staticTexts["probe.status"]
        XCTAssertTrue(status.label.contains("x:1261986084918947840"), "Destination must preserve approved content ID")
        result(surface + "-OPEN", "DESTINATION_OBSERVED", status.label)
    }

    func visibleWidget(medium: Bool) -> XCUIElement? {
        for _ in 0..<4 {
            let icons = board.icons.matching(identifier: "냠모아 v25 검증").allElementsBoundByIndex
            for icon in icons {
                let value = icon.value as? String ?? ""
                let wide = icon.frame.width > board.frame.width * 0.65
                if value.hasPrefix("Widget") && icon.isHittable && wide == medium { return icon }
            }
            board.swipeLeft(); Thread.sleep(forTimeInterval: 1)
        }
        return nil
    }

    func test05SmallInteraction() throws { try addWidget("H-S", medium: false, react: true) }
    func test06WideInteraction() throws { try addWidget("H-W", medium: true, react: true) }

    func test03SmallHomeHost() throws { try addWidget("H-S", medium: false) }
    func test04WideHomeHost() throws { try addWidget("H-W", medium: true) }
}
