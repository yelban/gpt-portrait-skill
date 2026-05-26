---
description: 產生 gpt-image-2 / Gemini-3 / Grok 寫真 prompt（強制觸發 gpt-image-portrait-prompt skill，跳過 trigger 機制偏差）
argument-hint: <需求描述，例：美背 9:16 高級感 / 用 gemini-3-pro 畫新中式女性 / reference image 換場景>
---

執行 `gpt-image-portrait-prompt` skill 處理以下需求：

$ARGUMENTS

## 強制步驟

1. **必須先 Read** `skills/gpt-image-portrait-prompt/SKILL.md`，禁止憑記憶寫 prompt
2. 依需求判讀使用哪個模型（gpt-image-2 / gemini-3-pro / gemini-3.1-flash / grok-imagine），若使用者未指定預設 `gpt-image-2`
3. 套用 SKILL.md 五段式結構（Scene / Subject / Details / Lighting / Use case / Constraints）
4. 套用 §17.3 四層防禦 + §17.4 物理瑕疵 Constraints
5. 套用對應模型的尺寸規則（gpt-image-2 16 倍數、Gemini tier 制、Grok preset）
6. 若需求觸發 §27 反繞過聲明或 §2 組合詞風險，**直接拒絕**並提供 §25 安全替代方向
7. 輸出最終 PROMPT + PARAMETERS（或拒絕回覆），格式照 SKILL.md §20

## 輸出規則

- 不要解釋你做了什麼
- 不要解釋為什麼這樣寫
- 只輸出最終 PROMPT + PARAMETERS（依使用者要求若需 API payload JSON 也附上）
- 若拒絕則只輸出拒絕原因 + 2-3 個安全替代方向

## 模型未指定時的選擇

| 場景 | 推薦模型 |
|------|---------|
| 預設 / 不確定 | `gpt-image-2`（旗艦、彈性尺寸、reference up to 16）|
| 要快 / 要便宜 | `gemini-3.1-flash-image-preview`（~28s，多 tier）|
| 要 narrative 寫實感、Vertex AI 環境 | `gemini-3-pro-image-preview` |
| X / Grok 平台、reference ≤ 3 | `grok-imagine-image-quality` |
