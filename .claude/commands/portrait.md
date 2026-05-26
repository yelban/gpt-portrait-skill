---
description: 產生 gpt-image-2 / Gemini-3 / Grok 寫真 prompt（強制觸發 gpt-image-portrait-prompt skill，跳過 trigger 機制偏差）
argument-hint: <需求描述，例：美背 9:16 高級感 / 用 gemini-3-pro 畫新中式女性 / reference image 換場景>
---

執行 `gpt-image-portrait-prompt` skill 處理以下需求：

$ARGUMENTS

## 強制步驟

1. **必須先 Read** `skills/gpt-image-portrait-prompt/SKILL.md`，禁止憑記憶寫 prompt
2. 依需求判讀使用哪個模型（gpt-image-2 / gemini-3-pro / gemini-3.1-flash / grok-imagine），若使用者未指定預設 `gpt-image-2`
3. **判斷 Mode A vs Mode B**（依 SKILL.md §3.1）：
   - 簡單請求 → **Mode A**（PROMPT + PARAMETERS 兩段）
   - 完整參數表 / 精修 / 商業寫真 / 指定五官 / 豐腴曲線 → **Mode B**（5 段輸出含參數覆核）
4. **缺參數時啟動互動補完**（依 §3.2）：
   - Claude Code 環境 → 用 AskUserQuestion 工具，每輪 ≤ 2 題
   - 其他環境 → fallback 用 markdown 編號清單請使用者回覆
5. **執行參數鎖定覆核**（依 §3.3，Mode B 必做）：使用者填寫的參數禁止替換 / 弱化 / 改寫；只有「自動 / 留空」才能 auto-complete
6. 套用 SKILL.md 五段式結構（Scene / Subject / Details / Lighting / Use case / Constraints）
7. 套用 §17.3 四層防禦 + §17.4 物理瑕疵 Constraints
8. 套用對應模型的尺寸規則（gpt-image-2 16 倍數、Gemini tier 制、Grok preset）
9. 若指定五官方向，依 §28 抽取對應 7 維度描述詞（臉型 / 眼型 / 鼻型 / 唇型 / 骨相 / 表情 / 神韻），禁止跨方向混搭
10. 若風格 × 五官衝突，依 §29 6 條原則調和（保留兩者、調整妝容 / 表情 / 光線 / 服裝 / 氣質）
11. 若觸發 §27 反繞過聲明 / §2 組合詞風險 / §29 不可調和衝突，**直接拒絕** + 提供 §25 安全替代方向
12. 輸出最終結果（Mode A：§20 PROMPT + PARAMETERS；Mode B：§20 5 段格式；拒絕：理由 + 替代）

## 輸出規則

- 不要解釋你做了什麼（除了 Mode B 的「自動補全標註」段）
- 不要解釋為什麼這樣寫
- Mode A：只輸出 PROMPT + PARAMETERS（依使用者要求若需 API payload JSON 也附上）
- Mode B：完整 5 段格式，含參數覆核 / Prompt / 自動補全 / 吸睛點 / 負面詞
- 若拒絕：只輸出拒絕原因 + 2-3 個安全替代方向

## 模型未指定時的選擇

| 場景 | 推薦模型 |
|------|---------|
| 預設 / 不確定 | `gpt-image-2`（旗艦、彈性尺寸、reference up to 16）|
| 要快 / 要便宜 | `gemini-3.1-flash-image-preview`（~28s，多 tier）|
| 要 narrative 寫實感、Vertex AI 環境 | `gemini-3-pro-image-preview` |
| X / Grok 平台、reference ≤ 3 | `grok-imagine-image-quality` |
