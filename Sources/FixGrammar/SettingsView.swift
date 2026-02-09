import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared
    @State private var availableModels: [String] = []
    @State private var isLoadingModels = false
    @State private var isConnected = false
    @State private var hasAccessibility = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FixGrammar")
                .font(.headline)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Ollama URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    TextField("http://localhost:11434", text: $settings.ollamaURL)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        loadModels()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .controlSize(.small)
                    .disabled(isLoadingModels)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Model")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if availableModels.isEmpty {
                    HStack(spacing: 6) {
                        TextField("gemma3", text: $settings.modelName)
                            .textFieldStyle(.roundedBorder)
                        if isLoadingModels {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                } else {
                    Picker("", selection: $settings.modelName) {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .labelsHidden()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Tone Description")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextEditor(text: $settings.toneDescription)
                    .font(.body)
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Shortcuts (click to change)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ShortcutRecorder(label: "Fix Grammar", shortcut: $settings.grammarShortcut)
                ShortcutRecorder(label: "Add Tone", shortcut: $settings.toneShortcut)
            }

            Divider()

            HStack {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(isConnected ? "Ollama Connected" : "Ollama Disconnected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Circle()
                    .fill(hasAccessibility ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(hasAccessibility ? "Accessibility OK" : "Accessibility Required")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !hasAccessibility {
                    Spacer()
                    Button("Grant") {
                        AccessibilityService.requestPermission()
                    }
                    .controlSize(.small)
                }
            }

            Divider()

            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .controlSize(.small)
            }
        }
        .padding()
        .frame(width: 320)
        .onAppear {
            loadModels()
            hasAccessibility = AccessibilityService.isTrusted()
        }
    }

    private func loadModels() {
        isLoadingModels = true
        OllamaService.shared.fetchModels { models in
            DispatchQueue.main.async {
                availableModels = models
                isConnected = !models.isEmpty
                isLoadingModels = false
                if !models.isEmpty && !models.contains(settings.modelName) {
                    settings.modelName = models[0]
                }
            }
        }
    }
}
