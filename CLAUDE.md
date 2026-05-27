# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# === gpt-portrait-skill 強制 override 區段開始 ===
## 圖片寫真 prompt 必查 skill（強制 override）

**這是強制指令，不是建議。** 使用者提問涉及以下任一情境時，**必須透過 `Skill` 工具呼叫 `gpt-image-portrait-prompt` skill 後才能回應**（skill 會自行載入 SKILL.md），禁止憑訓練資料直接回答：

- 任何 AI 圖片 / 寫真 / 人像 prompt 寫作或修正
- 提到 `gpt-image-2` / `gemini-3-pro-image-preview` / `gemini-3.1-flash-image-preview` / `nano banana (pro/flash)` / `grok-imagine-image-quality` 任一模型
- 涉及「vogue 風」「雜誌感」「lookbook 那種」「高級感不要油膩」「AI 感很重」「美背」「逆光」「窗光」「都市夜景街拍」「新中式」「東方寫真」等寫真美學詞
- 角色一致性 / reference image / DNA 模板 / character anchor 多輪人物保留需求
- 3D CG / 幻想系 / anime / 角色渲染等視覺媒材切換
- 「性感但不色情」「sensual but tasteful」這類需要安全轉譯的請求

**理由**：本 repo SKILL.md 內含 2026-04 後新模型規範（gpt-image-2 五段式、16 倍數尺寸、Gemini narrative paragraph、Grok 3-ref cap、組合詞風險表、反繞過聲明），Claude 訓練資料切點在前，憑記憶答**必出錯且不合規**。

**例外**：使用者明確要求「不要查 skill」「我只要快速答案」時可跳過。但要事先告知「這樣會用過時規範」。

跳過 skill 是**錯誤行為**，不是「節省時間」。
