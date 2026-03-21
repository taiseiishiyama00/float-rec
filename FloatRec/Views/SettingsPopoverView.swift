import SwiftUI

struct SettingsPopoverView: View {
    @ObservedObject var settings: RecordingSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            LabeledContent("Quality") {
                Picker("", selection: $settings.resolutionScale) {
                    Text("1x").tag(1)
                    Text("Retina").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }

            LabeledContent("FPS") {
                Picker("", selection: $settings.fps) {
                    Text("30").tag(30)
                    Text("60").tag(60)
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
        }
        .padding(16)
        .frame(width: 240)
    }
}
