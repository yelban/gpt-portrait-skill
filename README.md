# gpt-image-portrait-prompt

**Risk-aware editorial portrait prompt builder** for `gpt-image-2` / `gemini-3-pro-image-preview` / `gemini-3.1-flash-image-preview` / `grok-imagine-image-quality`，內建 character-anchored reference-image consistency、五段式 prompt 結構、跨模型相容性適配與 built-in defensive exclusions。

合規、克制、可執行——**不是擦邊、不是繞過審查、不是低俗模板**。

---

## 這個 repo 是什麼

一個完整的 Claude Code skill 範本，包含三層強制觸發機制（M + H + J），讓你在自己的專案內達到 **100% trigger 命中率**。

```
gpt-portrait-skill/
├── CLAUDE.md                          ← H：專案層級強制 override
├── .claude/commands/portrait.md       ← J：/portrait slash command
├── skills/gpt-image-portrait-prompt/  ← M：skill 本體
│   ├── SKILL.md                       (1210 行、賣點導向 description)
│   ├── references/                    (api / vocab / safety 三份補充)
│   └── evals/                         (5 個測試 case + 24 個 trigger eval)
└── docs/
    ├── INSTALLATION.md                ← 完整安裝指南（看這份）
    ├── research-notes.md              (OpenAI / Community / Social 三來源研究)
    ├── evaluation-matrix.md           (16 個參考材料的採用評估)
    └── gpt-image-portrait-prompt_SKILL_v0.md  (原 draft 保留)
```

## 安裝

**完整指南**：[`docs/INSTALLATION.md`](./docs/INSTALLATION.md)

### 30 秒最快路徑（in-project 100% trigger，一次裝完三層）

**前提**：範本與你的專案放在同一個父目錄（兄弟關係）。例如都在 `~/work/` 下、或都在 `~/projects/` 下。

```bash
# 1. clone 範本（一次性，未來可 git pull 更新）
git clone https://github.com/yelban/gpt-portrait-skill.git

# 2. 切到你的專案
cd ./your-gpt-project

# 3. 一次裝三層（M skill 本體 + J slash command + H CLAUDE.md override）
mkdir -p .claude/commands skills
cp -r ../gpt-portrait-skill/skills/gpt-image-portrait-prompt skills/
cp ../gpt-portrait-skill/.claude/commands/portrait.md .claude/commands/

# 4. 安裝 H 層（CLAUDE.md 強制 override）——三種情境擇一
# (a) 專案還沒有 CLAUDE.md（直接複製整份）
# cp ../gpt-portrait-skill/CLAUDE.md ./CLAUDE.md

# (b) 專案已經有自己的 CLAUDE.md（推薦，只 append 強制段落）
sed -n '/^# === gpt-portrait-skill 強制 override 區段開始 ===/,$p' ../gpt-portrait-skill/CLAUDE.md >> CLAUDE.md

# (c) 安裝到全域 ~/.claude/CLAUDE.md（所有專案生效，建議先備份）
# cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak 2>/dev/null || true
# sed -n '/^# === gpt-portrait-skill 強制 override 區段開始 ===/,$p' ../gpt-portrait-skill/CLAUDE.md >> ~/.claude/CLAUDE.md

# 5. ★ 重開 Claude Code session 即生效
```

> ⚠️ **CLAUDE.md 用 `>>` append、不要 `cp` 覆蓋**——避免吃掉你原本專案的 CLAUDE.md 內容。
>
> 若範本與專案**不在同一父目錄**（例如範本在 `~/templates/`、專案在 `~/work/`），把上方 `../gpt-portrait-skill/` 改成範本的實際路徑（如 `~/templates/gpt-portrait-skill/`）。
>
> 完整安裝指南 + 推薦使用根目錄的 `install.sh` 見 [docs/INSTALLATION.md](./docs/INSTALLATION.md)。

裝完後在這個專案內：
- 自然 query（「幫我寫個美背 9:16」）→ Claude 自動讀 SKILL.md 才答（H 強制）
- `/portrait 美背 9:16 高級感` → 100% 觸發（J 主動）

## 為什麼需要三層

**Claude 對「幫我寫 prompt」這類請求有 hardcoded 偏差——會自己寫、不查 skill。** 即使 description 寫得再 pushy，被動 trigger 率只有約 50%（實測）。

