enum PromptMode {
    case grammar
    case tone
}

enum Prompts {
    static func build(for mode: PromptMode, text: String) -> String {
        switch mode {
        case .grammar:
            return """
            Fix any grammar, spelling, and punctuation errors in the following text. \
            Preserve the original meaning, tone, and formatting. \
            Return ONLY the corrected text. \
            Do NOT wrap output in quotes or markdown formatting. \
            Do NOT add any explanations or comments.

            \(text)
            """
        case .tone:
            let tone = Settings.shared.toneDescription
            return """
            Rewrite the following text to match this tone: \(tone). \
            Fix any grammar, spelling, and punctuation errors in the process. \
            Preserve the original meaning and key information. \
            Return ONLY the rewritten text. \
            Do NOT wrap output in quotes or markdown formatting. \
            Do NOT add any explanations or comments.

            \(text)
            """
        }
    }
}
