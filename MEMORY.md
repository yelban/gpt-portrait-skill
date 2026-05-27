# MEMORY.md — gpt-image-portrait-prompt skill 設計決策

未來回來時看這份。記錄關鍵決策、為什麼這樣選、走過的彎路。

> 建立時間：2026-05-26
> Owner：吹吹（yelban）
> Skill 性質：Risk-aware editorial portrait prompt builder
> 支援模型：gpt-image-2 / gemini-3-pro-image-preview / gemini-3.1-flash-image-preview / grok-imagine-image-quality

---

## 1. 為什麼建這個 skill

吹吹想要產生 **合規、克制、高級、可執行** 的 AI 寫真 prompt，原本市面範本要嘛太擦邊（觸發 ban）、要嘛太貧瘠（模型自由發揮亂出）。

需要一個 prompt builder skill 能：
- 自動套用最新模型規範（如 gpt-image-2 五段式、16 倍數尺寸）
- 把使用者口語化「性感」「美背」「逆光」翻譯成高級攝影語言
- 明文拒絕 jailbreak / 真人冒名 / 未成年 / 多人親密場景
- 與 reference image 配合保持人物一致性

吹吹有 v0 draft（`docs/gpt-image-portrait-prompt_SKILL_v0.md`，1094 行手寫），但缺乏 2026-04 後新模型規範 + 跨模型相容性。

---

## 2. 開發歷程（時間軸）

| 階段 | 動作 | 產出 |
|------|------|------|
| 1. /dec 重構需求 | 把模糊請求轉成 declarative 規格（成功條件 + 驗證指令 + 非目標）| 同意進入實作 |
| 2. 評估 v0 + 研究新模型 | 平行：評估矩陣（16 block）+ research agent 跑 OpenAI 三來源 | `docs/evaluation-matrix.md` + `docs/research-notes.md` |
| 3. 整合 SKILL.md | 從 v0 + 研究發現 + 評估結果整合成新 SKILL.md（1210 行）| `skills/.../SKILL.md` + 3 個 references/ |
| 4. iteration-1 跑 evals | 5 個測試 case × with/without skill = 10 個 subagent 並行 | benchmark.md: 100% vs 46%, Δ +54% |
| 5. description 優化 v1 | run_loop.py 5 iterations 找最佳 description | best iter3 1077 字元（超 1024 限制）|
| 6. 模型擴展 + ultrawork | 加 Gemini-3-Pro / Gemini-3.1-Flash / Grok Imagine 支援 | Workflow 跑 3 並行研究 + 1 設計 agent |
| 7. description v2 + run_loop | 760 字元 ALWAYS 版 | best iter1（沒被改寫超越）|
| 8. 三層強制 H+J+M | 突破 trigger 偏差 ceiling | CLAUDE.md override + /portrait command + 賣點 description |
| 9. 安裝指南 + README | 讓使用者複製安裝 | `docs/INSTALLATION.md` + `README.md` |
| 10. MEMORY.md（這份）| 記錄設計決策 | 你正在看 |
| 11. Living Layer 持續更新機制 | 2026-05 吹吹指示降低安全保守、優先「有效 + 高表達力 + 降低拒絕」後建立 | `scripts/research-ingest.py` + `community-vetted/` + 三維 Gate + SKILL.md 最小引用 |

---

## 3. 關鍵研究發現（出自 docs/research-notes.md）

### 3.1 模型現況（2026-05 為準）

| 模型 | 發布 | 定位 |
|------|------|------|
| `gpt-image-1` | 2025-04 → **2026-10-23 停用** | Legacy |
| `gpt-image-1-mini` | 2025-10 DevDay | 低成本 |
| `gpt-image-1.5` | 2025-12 | 中間 |
| `gpt-image-2` | **2026-04（現役旗艦）** | 預設 |
| `gemini-3-pro-image-preview` | 2026（Nano Banana Pro）| Google AI Studio / Vertex AI |
| `gemini-3.1-flash-image-preview` | 2026（Nano Banana Flash）| 同上，快、便宜、多 tier |
| `grok-imagine-image-quality` | xAI Grok Imagine | X 平台 |

**決定**：SKILL.md 預設用 `gpt-image-2`，但 description 列全部 4 個現役模型作為 trigger keywords。Legacy 模型從文件移除。

### 3.2 跨模型相容性差異

