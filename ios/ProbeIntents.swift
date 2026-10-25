import AppIntents
import WidgetKit

enum ProbeCharacter: Int, AppEnum {
    case moa = 1, second = 2, third = 3, fourth = 4
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "캐릭터"
    static var caseDisplayRepresentations: [ProbeCharacter: DisplayRepresentation] = [.moa: "모아", .second: "캐릭터 2", .third: "캐릭터 3", .fourth: "캐릭터 4"]
}
struct ProbeConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "냠모아 검증 설정"
    @Parameter(title: "캐릭터", default: .moa) var character: ProbeCharacter
}
struct ReactIntent: AppIntent {
    static var title: LocalizedStringResource = "모아 반응"
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults.standard
        defaults.set(!defaults.bool(forKey: "reaction"), forKey: "reaction")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
