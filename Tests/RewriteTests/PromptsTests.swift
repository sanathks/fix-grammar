import XCTest
@testable import Rewrite

final class PromptsTests: XCTestCase {

    // MARK: - Rewrite Prompt

    func testRewritePromptUsesModePrompt() {
        let mode = RewriteMode(id: UUID(), name: "Clarity", prompt: "Make it clear")
        let prompt = Prompts.rewrite(mode: mode, text: "test input")
        XCTAssertTrue(prompt.contains("Make it clear"))
    }

    func testRewritePromptContainsInputText() {
        let mode = RewriteMode(id: UUID(), name: "Clarity", prompt: "Make it clear")
        let prompt = Prompts.rewrite(mode: mode, text: "test input")
        XCTAssertTrue(prompt.contains("test input"))
    }

    func testRewriteMyToneUsesSpecialHandling() {
        let mode = RewriteMode(id: UUID(), name: "My Tone", prompt: "casual and friendly")
        let prompt = Prompts.rewrite(mode: mode, text: "test")
        XCTAssertTrue(prompt.contains("match this tone"))
        XCTAssertTrue(prompt.contains("casual and friendly"))
    }

    func testRewriteMyToneContainsGrammarFix() {
        let mode = RewriteMode(id: UUID(), name: "My Tone", prompt: "casual")
        let prompt = Prompts.rewrite(mode: mode, text: "test")
        XCTAssertTrue(prompt.contains("Fix any grammar, spelling, and punctuation errors"))
    }

    func testRewriteNonMyToneDoesNotContainMatchTone() {
        let mode = RewriteMode(id: UUID(), name: "Professional", prompt: "Be professional")
        let prompt = Prompts.rewrite(mode: mode, text: "test")
        XCTAssertFalse(prompt.contains("match this tone"))
    }

    func testRewritePromptContainsNoDashesInstruction() {
        let mode = RewriteMode(id: UUID(), name: "Clarity", prompt: "Make it clear")
        let prompt = Prompts.rewrite(mode: mode, text: "test")
        XCTAssertTrue(prompt.contains("Never use em dashes or semicolons"))
    }

    func testRewritePromptContainsReturnOnlyInstruction() {
        let mode = RewriteMode(id: UUID(), name: "Clarity", prompt: "Make it clear")
        let prompt = Prompts.rewrite(mode: mode, text: "test")
        XCTAssertTrue(prompt.contains("Return ONLY the rewritten text"))
    }

    func testFixGrammarModeWorksThroughRewrite() {
        let mode = RewriteMode(
            id: Settings.fixGrammarModeId,
            name: "Fix Grammar",
            prompt: "Fix any grammar, spelling, and punctuation errors in the following text. Never use em dashes or semicolons. Use commas or periods instead. Preserve the original meaning, tone, and formatting."
        )
        let prompt = Prompts.rewrite(mode: mode, text: "she dont like it")
        XCTAssertTrue(prompt.contains("Fix any grammar, spelling, and punctuation errors"))
        XCTAssertTrue(prompt.contains("she dont like it"))
        XCTAssertTrue(prompt.contains("Never use em dashes or semicolons"))
    }
}