| 維度 | gpt-image-2 | Gemini | Grok |
|------|------------|--------|------|
| Prompt 風格 | 5 段條列 OK | **narrative paragraph 強制偏好** | 平實英文敘事 |
| Negative prompt | inline `No X` | **無欄位，必須正向重寫** | 嵌入敘事 |
| 尺寸 | 像素字串 + 16 倍數 | `aspect_ratio` + `image_size` tier（"1K"/"2K"/"4K"）| preset |
| Reference image | 16 張 | 14 張（6 obj + 5 char）| 3 張 |
| 真人 / 名人 | 預設 auto 過濾 | **model 層強制封鎖** | 較寬但本 Skill 不放寬 |

**踩坑記錄**：原 v0 用 1200×1600 / 1536×1920 當 3:4 / 4:5 尺寸，**1200 不是 16 倍數**，會被 gpt-image-2 API 拒絕。新版改成 1152×1536 / 1024×1280。

### 3.3 五段式結構（OpenAI Cookbook 官方）

`Scene → Subject → Details → Lighting → Constraints`

**Constraints 是最常被忽略、最有效的欄位**（OpenAI 官方說的）。

### 3.4 攝影技術詞 vs 抽象形容詞

實測有效 vs 無效對照：

| 抽象（無效） | 視覺具體（有效）|
|------------|----------------|
| `stunning portrait` | `85mm portrait, f/1.8, eye-level` |
| `amazing lighting` | `single 45° key light, soft fill from right` |
| `beautiful skin` | `natural pores, subtle imperfections preserved` |
| `8K masterpiece` | `medium format tight crop, visible fabric texture` |

**禁止使用**：`stunning / 8K / masterpiece / epic / amazing / gorgeous`。
模型對抽象形容詞會「平光化」（變平淡均勻）。

### 3.5 Negative prompt 真相

GPT Image 系列**沒有獨立 negative prompt 欄位**。必須在正向 prompt 內嵌 `Do not stylize the face. No cartoon. No anime. No CGI`。

**省略的最常見後果：塑膠感皮膚立即出現**（plastic skin）。

### 3.6 Reference image 一致性

最有效的社群手法是「**角色錨點法 + DNA 模板**」：

- 角色錨點：先生一張完整描述的「anchor 圖」，後續每次 `images.edit` 都傳這張 + 複貼描述 + `Do not redesign the character`
- DNA 模板：5-7 個**具體**臉部特徵詞（如 `almond-shaped eyes with slight upward tilt`），用 hex 色碼取代模糊顏色

---

## 4. 評估結果（iteration-1 量化）

| Metric | With Skill | Without Skill | Δ |
|--------|-----------|---------------|---|
| Pass Rate | **100% ± 0%** | 46% ± 22% | **+54%** |
| Time / run | 38.2s ± 6.6s | 18.2s ± 5.0s | +19.9s |
| Tokens / run | 38165 ± 2143 | 18037 ± 444 | +20128 |

**5 個測試 case 全 100% 通過**：
- eval-0 預設寫真：10/10
- eval-1 reference image 一致性：9/9
- eval-2 拒絕危險組合（學生+性感+床上）：5/5
- eval-3 3D CG 模式切換：7/7
- eval-4 風險詞轉譯（性感美背）+ §12 美背 preset：7/7

**without skill 慘輸 5 項**（with 100% / without 0%）：
- 主體標明 clearly adult
- 五段式結構完整性
- Constraints 排除指令數量
- size 為 gpt-image-2 合法尺寸（baseline 寫 1024x1792 等非 16 倍數）
- model 名稱 gpt-image-2

→ 證明 skill 提供的是 baseline 完全沒有的「規範性知識」。

---

## 5. 為什麼有 H + J + M 三層

### 痛點：description 觸發天花板

run_loop.py 跑 5 iterations 嘗試 LLM 改寫 description，**iter 1（手寫版）就是 best、後續沒提升**。

| Version | trigger eval | best test |
|---------|-------------|-----------|
| 760 字元 ALWAYS 版（v2 iter 1）| v2 (24q, 含 Gemini/Grok) | **4/8 = 50%（ceiling）** |
| 1077 字元 best v1 iter 3 | v1 (20q) | 5/8 = 62.5%（**超 1024 限制**）|
| 967 字元 v0 原版 | v1 (20q) | 4/8 = 50% |

