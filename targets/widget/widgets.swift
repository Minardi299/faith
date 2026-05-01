import WidgetKit
import SwiftUI

struct Verse: Decodable {
    let number: Int
    let chapter: Int
    let chapterPali: String
    let chapterTitle: String
    let storyTitle: String
    let storyPaliName: String
    let story: String
    let text: String
}

enum VerseLoader {
    static let all: [Verse] = {
        guard
            let url = Bundle.main.url(forResource: "dhammapada", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let verses = try? JSONDecoder().decode([Verse].self, from: data),
            !verses.isEmpty
        else { return [] }
        return verses
    }()

    static func verse(for date: Date) -> Verse? {
        guard !all.isEmpty else { return nil }
        let day = Int(date.timeIntervalSince1970 / 86_400)
        return all[((day % all.count) + all.count) % all.count]
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> VerseEntry {
        VerseEntry(date: Date(), configuration: ConfigurationAppIntent(), verse: VerseLoader.verse(for: Date()))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> VerseEntry {
        VerseEntry(date: Date(), configuration: configuration, verse: VerseLoader.verse(for: Date()))
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<VerseEntry> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86_400)

        let entry = VerseEntry(
            date: today,
            configuration: configuration,
            verse: VerseLoader.verse(for: today)
        )
        return Timeline(entries: [entry], policy: .after(tomorrow))
    }
}

struct VerseEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let verse: Verse?
}

struct widgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        if let verse = entry.verse {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Verse \(verse.number)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(verse.chapterTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text(verse.text)
                    .font(family == .systemSmall ? .caption : .footnote)
                    .lineLimit(family == .systemSmall ? 6 : 12)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
        } else {
            Text("No verse available")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Dhammapada")
        .description("A daily verse from the Dhammapada.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    widget()
} timeline: {
    VerseEntry(date: .now, configuration: ConfigurationAppIntent(), verse: VerseLoader.verse(for: .now))
}
