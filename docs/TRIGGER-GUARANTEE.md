# Trigger Guarantee — 觸發率保證的工程現實

回答這個 skill 最常被問的問題：**「裝完真的能 100% 觸發嗎？」**

簡答：**在這個 repo 內、新 session、圖片寫真請求** 三個條件成立時，trigger ≈ 100%。但「100%」不是無條件——共 5 個前提條件。離開這個 repo（沒裝 H 強制 override）會退回 50-65%。

---

## TL;DR

| 場景 | trigger 率 |
|------|-----------|
| 在這個 repo cwd 內、自然 query | **≈100%** |
| `/portrait <需求>` 主動觸發 | **100%** |
| 照 INSTALLATION.md 裝 H + J + M 三層到別的 repo | **≈100%** |
| 只 cp 了 skill 本體、沒裝 H + J | **50-65%** ← M 描述觸發 ceiling |
| 用 Claude Code plugin 形式安裝（如未來提交 marketplace） | **50-65%** ← plugin 不能裝 H |

「100%」≠ 「無條件 100%」。下方解釋為什麼。

---

## 觸發決策流程圖

實際上 Claude 收到使用者 query 時的觸發判斷流程：

```mermaid
flowchart LR
    A[Query 進來] --> B{在這個 repo<br/>cwd 內?}
    B -- 是 --> C{新 session?<br/>CLAUDE.md 已載入?}
    C -- 是 --> D{圖片寫真 prompt<br/>類請求?}
    D -- 是 --> E{使用者沒說<br/>不要查 skill?}
    E -- 是 --> F[H 強制 override 生效<br/>≈100%]
    B -- 否 --> G[只剩 M 描述觸發<br/>50-65%]
    C -- 否 --> H[CLAUDE.md 未生效<br/>退回 50-65%]
    D -- 否 --> I[skill 本來就不該觸發]
    E -- 否 --> J[CLAUDE.md 內 escape hatch<br/>合法跳過]

    style F fill:#15803d,color:#fff,stroke:#86efac
    style G fill:#b45309,color:#fff,stroke:#fcd34d
    style H fill:#b45309,color:#fff,stroke:#fcd34d
    style I fill:#374151,color:#fff,stroke:#9ca3af
    style J fill:#374151,color:#fff,stroke:#9ca3af
```

紅綠燈說明：

- 🟢 **綠色（≈100%）**：H 強制 override 生效，Claude 必查 skill
- 🟡 **黃色（50-65%）**：退回 M description trigger，受 Claude 內建 undertriggering 偏差影響
- ⚫ **灰色**：合理跳過（不該觸發 or 使用者明確拒絕）

---

## 5 個前提條件（缺一就退回 50-65%）

### 前提 1：在這個 repo cwd 內 / 或對方已照 INSTALLATION.md 完整裝 3 層

**意義**：CLAUDE.md 內的「圖片寫真 prompt 必查 skill」段落必須被 Claude Code 載入。

**載入條件**：
- 使用者把 Claude Code 啟動在這個 repo 為 cwd
- 或這個 repo 是使用者專案的子目錄（CLAUDE.md 沿父目錄向上搜尋）
- 或對方依 INSTALLATION.md 把 H 段落 cp 到他們專案的 CLAUDE.md

**失敗時**：CLAUDE.md 沒生效 → 只剩 M description trigger → 50-65%

### 前提 2：新 session（CLAUDE.md 變更後重開）

**意義**：CLAUDE.md 是 **session-start** 時載入一次，後續修改要重開 Claude Code 才會重讀。

**失敗時**：在舊 session 內裝 H 但沒重開 → CLAUDE.md 還是舊內容 → 行為退化

**驗證方式**：

```bash
# 退出 Claude Code
# 重新啟動，輸入：
"請告訴我 CLAUDE.md 內有沒有『圖片寫真 prompt 必查 skill』段落？"
# Claude 應該能引用該段落
```

### 前提 3：是圖片寫真 prompt 類請求

**意義**：CLAUDE.md 的 H 段落明列 6 個觸發情境（任一命中就強制查 skill）：

