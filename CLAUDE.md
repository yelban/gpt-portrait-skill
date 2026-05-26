# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Notes that complement Claude Code's built-in guidance. Apply to code work; for non-code tasks (writing, docs, design), use judgment.

## Stop when confused

If a request is ambiguous, name what is unclear and ask. Do not pick an interpretation silently. This applies *before* writing code, not after the fact.

## Every changed line should trace to the request

Before reporting done, re-read your own diff. If a line does not directly serve the user's stated goal, remove it. This is the working definition of "surgical changes."

## Loop on declarative goals

When the user gives a verifiable end state (tests pass, output matches, lint clean, benchmark below X), drive toward it autonomously. When they give imperative steps, follow them.

If the request is imperative but an obvious success criterion exists, propose the declarative version first ("I can verify this by Y — okay to drive toward that?") rather than guessing.

Users can invoke this reframing explicitly with the `dec` slash command: `/dec <request>` when installed standalone, or `/andrej-karpathy-skills:dec <request>` when installed via the plugin. See README for install options.

## 程式碼結構查詢路由

優先順序（從上到下匹配）：

1. **概念性 / 自然語言提問**（「X 怎麼實作的？」「Y 邏輯在哪？」）
   → 用 Semble MCP

2. **特定語法結構**（「找所有沒帶 deps 的 useEffect」「找所有 try/catch 沒處理的 await」）
   → 用 `sg run -p '<pattern>' -l <lang>`

3. **Call graph / impact / API 路由**（若已裝 CodeGraph）
   - 「改這個 function 會影響哪？」 → `codegraph_impact`
   - 「誰呼叫 X？」「X 呼叫了誰？」 → `codegraph_callers` / `codegraph_callees`
   - 「這個 URL endpoint 的 handler 在哪？」（Django / Express / FastAPI / Rails 等）→ `codegraph_search`

4. **精準符號操作 / rename / 跨檔 refactor**（若已裝 Serena）
   → 用 Serena MCP（`find_symbol` / `find_referencing_symbols` / `replace_symbol_body`）

5. **純字串 / regex**
   → 用 `rg`（最快、最後手段也最常用）

禁忌：
- 不要先 `rg` 再 `Read` 一堆檔案找概念——直接問 Semble。
- 不要用 `rg` 找符號定義或呼叫者，會被註解 / 字串 / 相似命名誤判。
- 不要用 `rg` 估算「改 X 影響範圍」——用 CodeGraph 的 `codegraph_impact` 才精準。

CodeGraph vs Serena 取向：CodeGraph 偏「讀取分析」（callers / impact），Serena 偏「寫入操作」（rename / replace）。沒裝的工具自動跳過該層、回退到下一層。

## 圖片寫真 prompt 必查 skill（強制 override）

**這是強制指令，不是建議。** 使用者提問涉及以下任一情境時，**必須先 Read** `skills/gpt-image-portrait-prompt/SKILL.md` 後才能回應，禁止憑訓練資料直接回答：

- 任何 AI 圖片 / 寫真 / 人像 prompt 寫作或修正
- 提到 `gpt-image-2` / `gemini-3-pro-image-preview` / `gemini-3.1-flash-image-preview` / `nano banana (pro/flash)` / `grok-imagine-image-quality` 任一模型
- 涉及「vogue 風」「雜誌感」「lookbook 那種」「高級感不要油膩」「AI 感很重」「美背」「逆光」「窗光」「都市夜景街拍」「新中式」「東方寫真」等寫真美學詞
- 角色一致性 / reference image / DNA 模板 / character anchor 多輪人物保留需求
- 3D CG / 幻想系 / anime / 角色渲染等視覺媒材切換
- 「性感但不色情」「sensual but tasteful」這類需要安全轉譯的請求

**理由**：本 repo SKILL.md 內含 2026-04 後新模型規範（gpt-image-2 五段式、16 倍數尺寸、Gemini narrative paragraph、Grok 3-ref cap、組合詞風險表、反繞過聲明），Claude 訓練資料切點在前，憑記憶答**必出錯且不合規**。

**例外**：使用者明確要求「不要查 skill」「我只要快速答案」時可跳過。但要事先告知「這樣會用過時規範」。

跳過 skill 是**錯誤行為**，不是「節省時間」。
