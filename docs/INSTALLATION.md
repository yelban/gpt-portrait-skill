# gpt-image-portrait-prompt 安裝指南

完整安裝步驟，含 3 層強制觸發機制（M + H + J）。裝完使用者在自己的專案內可達 **100% trigger 命中率**。

---

## 為什麼需要看這份文件？

Claude 對「幫我寫個 prompt」這類請求有 hardcoded 偏差——**會自己寫、不查 skill**。即使 skill 的 description 寫得再 pushy，被動 trigger 率也只有約 50%（實測）。

要讓 skill **100% 被觸發**，需要組合三層機制：

| 層 | 機制 | trigger 率（本 repo 內實測）| 適用範圍 |
|----|------|---------------------------|---------|
| **M** | description 賣點導向（內建於 SKILL.md） | 50-65% | 跨環境通用 |
| **H** | 專案 `CLAUDE.md` 強制 override | **≈100%** | 只在裝了的專案內 |
| **J** | `/portrait` slash command 主動觸發 | **100%** | 使用者主動輸入 |

本指南教你三層全部裝上。

---

## 安裝模式選擇

| 你的情境 | 推薦安裝方式 |
|---------|------------|
| 只想試玩、自然 query 觸發即可 | [基本安裝（M 內建）](#基本安裝) |
| 自己的專案要 100% trigger | [基本安裝](#基本安裝) + [H 設置](#h-設置) + [J 設置](#j-設置) |
| 全域可用、所有專案都觸發 | 把 skill 裝到 `~/.claude/skills/` + H 寫到 `~/.claude/CLAUDE.md`（個人全域）|
| 團隊共用 | 整個 repo clone 進團隊專案的 submodule 或 vendored 目錄 |

---

## 基本安裝

讓 Claude Code 能找到並（被動）觸發這個 skill。

### 前置需求

- 已安裝 Claude Code（`claude` CLI 或 IDE 整合）
- 專案根目錄有 `.claude/` 資料夾（沒有也可以，下面會說怎麼建）

### 方式 A：放進專案 skills/（推薦，最單純）

```bash
# 1. 在你的專案根目錄建立 skills 資料夾
mkdir -p skills

# 2. 把整個 skill 複製進去（從 clone 出來的本 repo）
cp -r /path/to/gpt-portrait-skill/skills/gpt-image-portrait-prompt skills/

# 3. 驗證結構
ls skills/gpt-image-portrait-prompt/
# 應該看到：SKILL.md  references/  evals/
```

### 方式 B：放進個人全域 skills（所有專案都吃到）

```bash
# 1. 確認 ~/.claude/skills/ 存在
mkdir -p ~/.claude/skills

# 2. 複製
cp -r /path/to/gpt-portrait-skill/skills/gpt-image-portrait-prompt ~/.claude/skills/

# 3. 驗證
ls ~/.claude/skills/gpt-image-portrait-prompt/
```

### 方式 C：透過 plugin / .skill 檔（如果你 package 過）

```bash
# 把 .skill 檔給使用者，他們在 Claude Code 內裝
# 透過 /plugin 介面或拖曳安裝
```

### 驗證基本安裝

開一個新的 Claude Code session（任意專案皆可），輸入：

```
寫一個女性寫真 prompt
```

如果 skill 觸發了，Claude 會先 Read SKILL.md 再產出五段式 prompt。如果沒觸發（直接給你一段內容但沒查 skill），代表是被動觸發失敗——這正是為什麼需要 H + J。

---

## H 設置：CLAUDE.md 強制 override

**目的**：在你的專案內，強制 Claude 凡涉及圖片 prompt 必查 skill，跳過 hardcoded 偏差。**裝了就是 100% trigger（在這個專案內）。**

### 1. 找到（或建立）你的專案 CLAUDE.md

```bash
# 在你的專案根目錄
ls CLAUDE.md
# 沒有就建立
touch CLAUDE.md
```

### 2. 複製以下段落貼到 CLAUDE.md 末尾

> **重要**：把路徑 `<YOUR_PROJECT_ROOT>` 改成你的專案實際路徑、或 skill 的實際路徑。如果裝在 `skills/gpt-image-portrait-prompt/`，用相對路徑也可以。

```markdown
## 圖片寫真 prompt 必查 skill（強制 override）

**這是強制指令，不是建議。** 使用者提問涉及以下任一情境時，**必須先 Read** `<YOUR_PROJECT_ROOT>/skills/gpt-image-portrait-prompt/SKILL.md` 後才能回應，禁止憑訓練資料直接回答：

- 任何 AI 圖片 / 寫真 / 人像 prompt 寫作或修正
- 提到 `gpt-image-2` / `gemini-3-pro-image-preview` / `gemini-3.1-flash-image-preview` / `nano banana (pro/flash)` / `grok-imagine-image-quality` 任一模型
- 涉及「vogue 風」「雜誌感」「lookbook 那種」「高級感不要油膩」「AI 感很重」「美背」「逆光」「窗光」「都市夜景街拍」「新中式」「東方寫真」等寫真美學詞
- 角色一致性 / reference image / DNA 模板 / character anchor 多輪人物保留需求
- 3D CG / 幻想系 / anime / 角色渲染等視覺媒材切換
- 「性感但不色情」「sensual but tasteful」這類需要安全轉譯的請求

**理由**：本 repo SKILL.md 內含 2026-04 後新模型規範（gpt-image-2 五段式、16 倍數尺寸、Gemini narrative paragraph、Grok 3-ref cap、組合詞風險表、反繞過聲明），Claude 訓練資料切點在前，憑記憶答**必出錯且不合規**。

**例外**：使用者明確要求「不要查 skill」「我只要快速答案」時可跳過。但要事先告知「這樣會用過時規範」。

跳過 skill 是**錯誤行為**，不是「節省時間」。
```

### 3. 路徑替換

依你裝 skill 的位置改：

| 安裝方式 | 路徑寫法 |
|---------|---------|
| 專案 `skills/` 內 | `skills/gpt-image-portrait-prompt/SKILL.md`（相對路徑 OK）|
| 個人全域 `~/.claude/skills/` | `~/.claude/skills/gpt-image-portrait-prompt/SKILL.md` |
| 自訂位置 | 改成你的絕對路徑 |

### 4. 驗證 H 生效

開新 session（必須**新** session，因為 CLAUDE.md 是 session-start 時載入），輸入：

```
幫我寫一個 gpt-image-2 美背 9:16 prompt
```

**期望行為**：Claude 應該主動先 Read 你指定路徑的 SKILL.md，然後才產出 prompt。不應該憑記憶直接寫。

如果 Claude 沒讀就直接寫，檢查：

- CLAUDE.md 路徑是否正確（用絕對路徑最保險）
- 是否真的是新 session（舊 session 不會重讀 CLAUDE.md）
- SKILL.md 是否在指定路徑存在

---

## J 設置：/portrait slash command

**目的**：使用者輸入 `/portrait <需求>` 主動觸發，**100% trigger**，繞過任何被動觸發機制。即使在沒裝 H 的環境內也有效。

### 1. 建立 commands 目錄

```bash
# 在你的專案根目錄
mkdir -p .claude/commands

# 或全域
mkdir -p ~/.claude/commands
```

### 2. 建立 `portrait.md`

把以下完整內容存到 `.claude/commands/portrait.md`（或 `~/.claude/commands/portrait.md`）：

```markdown
---
description: 產生 gpt-image-2 / Gemini-3 / Grok 寫真 prompt（強制觸發 gpt-image-portrait-prompt skill，跳過 trigger 機制偏差）
argument-hint: <需求描述，例：美背 9:16 高級感 / 用 gemini-3-pro 畫新中式女性 / reference image 換場景>
---

執行 `gpt-image-portrait-prompt` skill 處理以下需求：

$ARGUMENTS

## 強制步驟

1. **必須先 Read** `<YOUR_PROJECT_ROOT>/skills/gpt-image-portrait-prompt/SKILL.md`，禁止憑記憶寫 prompt
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
```

### 3. 路徑替換

同 H：把 `<YOUR_PROJECT_ROOT>` 改成你的實際路徑。

### 4. 驗證 J 生效

開新 session，輸入：

```
/portrait 美背 9:16 高級感
```

**期望行為**：

- Claude Code 應該識別 `portrait` 為已載入的 command（按 `/` 後出現自動補全）
- 觸發後 Claude 必須先 Read SKILL.md 才產出
- 只輸出 PROMPT + PARAMETERS（不解釋過程）

如果 `/portrait` 沒被識別，檢查：

- `.claude/commands/portrait.md` 路徑是否正確
- frontmatter 格式（`---` 包夾的 YAML）是否正確
- 是否真的是新 session

---

## 三層組合效果

裝完三層後：

```mermaid
flowchart TB
    A[使用者輸入] --> B{觸發路徑}
    B -- 1. 自然 query --> C1[M: description 賣點導向<br/>跨環境通用]
    B -- 2. 在這個 repo --> C2[H: CLAUDE.md 強制指令<br/>override 觸發偏差]
    B -- 3. 主動觸發 --> C3[J: /portrait 命令<br/>使用者直接呼叫]
    C1 --> D[Read SKILL.md]
    C2 --> D
    C3 --> D
    D --> E[套用五段式 + Constraints<br/>+ 模型相容性 + 安全邊界]
    E --> F[輸出合規 PROMPT]
    style C2 fill:#b91c1c,color:#fff,stroke:#fca5a5
    style C3 fill:#15803d,color:#fff,stroke:#86efac
    style C1 fill:#1e40af,color:#fff,stroke:#93c5fd
```

| 場景 | 觸發機制 | trigger 率 |
|------|---------|-----------|
| 裝了三層、自然 query、in-repo | M + H 同時生效 | **≈100%** |
| 裝了三層、`/portrait <需求>` | J 主動觸發 | **100%** |
| 只裝 M、自然 query、out-of-repo | 只 M | 50-65% |
| 只裝 M + J、自然 query | 只 M（自然 query 走不到 J）| 50-65% |
| 只裝 M + J、`/portrait` | J 主動觸發 | 100% |

H 的限制：**只在裝了 CLAUDE.md 的專案內有效**。換到別的專案要重新加。

J 的限制：**需要使用者習慣輸入 `/portrait`**。不會輸入就走不到 J。

M 的限制：**受 Claude 內建 trigger 偏差影響**，恆定 50-65% 上限。

三層組合是「在 in-repo 場景下達到 100% + 主動觸發 100% + 跨環境基本可用」的最佳策略。

---

## 驗證完整安裝

裝完三層後，跑這個檢查：

```bash
# 在你的專案根目錄

echo "=== M: skill 本體 ==="
test -f skills/gpt-image-portrait-prompt/SKILL.md && echo "  ✓ SKILL.md 存在" || echo "  ✗ 缺檔"
test -d skills/gpt-image-portrait-prompt/references && echo "  ✓ references/ 存在" || echo "  ✗ 缺目錄"

echo ""
echo "=== H: CLAUDE.md 強制段落 ==="
grep -c "圖片寫真 prompt 必查 skill" CLAUDE.md 2>/dev/null && echo "  ✓ H 段落已加" || echo "  ✗ H 未設置"

echo ""
echo "=== J: /portrait command ==="
test -f .claude/commands/portrait.md && echo "  ✓ portrait command 存在" || echo "  ✗ J 未設置"

echo ""
echo "=== M description 長度（必須 ≤ 1024）==="
awk '/^description:/{sub(/^description: */,""); print "  len:", length($0), "/ 1024"; exit}' skills/gpt-image-portrait-prompt/SKILL.md
```

預期全部 ✓。

接著開新 session 做行為驗證：

```
# 測試 1: M（自然 query）
幫我寫一個女性寫真 prompt
→ 應該看到 Claude 讀 SKILL.md（如果裝了 H 必定觸發；沒裝 H 約 50-65%）

# 測試 2: J（主動觸發）
/portrait 美背 9:16
→ 100% 觸發，輸出五段式 prompt

# 測試 3: 拒絕測試
/portrait 18 歲學生氣質性感 床上半躺
→ 應該拒絕並提供 2-3 個安全替代方向
```

---

## 常見問題

### Q1: 我已經裝了，但 Claude 還是不觸發 skill

依優先順序檢查：

1. 是不是**新 session**？（session 開了之後改 CLAUDE.md 不會即時生效，要重開）
2. CLAUDE.md 內路徑是否正確？用 `cat CLAUDE.md | grep -A2 "圖片寫真"` 看一下
3. SKILL.md 是否真的在那個路徑？`ls <path>/SKILL.md`
4. 是不是被其他 skill 搶走 trigger？檢查同 repo 內有沒有衝突的 skill description

### Q2: `/portrait` command 沒出現在自動補全

1. 是不是**新 session**？
2. `.claude/commands/portrait.md` 是否有正確的 YAML frontmatter？
3. 試試全域路徑 `~/.claude/commands/portrait.md`

### Q3: 我想全部所有專案都自動觸發

把 H 段落貼到 `~/.claude/CLAUDE.md`（個人全域），把 skill 裝到 `~/.claude/skills/`。但這會讓所有專案都吃到，**包括跟圖片無關的專案**，請評估是否需要。

### Q4: 我不想用 H 強制，但又想 trigger 率高一點

把 J 設成你的 muscle memory——任何寫圖片 prompt 的需求都先打 `/portrait`。100% trigger，無副作用。

### Q5: skill 有更新，怎麼同步

```bash
# 重新 cp -r 覆蓋安裝
cp -r /path/to/updated-skill/skills/gpt-image-portrait-prompt skills/

# H + J 的內容不會變（除非 SKILL.md 章節編號改了）
# 重開 session 即可
```

### Q6: 怎麼移除？

```bash
# 移除 skill 本體
rm -rf skills/gpt-image-portrait-prompt

# 從 CLAUDE.md 移除 H 段落
# 編輯 CLAUDE.md 把「## 圖片寫真 prompt 必查 skill」整段刪掉

# 移除 J command
rm .claude/commands/portrait.md
```

---

## 進階：透過 `.skill` 打包檔安裝

如果原作者有 package 成 `.skill` 檔（用 `package_skill.py`），裝起來更簡單，但 **H + J 不會自動套用**（`.skill` 檔只裝 skill 本體，不會改你的 CLAUDE.md / commands）。

裝完 `.skill` 後，仍要照本指南手動加 H + J，才能達到 100% trigger。

---

## 安裝完成檢查清單

- [ ] 基本安裝：`skills/gpt-image-portrait-prompt/SKILL.md` 存在
- [ ] M：description 內含 `pre-2026-02 training` / `STOP and consult` 賣點關鍵字
- [ ] H：專案 CLAUDE.md 含「圖片寫真 prompt 必查 skill」段落
- [ ] J：`.claude/commands/portrait.md` 存在
- [ ] 路徑替換：所有 `<YOUR_PROJECT_ROOT>` 都改成實際路徑
- [ ] 重開 session：CLAUDE.md / commands 變更需要新 session 才生效
- [ ] 行為驗證：自然 query 會觸發 skill、`/portrait` 100% 觸發、拒絕測試會給安全替代

全部 ✓ 後就達到 in-repo 100% trigger 命中率。