- 任何 AI 圖片 / 寫真 / 人像 prompt 寫作或修正
- 提到 gpt-image-2 / gemini-3-pro / gemini-3.1-flash / nano banana / grok-imagine 任一模型
- 涉及「vogue 風 / 雜誌感 / lookbook 那種 / 高級感不要油膩 / AI 感很重 / 美背 / 逆光 / 窗光 / 都市夜景街拍 / 新中式 / 東方寫真」等寫真美學詞
- 角色一致性 / reference image / DNA 模板 / character anchor
- 3D CG / 幻想系 / anime / 角色渲染
- 「性感但不色情」「sensual but tasteful」這類需要安全轉譯的請求

**不該觸發的情境**（合理）：
- 「幫我寫個 Python script」← 跟圖片無關
- 「Cloudflare Workers 怎麼部署」← 不是寫真請求
- 「比較 Midjourney vs gpt-image-2」← 是「比較問題」不是「寫 prompt 請求」（trigger-eval v2 第 22 題範本）

### 前提 4：使用者沒明確拒絕查 skill

**意義**：CLAUDE.md 內留了 escape hatch：

```
**例外**：使用者明確要求「不要查 skill」「我只要快速答案」時可跳過。但要事先告知「這樣會用過時規範」。
```

**用途**：使用者趕時間或只要粗略想法時可跳過。但 Claude 必須告知後果。

**失敗（被啟動 escape）**：使用者說「不要查 skill 給我快版」→ Claude 用訓練資料直接答，會用過時尺寸 / 沒 Constraints / 沒模型適配。

### 前提 5：Claude 真的遵守 CLAUDE.md 強制指令

**意義**：CLAUDE.md 是 prompt-level 強制指令，不是 hardcoded 保證。

**理論上**：Anthropic 模型可能違反任何 prompt 指令（包括 CLAUDE.md 段落）。

**實務上**：
- 實測 100% 遵守（見「實測證據」段）
- Anthropic 訓練 Claude 高度尊重 system prompt + CLAUDE.md instructions
- Claude Opus 4.7 / Sonnet 4.6 / Haiku 4.5 都對 CLAUDE.md 順從度高

**保險做法**：CLAUDE.md 內**多次重申**「**這是強制指令，不是建議**」「跳過 skill 是**錯誤行為**，不是節省時間」。當前 H 段落已含這些強化詞。

---

## 實測證據（iteration-1 + iteration-2 edge tests）

### 證據 1：iteration-1 量化

5 個測試 case × with/without skill × 1 run：

| Eval | with_skill | without_skill | Δ |
|------|-----------|---------------|---|
| eval-0 預設寫真 | **10/10 ✓** | 2/10 | +80% |
| eval-1 reference image 一致性 | **9/9 ✓** | 4/9 | +56% |
| eval-2 拒絕危險組合 | **5/5 ✓** | 4/5 | +20% |
| eval-3 3D CG 模式切換 | **7/7 ✓** | 3/7 | +57% |
| eval-4 風險詞轉譯 美背 | **7/7 ✓** | 3/7 | +57% |
| **總計** | **38/38 (100%)** | 17/38 (45%) | **+55%** |

完整資料：`skills/gpt-image-portrait-prompt-workspace/iteration-1/benchmark.md`

### 證據 2：iteration-2 邊界測試

| Test | 情境 | 結果 |
|------|------|------|
| Edge A | 完整參數表 + 豐腴曲線 + 清冷高級臉 | ✓ Mode B 5 段輸出、9 參數全鎖定、清冷高級臉 7 維度抽取正確 |
| Edge B | 不可調和危險組合（學生氣質 + 性感 + 床上 + 低機位）| ✓ §27 + §2 + §29 三條款觸發、3 個安全替代方向、零包裝 prompt |
| 自然 query (gemini-3-pro 美背 9:16) | 在 main loop 由 Claude 直接處理 | ✓ 主動讀 SKILL.md、套用 §12 美背 preset、適配 Gemini narrative paragraph |

完整資料：`skills/gpt-image-portrait-prompt-workspace/iteration-2-edge/`

### 證據 3：description-only ceiling（run_loop）

跑 run_loop.py 5 iterations 嘗試 LLM 改寫 description 突破天花板：

| 版本 | 字元 | trigger eval | best test |
|------|------|-------------|-----------|
| 967 (v0 條列) | v1 20q | 4/8 = 50% |
| 1077 (v1 iter 3 best) | v1 20q | 5/8 = 62.5%（**超 1024 限制**）|
| 760 (v2 ALWAYS) | v2 24q (含 Gemini/Grok) | 4/8 = 50% |
| 913 (現役賣點導向) | v2 24q | 同上 ceiling |

