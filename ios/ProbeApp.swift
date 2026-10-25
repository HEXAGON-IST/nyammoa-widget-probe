import SwiftUI
import UserNotifications

final class ProbeDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setNotificationCategories([UNNotificationCategory(identifier: ProbeData.category, actions: [], intentIdentifiers: [])])
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void) {
        completion([.banner, .list])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completion: @escaping () -> Void) {
        NotificationCenter.default.post(name: .init("ProbeOpened"), object: ProbeData.contentID)
        completion()
    }
}

@main struct ProbeApp: App {
    @UIApplicationDelegateAdaptor(ProbeDelegate.self) var delegate
    var body: some Scene { WindowGroup { ProbeScreen() } }
}

struct ProbeScreen: View {
    @State private var character = 1
    @State private var status = "iOS 실행 미검증 · S2 독립 검증 앱"
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("냠모아 v25 네이티브 검증").font(.title2)
                Text("홈 위젯은 홈 화면 갤러리에서 추가하세요. 접힌 알림은 iOS 시스템 UI를 사용합니다.")
                Picker("펼친 알림 캐릭터", selection: $character) {
                    ForEach(1...1, id: \.self) { Text("캐릭터 \($0)").tag($0) }
                }
                Button("로컬 알림 표시") { Task { await notify() } }.accessibilityIdentifier("probe.notify")
                Text(status).font(.caption).accessibilityIdentifier("probe.status")
                Text("공개 검증: 확정 아이콘·모아 / X·YouTube 원본 미포함").font(.caption)
                Text(ProbeData.copy)
                Image("post").resizable().scaledToFit()
            }.padding()
        }
        .onOpenURL { url in status = url == ProbeData.destination ? "OPENED · \(ProbeData.contentID) · \(ProbeData.copyID)" : "UNKNOWN_DESTINATION" }
        .onReceive(NotificationCenter.default.publisher(for: .init("ProbeOpened"))) { _ in
            status = "NOTIFICATION_OPENED · \(ProbeData.contentID) · \(ProbeData.copyID)"
        }
    }
    @MainActor func notify() async {
        do {
            let center = UNUserNotificationCenter.current()
            guard try await center.requestAuthorization(options: [.alert, .badge]) else { status = "알림 권한을 허용해야 검증할 수 있어요"; return }
            let content = UNMutableNotificationContent()
            content.title = "냠모아"; content.body = ProbeData.copy
            content.categoryIdentifier = ProbeData.category
            content.userInfo = ["character": character, "contentID": ProbeData.contentID, "copyID": ProbeData.copyID]
            if let url = Bundle.main.url(forResource: "post", withExtension: "png") {
                content.attachments = [try UNNotificationAttachment(identifier: "post", url: url)]
            }
            try await center.add(UNNotificationRequest(identifier: "visual25", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)))
            status = "2초 후 알림 · 길게 눌러 펼친 영역을 확인하세요"
        } catch { status = "알림 검증 실패: \(error.localizedDescription)" }
    }
}
