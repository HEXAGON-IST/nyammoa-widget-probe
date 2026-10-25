import SwiftUI
import WidgetKit
import AppIntents

struct ProbeEntry: TimelineEntry {
    let date: Date
    let character: Int
    let reaction: Bool
}
struct ProbeProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ProbeEntry { ProbeEntry(date: .now, character: 1, reaction: false) }
    func snapshot(for configuration: ProbeConfiguration, in context: Context) async -> ProbeEntry {
        NSLog("PROBE_WIDGET snapshot requested")
        return entry(configuration)
    }
    func timeline(for configuration: ProbeConfiguration, in context: Context) async -> Timeline<ProbeEntry> {
        NSLog("PROBE_WIDGET timeline requested")
        return Timeline(entries: [entry(configuration)], policy: .never)
    }
    private func entry(_ configuration: ProbeConfiguration) -> ProbeEntry {
        ProbeEntry(date: .now, character: configuration.character.rawValue, reaction: UserDefaults.standard.bool(forKey: "reaction"))
    }
}
struct ProbeWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ProbeEntry
    var pet: some View {
        Button(intent: ReactIntent()) {
            Image("pet_\(entry.character)_\(entry.reaction ? "b" : "a")").resizable().scaledToFit().frame(width: 72, height: 72)
                .rotationEffect(.degrees(entry.reaction ? -5 : 0))
                .animation(.spring(duration: 0.76), value: entry.reaction)
        }.buttonStyle(.plain)
    }
    var body: some View {
        Group {
            if family == .systemSmall {
                VStack(spacing: 6) { HStack(spacing: 4) { pet; Text(ProbeData.copy).font(.system(size: 11)) }; Image("post").resizable().scaledToFit() }
            } else {
                GeometryReader { geometry in
                    HStack(spacing: 8) {
                        Image("post").resizable().scaledToFit().frame(width: geometry.size.width * 0.54)
                        VStack(spacing: 6) { pet; Text(ProbeData.copy).font(.system(size: 12)).frame(maxWidth: .infinity, alignment: .leading) }.frame(maxWidth: .infinity)
                    }.frame(height: geometry.size.height)
                }
            }
        }.widgetURL(ProbeData.destination)
            .containerBackground(Color(red: 1, green: 0.988, blue: 0.961), for: .widget)
    }
}
@main struct ProbeWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MoaVisual25", intent: ProbeConfiguration.self, provider: ProbeProvider()) { entry in ProbeWidgetView(entry: entry) }
            .configurationDisplayName("냠모아 v25 검증").description("고정 시안의 작은·넓은 홈 검증용. 상시 반복 모션 없음.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