**結論**：**沒有任何 description 改寫能突破 ~65% ceiling**。recall 卡在 0-4%（24 個 should-trigger run 裡只有 1 個會觸發）。precision 100%（never false-trigger）。

這就是為什麼必須加 H + J 兩層強制機制。

---

## 為什麼 Plugin 形式不能 100%

Claude Code Plugin 是「跨專案可用、可裝可拔」的模組。Plugin 規範下：

| Plugin 能裝什麼 | Plugin 不能裝什麼 |
|----------------|------------------|
| ✓ skill（M description trigger）| ✗ 修改使用者的 CLAUDE.md（H 機制無法注入）|
| ✓ slash command（J 但是 namespaced：`/<plugin-name>:portrait`）| ✗ 修改使用者的 settings.json |
| ✓ subagents / hooks（受限）| ✗ 全域 project instruction |
| ✓ MCP server | |
| ✓ LSP server | |

**結果**：Plugin 形式下三層機制只剩 M + J namespaced：

```mermaid
flowchart LR
    A[Plugin 安裝後] --> M[M: description trigger<br/>50-65% ceiling]
    A --> J["J: /pluginname:portrait<br/>使用者主動 100%"]
    A -.✗.-> H["H: CLAUDE.md override<br/>Plugin 無法注入"]

    style M fill:#b45309,color:#fff,stroke:#fcd34d
    style J fill:#15803d,color:#fff,stroke:#86efac
    style H fill:#7f1d1d,color:#fff,stroke:#fca5a5
```

**M + J 組合的實際表現**：
- 使用者沒主動輸入 `/portrait` → 退回 M description trigger（50-65%）
- 使用者主動 `/<pluginname>:portrait <需求>` → 100% 觸發

對使用者來說 plugin 還是有價值（J 主動觸發 100%、安裝方便、可從 marketplace 裝），但**達不到 standalone 三層 100%**。

這就是為什麼當前 repo **不採用 plugin 形式**——犧牲跨環境通用換 in-repo 100%。

---

## 跨環境的觸發率變化表

| 安裝方式 | 三層覆蓋 | 自然 query | 主動 `/portrait` | 適合誰 |
|---------|---------|----------|----------------|--------|
| 整個 repo clone 進專案（推薦）| M + H + J | **≈100%** | **100%** | 想要 in-repo 100%、單一專案 |
| `cp` 到自己專案、依 INSTALLATION.md 裝 H + J | M + H + J | **≈100%** | **100%** | 想整合到既有 repo |
| 只 `cp skills/`、不裝 H + J | M | 50-65% | (沒裝 J 不能用) | 不想動 CLAUDE.md |
| 全域裝 `~/.claude/skills/` + 全域 CLAUDE.md 加 H | M + H + J | **≈100% 所有專案** | **100%** | 所有專案都吃到（會 hijack 圖片相關問答）|
| 未來 plugin 形式（沒做）| M + J(namespaced) | 50-65% | **100%（要打全名）** | 想從 marketplace 一鍵裝 |
| Cowork / 遠端 agent / 無 CLAUDE.md 環境 | M | 50-65% | (依該環境是否支援 slash command) | 限制較多 |

---

## 如果要跨環境 100% — 唯一路徑 D

當前狀態犧牲跨環境通用換 in-repo 100%。如果未來想跨環境 100%，唯一可行路徑是 **D：加 `scripts/` 變 workflow**：

```mermaid
flowchart LR
    A[使用者: 用 gemini-3-pro 畫東方女生寫真] --> B{觸發判斷}
    B -- 當前形態 --> C1[Claude 自己寫 prompt 文字<br/>50-65% trigger]
    B -- D workflow 形態 --> C2[Claude 必須查 skill<br/>取得 generate.py]
    C2 --> D1["scripts/generate_image.py<br/>呼叫 OpenAI/Gemini/Grok API"]
    D1 --> E[實際輸出 PNG 圖片]

    style C2 fill:#15803d,color:#fff,stroke:#86efac
    style E fill:#15803d,color:#fff,stroke:#86efac
```

**D 路徑原理**：使用者請求自然變成「我要圖」而非「我要 prompt」。Claude 無法用文字直接滿足，必須查 skill 才能執行 API call。trigger 自然 ≈ 100%（不依賴 H）。