| 層 | 機制 | trigger 率 | 適用範圍 |
|----|------|----------|---------|
| **M** | description 賣點導向（內建於 SKILL.md，強調 Claude 訓練資料不含 2026 新規範）| 50-65% | 跨環境通用 |
| **H** | 專案 `CLAUDE.md` 強制 override | **≈100%** | 只在裝了的專案內 |
| **J** | `/portrait` slash command 主動觸發 | **100%** | 使用者主動輸入 |

詳細解釋見 [INSTALLATION.md](./docs/INSTALLATION.md#為什麼需要看這份文件)。

## 觸發率保證 — 「100%」的真相

「100%」不是無條件，有 5 個前提（在這個 repo 內 / 新 session / 圖片相關請求 / 使用者沒拒絕 / Claude 遵守 CLAUDE.md）。離開這個 repo 就退回 50-65%。

完整工程說明、決策流程圖、實測證據、為什麼不採用 plugin 形式：
**👉 [docs/TRIGGER-GUARANTEE.md](./docs/TRIGGER-GUARANTEE.md)**

## skill 設計亮點

| 維度 | 設計 |
|------|------|
| 安全立場 | 嚴守 OpenAI / Google / xAI ToS。明文拒絕 jailbreak / 限界突破 / 回避策 / 真人冒名 / 未成年性化 / 多人親密場景 |
| Prompt 結構 | 官方推薦五段式（Scene / Subject / Details / Lighting / Constraints），inline 防禦取代 negative prompt 欄位 |
| 模型相容性 | gpt-image-2（5 段式+像素尺寸）、Gemini（narrative paragraph + tier 制）、Grok（敘事句 + 3-ref cap）各自適配 |
| 風險詞轉譯 | 綠 / 黃 / 紅 三色階詞庫 + 組合詞警告表（如「學生 + 性感」「床上 + 衣物滑落」「20 歲 + 幼態」）|
| Reference image | 角色錨點法（Character Anchor）+ DNA 模板（具體臉部特徵詞 / hex 色碼）+ 16 張 reference 工作流 |

## 評估結果（iteration-1 with-skill vs without-skill）

| Metric | With Skill | Without Skill | Δ |
|--------|-----------|---------------|---|
| Pass Rate | **100% ± 0%** | 46% ± 22% | **+54%** |
| 5 個測試 case 全通過 | 38/38 | 17.5/38 | 預設寫真 / reference image / 危險組合拒絕 / 3D CG / 風險詞轉譯 |

完整 benchmark：`skills/gpt-image-portrait-prompt-workspace/iteration-1/benchmark.md`

## 開發歷程文件

- **`docs/INSTALLATION.md`**：使用者裝這個 skill 的完整指南
- **`docs/TRIGGER-GUARANTEE.md`**：「100%」觸發率的工程現實（5 前提、決策流程圖、實測證據、為何不採 plugin 形式、跨環境變化表）
- **`docs/research-notes.md`**：OpenAI 官方 + Community + 第三方 三來源 best practices 研究（含模型、API、prompt 結構、safety、reference image、成本）
- **`docs/evaluation-matrix.md`**：對 16 個社群參考材料（含日文連作）的採用/拒絕評估表
- **`docs/gpt-image-portrait-prompt_SKILL_v0.md`**：使用者原始手寫 draft（v0）保留作對照
- **`skills/gpt-image-portrait-prompt-workspace/iteration-1/`**：5 個測試 case 的 with/without skill 對比、grading、benchmark
- **`skills/gpt-image-portrait-prompt-workspace/iteration-2-edge/`**：邊界測試（完整參數 Mode B / 不可調和拒絕）
- **2026-05 SKILL.md 尺寸優化**：執行方案 1（大型 preset 與範例外移至 references/），主檔從 ~1550 行降至 1095 行。決策詳見 MEMORY.md「2026-05 尺寸決策」段（選擇 C，先維持現狀，待實際跨 agent 載入問題再處理）。

## License / 使用條款

未指定。本 skill 設計遵循 OpenAI / Google / xAI 各自 ToS。使用者自負 prompt 內容的合規責任。

## 致謝

- Skill 結構參考 [Anthropic Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) 官方規範
- 建構流程使用 Claude Code `skill-creator` plugin
- 多模型相容性研究使用 `ultrawork` multi-agent workflow（gemini-3-pro / gemini-3.1-flash / grok-imagine 三模型並行研究 + design agent 整合）