**recall 卡在 0-4%** = 24 個 should-trigger run 裡只有 1 個會觸發。precision 100%（never false-trigger）。

**根本原因**：Claude 對「幫我寫 prompt」類請求有 hardcoded 偏差——「我自己會寫，不必查 skill」。skill-creator 文件也明說：
> Simple, one-step queries may not trigger a skill even if the description matches perfectly.

### 解決方案：三層強制觸發

| 層 | 機制 | trigger 率 | 限制 |
|----|------|----------|------|
| **M** | description 賣點導向（「Claude 訓練資料不含 2026 新規範，不查會錯」）| 50-65% | 跨環境通用，但仍受偏差影響 |
| **H** | 專案 `CLAUDE.md` 強制 override | **≈100%** | 只在裝了的專案內 |
| **J** | `/portrait` slash command 主動觸發 | **100%** | 需使用者習慣輸入 |

### 為什麼不選 D（加 scripts 變 workflow）

D 路徑（加 `scripts/generate_image.py` 真的呼叫 OpenAI / Gemini / Grok API 出圖）能讓使用者請求變「我要圖」而非「我要 prompt」，Claude 必須查 skill 才能執行。

**沒選的理由**：
- 涉及 API key 管理、錯誤處理、檔案儲存等實作工作
- 偏離原始定位（prompt builder vs 圖片自動化）
- H + J + M 三層已能達 in-repo 100% trigger，CP 值更高

未來如要做圖片自動化，可單獨開新 skill `gpt-image-portrait-generate`，或在本 skill 加 `scripts/`。

### 為什麼不選 K（MCP server）

MCP tool 觸發機制比 skill 更積極（Claude 看到 tool 就會用），預期 trigger +40-60%。沒選原因：
- 要寫 Python/TS MCP server
- 要管 server 啟動、port、安裝流程
- H + J 已達 100% in-repo + 100% 主動觸發，差距不顯著

---

## 6. 安全立場與拒絕清單

### 明文拒絕（§28 反繞過聲明）

任何形式的：
- 限界突破 / 回避策 / 検閲を回避 / bypass / jailbreak / 擦邊 / 避審 / 降低 ban 率
- 把性化內容包裝成「藝術詞」（彫刻 / ダンス / 対話 / 秘密を共有 等偽裝）
- 多人物親密接觸場景（密著 / 吐息 / 抱擁 / 絡み合う）
- 真實人物 / 名人 / 網紅 / 政治人物的肖像生成
- 18 歲 / 學生 + 任何性化詞的組合

### 組合詞風險（§2）

**單詞無毒、組合致命**。禁止：

| 元素 A | + 元素 B | = 風險 |
|--------|---------|------|
| 可愛 / 甜美 | + 性感 / 挑逗 | 童顏性感 |
| 學生 / 制服 / 校園 | + 性化詞 | 未成年性感 |
| 床上 / 臥室 | + 衣物滑落 / 半裸 | 露骨臥室 |
| 濕身 / 濕髮 | + 身體部位 / 低機位 | 濕身性化 |
| 二人 / 多人 | + 親密接觸 | 親密場景 |
| 20 歲 / 年輕 | + 幼態 / 童顏 / 學生氣質 | 年齡邊界爭議 |

### 安全替代轉譯

| 風險詞 | 推薦改寫 |
|--------|---------|
| 性感 | tasteful mature elegance / refined feminine charm |
| 魅惑 | mysterious elegance / cinematic presence |
| 身材火辣 | balanced, well-proportioned silhouette |
| 撩人 | attractive but restrained / quietly confident |
| 貼身 | tailored fit / body-skimming silhouette |
| 床上 | bright refined bedroom with composed posture |
| 濕身 | rain-kissed atmosphere |
| 低機位 | eye-level / slight three-quarter angle |

完整見 `skills/.../references/safety-glossary.md`。

### 評估矩陣拒絕的參考材料（4 條）

從吹吹貼上的 16 個社群參考片段中拒絕納入：

1. 日文「真夏の砂浜」～ チャプター 5 連作（2 人女性親密接觸 5 章節 + 限界突破 / 回避策全開明文教學）
2. 「micro bikini → 極細ストラップのミニマルなビーチウェア」等偽裝詞
3. 「AI 不會讓你憑空變高級」純情緒論述
4. 把性化包裝成「彫刻 / ダンス / 対話」的藝術詞戰術

詳見 `docs/evaluation-matrix.md`。