**D 路徑代價**：
- 1-2 小時實作（API key 管理、錯誤處理、檔案儲存）
- 需要使用者提供 OPENAI_API_KEY / GEMINI_API_KEY / GROK_API_KEY
- 偏離原始定位（prompt builder vs 圖片自動化）
- 可能要拆成新 skill `gpt-image-portrait-generate`

**為什麼還沒做 D**：H + J + M 三層已能達 in-repo 100%，多數使用者（吹吹自己）也是在這個 repo 內用。D 適合「想分享給沒裝 H 的使用者群」或「想做圖片自動化」時才做。

---

## 常見問題

### Q1: 「100%」意思是 Claude 必定查 skill 而且 必定產出正確 prompt 嗎？

不是。「100%」只指 **觸發行為**（Claude 會去 Read SKILL.md），不保證 prompt 內容品質。但實測 iteration-1 with-skill 5 case 38/38 通過所有 assertions，**內容品質也接近 100%**。

### Q2: 如果 Claude 真的偶爾違反 CLAUDE.md 強制指令怎麼辦？

實測沒遇過。但理論上：
- 重開 session 通常恢復
- 在 prompt 內明確說「請查 SKILL.md」可強制觸發
- 用 `/portrait` slash command 走 J 路徑 100% 保證

### Q3: 為什麼不用 hook 強制注入 SKILL.md 內容？

Hook 機制（settings.json PreToolUse hooks）能做但要寫程式（match 關鍵字 + 注入 prompt）。複雜度高、CP 值不如 CLAUDE.md H 段落（純 markdown 維護）。

### Q4: 「在這個 repo 內」具體怎麼判斷？

Claude Code 啟動時的 cwd 在這個 repo（或其子目錄）。可以驗證：

```bash
# 啟動 Claude Code 後輸入：
"請列出當前 cwd"
# 應該看到 /Users/<you>/path/to/gpt-portrait-skill
```

CLAUDE.md 是沿父目錄向上搜尋的，所以即使在 repo 的子目錄（如 `docs/`、`skills/`）也會載入到 repo 根的 CLAUDE.md。

### Q5: 我把這個 repo 整個 cp 到別的 monorepo 子目錄，H 還會生效嗎？

只在「cwd 在 gpt-portrait-skill 內」時 H 生效（因為 CLAUDE.md 在 repo 根）。在 monorepo 根目錄啟動 Claude Code 時 **不會** 載入子 repo 的 CLAUDE.md。要嘛 cd 進子 repo、要嘛把 H 段落複製到 monorepo 根的 CLAUDE.md。

### Q6: trigger 率有沒有可能進一步提升？

當前 ceiling 是 ≈100%（in-repo）。要再進一步需要架構改變（D workflow / K MCP server）。但 **「99% → 99.5%」效益遞減**，多數使用者用不到那個邊際。

---

## 推薦使用方式（依場景）

| 場景 | 建議做法 |
|------|--------|
| 個人 dev 環境、單一專案 | 整個 repo clone、in-repo 100% 直接用 |
| 整合到既有專案 | 依 [INSTALLATION.md](./INSTALLATION.md) cp 三層、in-repo 100% |
| 給團隊用 | clone 進團隊 monorepo / vendored、INSTALLATION.md 給隊友 |
| 想跨所有專案自動觸發 | 全域裝 `~/.claude/skills/` + 全域 CLAUDE.md 加 H 段落 |
| 想分享給 community | 未來做 plugin 形式（接受 50-65% trigger）或做 D workflow（保 100%）|
| 不在乎觸發率、用 `/portrait` 主動觸發即可 | 只裝 J（slash command）、跳過 H、跨環境一致 100% |

---

## 相關文件

- [INSTALLATION.md](./INSTALLATION.md)：完整三層安裝指南
- [evaluation-matrix.md](./evaluation-matrix.md)：16 個參考材料的採用評估
- [research-notes.md](./research-notes.md)：OpenAI / Community / Social 三來源研究
- [../README.md](../README.md)：repo 入口
- [../MEMORY.md](../MEMORY.md)：完整設計決策

---

**結論**：「目前方式 100% ？」答案是「在這個 repo 內、新 session、圖片相關請求」三個條件下，**是的，≈100%**——但這是工程現實，不是萬靈藥。離開這個 repo 就退回 50-65%（M description ceiling）。這個 trade-off 是當前架構的核心設計選擇。