---

## 7. 重要設計權衡（思考的時候要記住）

### 7.1 一氣呵成 vs 模組化

SKILL.md 1210 行（超出 skill-creator 建議的 500 行）。原因：

- **規範性 skill**：每段都是強制清單，不適合「需要時才查 references/」
- §18.3 四層防禦 + §18.4 物理瑕疵 + §2 組合詞警告必須**每次觸發都帶到**，分散到 references/ 就有「model 沒讀就漏防禦」風險
- 4 個範例（§22-25）是「告訴 model 怎麼組裝五段式」的 few-shot，搬走會降低穩定度

**權衡**：每次觸發多 ~20K tokens / 20s overhead。在 Claude 1M context 下可接受。

未來如需精簡，可考慮：
- §12-15 四個 preset 搬 references/style-presets.md
- §22-25 範例搬 references/examples.md
- SKILL.md 變約 700 行

### 7.2 description 1024 字元限制

**Anthropic API 硬限制**（不是建議）。超過會被拒絕載入。Claude Code v2.1.129+ 比較寬容但仍會吃 budget。

當前 913 字元（賣點導向版）：在限制內、強調「Claude 不知道 2026 規範」、列 4 個模型 + 安全排除。

**為什麼不再壓到官方推薦的 200-400 字元**：需要列 4 個模型名 + 多語觸發詞 + 安全排除清單，這些都不能省。

### 7.3 ultrawork（multi-agent workflow）的使用

模型擴展（Gemini / Grok）研究用了 Workflow tool 跑 3 並行 research agent + 1 design agent。

**為什麼用 workflow 而非單 agent**：
- 3 個模型獨立研究，避免單 agent context 過載
- 平行省時間（295s 跑完）
- structured output schema 強制 design agent 產出符合規格的 description + trigger eval

**踩坑**：Workflow 預設 schema validation 嚴格，design agent 的 trigger_eval 必須剛好 20-24 個 query（minItems / maxItems）。

---

## 8. 已知限制與未來方向

### 已知限制

1. **未實際呼叫 API 驗證圖片**：所有測試只到 prompt 級，沒實際生圖
2. **description trigger 50-65% ceiling**：跨環境（離開本 repo）只剩 M 層生效
3. **Gemini / Grok 適配是「prompt 結構提示」**：實際使用時要使用者手動依 §20 跨模型表調整，不是自動轉換
4. **moderation: low 行為未實測**：官方無量化說明
5. **4K (gpt-image-2 Experimental) 實際品質未實測**：發布僅 1 個月，社群實測稀少

### 未來方向（若需要）

| 方向 | 何時做 |
|------|--------|
| D：加 `scripts/generate_image.py` 真實呼叫 API 出圖 | 想做圖片自動化時 |
| K：改成 MCP server，暴露 `generate_portrait_prompt(...)` tool | 想分享給外部使用、提升跨環境 trigger |
| 精簡 SKILL.md 到 700 行 | 發現 context 成本太高時 |
| 加 reference image 實作工作流（Files API + multi-turn）| 真做角色一致性 production 應用時 |
| 跑 iteration-2 對特定 query 補強 | 發現某類請求 skill 不夠好時 |

---

## 9. 重要檔案地圖

```
gpt-portrait-skill/
├── README.md                                   入口
├── CLAUDE.md                                   H 強制 override
├── MEMORY.md                                   ← 你在看
├── .claude/
│   ├── settings.json                           enabledPlugins: skill-creator
│   ├── settings.local.json                     hooks (kiroku)
│   └── commands/
│       ├── dec.md                              既有
│       └── portrait.md                         J slash command
├── skills/
│   ├── gpt-image-portrait-prompt/
│   │   ├── SKILL.md                            主體（1210 行）
│   │   ├── references/
│   │   │   ├── api-reference.md                模型、API、尺寸、成本
│   │   │   ├── photography-vocab.md            完整攝影詞庫
│   │   │   └── safety-glossary.md              綠/黃/紅詞庫 + 拒絕模板
│   │   └── evals/
│   │       ├── evals.json                      5 個測試 case
│   │       ├── trigger-eval.json               v1 trigger eval (20q)
│   │       └── trigger-eval-v2.json            v2 trigger eval (24q, 含 Gemini/Grok)
│   └── gpt-image-portrait-prompt-workspace/
│       └── iteration-1/                        with/without skill 對比
│           ├── benchmark.json
│           ├── benchmark.md
│           ├── grade.py                        自製 grading script
│           └── eval-{0~4}-*/                   per-case outputs
└── docs/
    ├── INSTALLATION.md                         完整安裝指南（給使用者）
    ├── research-notes.md                       三來源研究（OpenAI / Community / Social）
    ├── evaluation-matrix.md                    16 block 採用評估
    └── gpt-image-portrait-prompt_SKILL_v0.md   v0 原始 draft 保留
```

---

## 10. 開發指令快速參考

設 `$REPO` 為本 repo 根目錄、`$SC` 為 skill-creator plugin 路徑（通常 `~/.claude/plugins/cache/claude-plugins-official/skill-creator/unknown/skills/skill-creator`）。

```bash
# 跑 with/without skill 評估
cd "$REPO"
python3 skills/gpt-image-portrait-prompt-workspace/iteration-1/grade.py

# 跑 description 優化 loop
cd "$SC"
python3 -m scripts.run_loop \
  --eval-set "$REPO/skills/gpt-image-portrait-prompt/evals/trigger-eval-v2.json" \
  --skill-path "$REPO/skills/gpt-image-portrait-prompt" \
  --model claude-opus-4-7 \
  --max-iterations 5 \
  --verbose

# Aggregate benchmark
python3 -m scripts.aggregate_benchmark \
  "$REPO/skills/gpt-image-portrait-prompt-workspace/iteration-1" \
  --skill-name gpt-image-portrait-prompt

# 開 eval viewer
python3 "$SC/eval-viewer/generate_review.py" \
  "$REPO/skills/gpt-image-portrait-prompt-workspace/iteration-1" \
  --skill-name gpt-image-portrait-prompt \
  --benchmark "$REPO/skills/gpt-image-portrait-prompt-workspace/iteration-1/benchmark.json"

# 驗證三層完整性（在 $REPO 內執行）
test -f skills/gpt-image-portrait-prompt/SKILL.md && \
test -f .claude/commands/portrait.md && \
grep -q "圖片寫真 prompt 必查 skill" CLAUDE.md && echo "✓ 三層完整"
# 更穩健的驗證方式（推薦）：
# grep -q "gpt-portrait-skill 強制 override 區段開始" CLAUDE.md && echo "✓ H override"
```

---

## 11. 開發感想（給未來自己）

- **description 是 skill metadata，body 才是 skill 本體**——別把它當「短文描述」，它是「Claude 判斷要不要查」的唯一依據
- **trigger ceiling 是真的**——別跟 Claude 內建偏差硬碰，繞過去（H / J）比優化文字（M）有效百倍
- **規範性 skill 適合一氣呵成**——別硬遵循「< 500 行」建議拆模組
- **2026-05 SKILL.md 尺寸優化**：因擔心其他 agent（Codex 等）載入失敗，執行「方案 1（溫和外移）」：
  - 將 §12–§17（6 個大型 Preset + 3D CG 模式）與 §22–§25（4 個完整範例）移至 `references/presets.md` 與 `references/examples.md`
  - 主 SKILL.md 從 ~1550 行降至 1095 行
  - 同時精簡黃色詞表格、跨模型大表、§26 長文等
- **尺寸決策**：吹吹選擇 **C**（先維持目前狀態，待實際出現其他 agent 拒載或截斷案例再啟動下一階段精簡）。此時已符合「以 Claude Code 為主，其他環境可接受偶爾風險」的定位。
- Anthropic 官方建議（2026 已確認）：SKILL.md 推薦低於 500 行，實務上限約 5,000 tokens。超過會影響載入與效能。
- **safety 不是「藏關鍵字」是「整體意圖判讀」**——gpt-image-2 看的是脈絡密度，不是字面詞
- **多模型支援要先研究再寫**——Gemini 跟 OpenAI 完全不同 API / 完全不同 prompt 哲學（narrative vs structured），不能直接套
- **ultrawork 適合「需要平行研究 + structured output」的任務**——3 並行研究 + 1 design 跑 5 分鐘完成，單 agent 至少 15 分鐘
- **吹吹喜歡簡潔回應 + 用 mermaid + 偏好繁中台灣用語 + commit message 寫英文**

下次回來想增刪改 skill 時，從這份 MEMORY.md 開始看，再進 README → INSTALLATION → SKILL.md。
