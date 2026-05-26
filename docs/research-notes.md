# GPT Image Model 研究筆記

> 研究時間：2026-05-25
> 涵蓋來源：OpenAI 官方 API 文件 / OpenAI Cookbook / OpenAI Developer Community / 第三方技術部落格

---

## TL;DR（給整合用的 5 條關鍵結論）

1. **模型系列現況**：官方目前有四個模型——`gpt-image-1`（Legacy，2026-10-23 停用）、`gpt-image-1-mini`（低成本批次用）、`gpt-image-1.5`（2025-12 發布，穩定中間層）、`gpt-image-2`（2026-04-21 發布，最新旗艦，建議新專案預設）。社群俗稱「GPT Image 2」= 官方 `gpt-image-2`，無出入。

2. **尺寸真相**：`gpt-image-2` 確實支援 4K（3840×2160），但標注為 **Experimental**；2K（2560×1440）則已穩定可用。`gpt-image-1/1.5` 僅支援三種固定尺寸（1024×1024 / 1024×1536 / 1536×1024）。

3. **人像提示詞結構**：官方與社群一致建議 **Scene → Subject → Details → Lighting → Constraints** 的五段式結構；「Constraints 欄位」是最多人忽略也最能提升品質的環節。

4. **Reference image / 人物一致性**：`images.edit` 端點支援最多 16 張參考圖，以 file ID 或 URL 傳入；跨圖一致性的最佳實踐是「先建立角色錨點（anchor），之後每次請求複述相同描述詞並加 "Do not redesign the character"」。

5. **Negative prompt**：GPT Image 系列無獨立的 negative prompt 欄位，須以正向提示詞內嵌「排除指令」（如 "Do not stylise the face. No cartoon."）來實現防禦性提示，效果被社群實測確認有效。

---

## OpenAI Official

### 1. 模型系列與官方命名
**來源**：https://developers.openai.com/api/docs/models/gpt-image-1 / https://developers.openai.com/api/docs/guides/image-generation

OpenAI 圖像生成模型官方名稱依發布時序為：

| 官方 API 名稱 | 發布時間 | 定位 |
|---|---|---|
| `gpt-image-1` | 2025-04-23 | 第一代旗艦（現為 Legacy，2026-10-23 停用） |
| `gpt-image-1-mini` | 2025-10-06 (DevDay) | 低成本版，比 gpt-image-1 便宜 80% |
| `gpt-image-1.5` | 2025-12-16 | 中間旗艦，速度提升 4 倍、成本降 20% |
| `gpt-image-2` | 2026-04-21 | 現行旗艦，整合 O-series 推理能力 |

社群俗稱「GPT Image 2」即官方 `gpt-image-2`，沒有命名落差。

**與 skill 的關聯**：Skill 應以 `gpt-image-2` 為預設模型，保留 `gpt-image-1.5` 為向後相容選項；說明文件中若有舊模型名稱需更新。

---

### 2. API 端點與必要／可選參數
**來源**：https://developers.openai.com/api/docs/guides/image-generation

**端點（Images API）**：
- `POST /v1/images/generations` — 文字生圖
- `POST /v1/images/edits` — 圖片編輯（含 reference image）

**端點（Responses API）**：支援多輪對話、`previous_response_id`、`action: auto/generate/edit`

**主要參數**：

| 參數 | 說明 | 備注 |
|---|---|---|
| `model` | 模型名稱 | 必要 |
| `prompt` | 文字描述 | 必要 |
| `n` | 生成張數（預設 1） | 可選 |
| `size` | 圖片尺寸 | 可選，見下方 |
| `quality` | `low / medium / high / auto` | 可選 |
| `background` | `opaque` 或 `auto`（`gpt-image-2` 不支援透明） | 可選 |
| `moderation` | `auto`（預設）或 `low` | 可選 |
| `output_compression` | 0-100%，適用於 JPEG/WebP | 可選 |
| `stream` | 啟用串流 | 可選 |
| `partial_images` | 串流中途回傳 0-3 張草稿 | 可選 |
| `input_fidelity` | `low / high`（`gpt-image-2` 不支援，預設即高保真） | gpt-image-1.x 可選 |
| `input_image_mask` | 遮罩檔案（需含 alpha channel，上限 50MB） | 編輯模式可選 |

**response_format**：`gpt-image-1` 回傳 `b64_json`（不支援 URL 格式）；輸出格式可指定 `png`（預設）/ `jpeg` / `webp`。

**與 skill 的關聯**：Skill 的 API 呼叫模板需包含 `quality`、`moderation`、`size` 三個關鍵可選參數，並依人像用途預設 `quality: "high"`、`size: "1024x1536"`。

---

### 3. 支援尺寸清單與 4K 現況
**來源**：https://developers.openai.com/cookbook/examples/multimodal/image-gen-models-prompting-guide / https://developers.openai.com/api/docs/guides/image-generation

**`gpt-image-1 / gpt-image-1.5 / gpt-image-1-mini`**（固定三種）：
- 1024×1024（正方形）
- 1024×1536（直式人像）
- 1536×1024（橫式）
- `auto`（依 prompt 自動選擇）

**`gpt-image-2`**（彈性尺寸，限制如下）：
- 最大邊長 ≤ 3840px
- 兩邊皆須為 16 的倍數
- 長寬比 ≤ 3:1
- 總像素數：655,360 ~ 8,294,400

官方列出的熱門尺寸：

| 標籤 | 解析度 | 狀態 |
|---|---|---|
| HD 直式 | 1024×1536 | 穩定 |
| HD 橫式 | 1536×1024 | 穩定 |
| 正方形 | 1024×1024 | 穩定 |
| 2K/QHD | 2560×1440 | 穩定 |
| 4K/UHD | 3840×2160 | **Experimental** |

**結論**：4K 支援屬實，但標注 Experimental，正式產品環境建議使用 2K 或以下。

**與 skill 的關聯**：人像 skill 推薦尺寸應為 `1024×1536`（標準人像）或 `2560×1440`（高品質直式）；4K 可列為進階選項並標注 Experimental。

---

### 4. Reference Image / 圖片編輯支援
**來源**：https://developers.openai.com/api/docs/guides/image-generation / https://community.openai.com/t/introducing-gpt-image-2-available-today-in-the-api-and-codex/1379479

**Images API（`/v1/images/edits`）**：
- 以 `image=[open("file.png", "rb"), ...]` 傳入，支援陣列（多張參考圖）
- 搭配 `input_image_mask`（alpha channel 遮罩）做局部編輯（inpainting）
- `gpt-image-2` 使用示範：傳入 4 張產品照合成一張場景圖

**Responses API**：
- 支援三種輸入格式：完整 URL、Base64 data URL、Files API 的 file ID
- `purpose: "vision"` 上傳後可重複使用，節省 token

**與 skill 的關聯**：人像一致性工作流程應說明如何透過 `images.edit` 傳入角色參考圖，Responses API 的 file ID 方式適合長流程多輪生成。

---

### 5. 官方 Prompt 結構建議
**來源**：https://developers.openai.com/cookbook/examples/multimodal/image-gen-models-prompting-guide

官方 Cookbook 建議的提示詞排序（五段式）：

1. **Scene / Background** — 環境、背景
2. **Subject** — 主體（人物 / 物件），含姿態、視線、互動
3. **Important Details** — 材質、光線、鏡頭、構圖
4. **Use case / Intended artifact** — 用途說明（編輯人像、廣告圖、UI mock 等）
5. **Constraints** — 排除項目與不變元素（最常被忽略、最有效的欄位）

**官方具體建議**：
- 人物描述：描述比例、身體框架、視線方向、與物件的互動
- 光線：指定方向、填充、高光行為，避免「魔法光」（model 預設平光化）
- 編輯模式的約束格式：「change only X」+ 「keep everything else the same」

**與 skill 的關聯**：Skill 的提示詞模板應嚴格遵循此五段順序，Constraints 欄位需列出至少 3-5 條排除指令。

---

### 6. 內容政策與安全規範
**來源**：https://deploymentsafety.openai.com/chatgpt-images-2-0 / https://developers.openai.com/api/docs/guides/image-generation

**三層安全過濾架構**：
1. **文字層（Prompt）**：safety text classifier 在生圖前先審查
2. **輸入圖層（Input）**：對傳入的參考圖進行審查
3. **輸出圖層（Output）**：生成後再次審查，不通過則不回傳

**`moderation` 參數**：
- `auto`（預設）：標準年齡適切性過濾
- `low`：較寬鬆（適用於特定平台驗證後使用）

**明確禁止項目**：
- 任何真實人物的色情或政治 deepfake
- 兒童的寫實描繪（完全禁止，規則最嚴格）
- 生化武器相關視覺資訊（設有專屬影像版 bio-risk 政策）

**已放寬的規範**（2025 起）：
- 公眾人物的中性描繪（如 Elon Musk 頭像）現在可生成
- 仇恨符號在教育／中立脈絡可生成
- 從「全面禁止」轉向「以實際危害為導向的細緻審查」

**系統安全效能**：即時模式 99.1% 對抗提示安全率；思考模式 99.2%。

**與 skill 的關聯**：Skill 的提示詞不應包含真人姓名、不應要求「寫實孩童」，虛構角色的人像生成是安全範疇。

---

## Community

### 1. Reference Image 維持人物一致性的最佳實踐
**來源**：https://charliehills.substack.com/p/how-to-prompt-gpt-image-15（2025-12）/ https://fal.ai/learn/tools/prompting-gpt-image-2（2026-04）/ https://blog.laozhang.ai/ai-tools/mastering-character-consistency-chatgpt-image-generator/（2025）

社群實測出七種一致性維持技術，其中實用度最高的：

**1. 角色錨點法（Character Anchor）**：
- 先用一次完整描述產生「錨點圖」，鎖定外貌、比例、服裝、色調
- 後續每次請求原文複貼那份描述，並加上 "Do not redesign the character"
- 使用 `images.edit` 並傳入錨點圖作為參考

**2. 視覺參考上傳（Visual Reference Anchoring）**：
- 上傳角色參考圖，在提示詞中明確標注 "Image 1: character reference"
- Fal.ai 指南建議：多張參考圖各自標注角色（"Image 1: base scene. Image 2: jacket reference"）
- `gpt-image-2` 接受最多 16 張 reference image

**3. 身份鎖定行（Identity Lock Line）**：
- 社群公認最重要的防禦性描述：明確指定要保留的「面部特徵、比例、年齡、皮膚質感、髮型、表情」
- 最常見失敗模式：「非預期美化（Unwanted Improvement）」——模型自動平滑皮膚、增加光暈

**4. DNA 模板（社群命名）**：
- 提供至少 5-7 個具體臉部特徵描述詞（如 "almond-shaped eyes with slight upward tilt at outer corners"）
- 使用精確色碼取代模糊顏色（如 "sapphire blue eyes (hex #0F52BA)" 而非 "blue eyes"）

**5. 參考圖標注角色型態（Reference Sheet Anchor）**：
- 把角色「多角度轉圖（character turnaround sheet）」作為參考圖
- 可在單一圖片中壓縮身份、服裝、調色盤、多角度資訊

**與 skill 的關聯**：Skill 應提供兩種模式——純文字錨點（適合無圖情境）與上傳參考圖模式（適合有明確角色設定的使用者）。

---

### 2. Safety Filter 常見誤觸與合規處理
**來源**：https://deploymentsafety.openai.com/chatgpt-images-2-0 / https://codewithvamp.medium.com/no-more-photo-to-art-transformations-openais-image-rules-just-changed-8aa373c6d89a / 搜尋結果彙整（2025-2026）

**常被誤觸的情境**（非 bypass，而是合規應對）：
- 醫療解剖圖：部分過濾器對「skin」「body parts」等孤立詞反應，改用 "educational fitness anatomy study" 描述可降低誤觸
- 運動服裝（泳裝、緊身運動服）：加入脈絡（場景、目的）顯著降低誤觸率，如 "competitive swimmer preparing to race at an indoor pool"
- 寫實風格人像：改以「攝影師視角」描述（鏡頭焦距、光源、構圖）比單純說 "photorealistic" 更穩定
- 相似外貌的虛構角色：加入 "fictional character, original design, no real person" 有助於通過審查

**系統性問題**：
- 社群回報執行一致性差，相似 prompt 有時通過有時被擋，無明確規律
- GPT-Image-2 改為「脈絡理解型審查」（評估整體意圖而非關鍵字比對），比前代更能區分合法的身體描繪與有害內容

**注意**：任何 jailbreak / 繞過安全系統的方法不在本文件研究範圍，且違反 OpenAI ToS。

**與 skill 的關聯**：Skill 的 prompt 模板應主動加入場景脈絡與用途說明，降低無意義誤觸；同時在說明文件中提示使用者「描述場景而非孤立的人體部位」。

---

### 3. Quality / Aspect Ratio 實測成本差異
**來源**：https://community.openai.com/t/need-help-in-understanding-the-pricing-of-image-generation-using-gpt-image-1-through-api/1335170 / https://costgoat.com/pricing/openai-images（2026-05）

**gpt-image-1 每張成本**（已知最精確定價）：

| 品質 | 1024×1024 | 1024×1536 |
|---|---|---|
| Low | $0.011 | $0.016 |
| Medium | $0.042 | $0.063 |
| High | $0.167 | $0.25 |

**gpt-image-2 Token 定價**：
- Image 輸入：$8 / 1M tokens
- Image 輸出：$30 / 1M tokens
- Text：輸入 $5、輸出 $10（/ 1M tokens）

**社群建議的成本控制工作流**：
- Draft → 用 `gpt-image-1-mini low`（約 $0.005-0.006）做 5-10 次迭代
- Final → 升級至 `gpt-image-2 high` 輸出
- 每月 50 張 `gpt-image-1` 人像（1024×1536 high quality）約 $13.50，社群認為偏高

**與 skill 的關聯**：Skill 文件應提供成本估算表，並建議分階段生成（low quality 先驗證構圖，確認後 high quality 出圖）。

---

### 4. 社群常見編輯任務與問題
**來源**：https://community.openai.com/t/gpt-image-1-5-rolling-out-in-the-api-and-chatgpt/1369443 / https://community.openai.com/t/gpt-image-1-model-at-medium-quality-how-does-it-perform/1336298

**常見任務類型**：
- 服裝替換（保留臉部）
- 背景替換（inpainting + mask）
- 風格轉換（寫實 → 水彩等）
- 多角色合成

**社群回報的已知限制**：
- `images.edit` 的遮罩編輯並非「像素精準保留」——未遮蔽區域也可能被模型重新生成（`_j` 測試確認）
- OpenAI 官方說法是「更一致地保留」，但非「原像素保留」，需在 prompt 中明確列出要保留的元素
- 時鐘/數字精確度：gpt-image-1.5 仍可能誤判時間（「9:30 not 11:55」案例）
- 某些特定藝術風格在 gpt-image-1.5 有回歸（regression），gpt-image-2 改善

**與 skill 的關聯**：人像 skill 不應過度宣稱「精確保留」；提示詞模板應在每次編輯請求中明確列出要保留的元素清單。

---

## Social / 第三方部落格

### 1. 攝影技術詞彙作為「寫實性觸發器」
**來源**：https://charliehills.substack.com/p/how-to-prompt-gpt-image-15（MarTech AI Substack，2025-12）/ https://fal.ai/learn/tools/prompting-gpt-image-2（Fal.ai，2026-04）/ https://queststudio.io/blog/photorealism-image-prompts（Quest Studio，2025）

社群最廣泛驗證的寫實人像技巧：用「攝影師的技術語言」描述影像，而非形容詞堆疊。

**有效的技術詞彙組合**：
- 鏡頭：`85mm portrait lens`、`medium format tight crop`
- 光圈：`f/1.8 shallow depth of field`、`bokeh background`
- 光源：`single soft key light from the left at 45°, slight fill from right`、`north-window light`
- 皮膚：`natural skin texture`、`subtle imperfections`、`visible pores and hair detail`、`no beauty retouching`
- 排除：`no artificial-looking retouching`、`no stock photo feel`

**完整人像 prompt 示範**（社群整合版）：
```
Scene: Modern office, exposed brick wall, warm ambient lighting, late afternoon.
Subject: 40-something man in charcoal merino crewneck, seated on desk edge, direct eye contact, neutral-confident expression.
Details: 85mm portrait lens feel, f/1.8 bokeh, single soft key light at 45° from left, warm color temperature, eye-level shot.
Use case: Editorial founder portrait for About page, 4:5 portrait format.
Constraints: No artificial retouching, no stock photo feel, no props, natural skin texture, subtle imperfections preserved.
```

**與 skill 的關聯**：Skill 應提供一份「攝影技術詞彙庫」作為人像提示詞的建構模組，使用者可依需求組合。

---

### 2. 「防禦性提示詞」取代 Negative Prompt
**來源**：https://charliehills.substack.com/p/how-to-prompt-gpt-image-15 / https://fal.ai/learn/tools/prompting-gpt-image-2

GPT Image 系列無獨立的 negative prompt 欄位，社群開發出「行內防禦性語句（inline exclusion）」方法。

**核心原則**：提示詞中的「排除指令」必須明確、具體，不能只說 "realistic"——必須同時說 "no cartoon, no anime, no illustration, do not stylise the face"。

**人像最常用的防禦語句組合**：
```
Style exclusion: Do not stylise the face. Do not cartoonise. No anime. No CGI look. No illustration.
Physics: No fantasy armour. No robes. No sci-fi elements.
Environment: No scenery clutter. No additional characters.
Output: No watermark. No logo. No extra text. No duplicate text.
```

**有效性比較**（vs SD/Midjourney）：
- Stable Diffusion 有專用 negative prompt 欄位，語法格式不同（token 權重系統）
- Midjourney 有 `--no` 參數
- GPT Image 系列的行內排除效果被社群評為「有效但需要更明確的語句」
- 省略排除語句的最常見後果：「塑膠感皮膚（plastic skin）」立即出現

**與 skill 的關聯**：Skill 的每個 prompt 模板都應包含預建的防禦性語句組，並說明此設計是 GPT Image 系列的必要補償機制（非 SD 的 negative prompt 欄位）。

---

### 3. Prompt 方法論：視覺事實 vs 抽象形容詞
**來源**：https://fal.ai/learn/tools/prompting-gpt-image-2 / https://chatcut.io/blog/how-to-use-gpt-image-2 / https://developers.openai.com/cookbook/examples/multimodal/image-gen-models-prompting-guide

**已驗證成立的核心論點**：「不要堆抽象形容詞、要寫具體視覺系統」——這不只是建議，社群與官方文件均一致強調。

**具體對比**：

| 抽象（無效） | 視覺具體（有效） |
|---|---|
| "stunning portrait" | "85mm portrait, f/1.8, eye-level" |
| "amazing lighting" | "single 45° key light, soft fill from right" |
| "beautiful skin" | "natural pores, subtle flyaway hairs, no over-smoothing" |
| "8K masterpiece" | "medium format tight crop, visible fabric texture" |
| "epic atmosphere" | "overcast daylight, brushed aluminum surface" |

**官方 Cookbook 明確確認**：
- "vague praise (stunning, epic, 8K, masterpiece)" 應替換為視覺事實
- 抽象形容詞讓模型自由發揮，結果往往「用足夠的精緻感讓你懷疑自己判斷」

**方法論補充**：
- 單次請求只改一個變數
- 迭代策略：先確認構圖 → 再確認光線 → 再確認人物細節
- "You do not need a perfect prompt. You need a direction you can react to."

**與 skill 的關聯**：Skill 的說明文件應明確反對抽象形容詞，提供「視覺詞彙替換表」，並解釋迭代工作流。

---

## Phase 2 — Google Gemini & xAI Grok 模型研究（2026-05 ultrawork 補充）

> 研究方式：3 個並行 research agent 透過 Workflow tool 跑（ultrawork multi-agent orchestration），各自研究一個模型，結果整合進 SKILL.md §19 跨模型相容性表。
> 補充原因：Phase 1（上面）只涵蓋 OpenAI 系列。Phase 2 補上 Google Gemini 3 系列與 xAI Grok Imagine。

### 7. gemini-3-pro-image-preview（Nano Banana Pro）

**來源**：
- https://ai.google.dev/gemini-api/docs/models/gemini-3-pro-image-preview
- https://ai.google.dev/gemini-api/docs/image-generation
- https://deepmind.google/models/gemini-image/prompt-guide/
- https://cloud.google.com/blog/products/ai-machine-learning/ultimate-prompting-guide-for-nano-banana
- https://blog.laozhang.ai/en/posts/gpt-image-2-vs-nano-banana-pro

**API endpoint**：

- Google AI Studio (`ai.google.dev`) 與 Vertex AI
- Primary：`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent`
- SDK：`@google/genai`（JS）、`google-generativeai`（Python）
- 無 OpenAI 相容 adapter

**Prompt 結構**：

Google DeepMind 官方建議 **5 段式（不同於 OpenAI 五段）**：

```
Style → Subject → Setting → Action → Composition
```

社群與 Google Cloud 擴展為 8 元素（人像專用）：

```
Subject + Physical Description → Composition/Framing → Environment 
→ Lighting → Camera/Lens Details → Style/Aesthetic → Mood → Quality Tags
```

**關鍵差異**：**強烈偏好 narrative paragraph，不接受 keyword stacking**。「describe the scene, don't just list keywords.」

**Negative prompt**：**無欄位**。Exclusions 必須正向重寫（「empty deserted street」非「no cars」）。

**尺寸 / Aspect ratio**：

- Aspect ratios: 1:1 / 2:3 / 3:2 / 3:4 / 4:3 / 4:5 / 5:4 / 9:16 / 16:9 / 21:9
- Resolution tier: 1K / 2K / 4K（**大寫 K**，"1K" 非 "1k"）
- 無 16 倍數約束（內部已對齊）
- 透過 `imageConfig: { aspectRatio: "9:16", imageSize: "2K" }` 指定

**Reference image**：

- 最多 14 張（6 object + 5 character 拆分）
- 透過 `inlineData`（JS）/ `inline_data`（REST）傳 base64 + mimeType
- 或 Python PIL Image 物件直接放 `contents[]`
- 大檔用 Files API
- **最佳實踐**：在 prompt 為每個 character / object 命名以保一致性

**Safety 政策**：

- **兩層系統**：可調過濾器（4 類：harassment / hate / sexually explicit / dangerous）+ 永遠開的 model-level 防護
- **Gemini 3 預設 4 類 = OFF**（可關）
- **永遠擋（不可關）**：CSAE（兒童性剝削）、非合意親密影像、暴力極端主義
- **真人 / 名人**：寫實名人圖被預設擋（error 29310472/15236754），face swap / outfit swap 也擋
  - **2026-02 Nano Banana 2 安全升級**：名人 / 臉部限制大幅收緊，**model-level baked**，無法透過 API safety settings 繞過
- **虛構人物、stylized、illustrated** 仍允許
- **SynthID watermark 強制**，所有輸出都有，不能關

**Generation 速度**：~28s（vs gpt-image-2 ~112s）。Gemini 用 `Thinking` reasoning step（支援 Thinking capability flag）。

**與 gpt-image-2 相容性**：medium

**主要差異**：

1. **Prompt format**：gpt-image-2 五段式 + inline exclusions ↔ Gemini-3-Pro 5-comp Style→...→Composition + 無 negative prompt
2. **API schema**：OpenAI flat JSON ↔ Google `contents[]` multipart — request/response 不相容，需 adapter
3. **Size**：pixel string + 16 倍數 ↔ aspect_ratio + image_size tier
4. **真人 safety**：gpt-image-2 可調 ↔ Gemini-3-Pro model-level baked
5. **Reasoning**：gpt-image-2 無顯式 reasoning step ↔ Gemini-3-Pro 'Thinking' before generate

**Trigger keywords**（給 SKILL.md description）：

`gemini-3-pro-image-preview` / `Gemini 3 Pro image` / `Nano Banana Pro` / `Google Gemini image generation` / `Gemini 圖像生成` / `Nano Banana 圖像`

---

### 8. gemini-3.1-flash-image-preview（Nano Banana Flash）

**來源**：

- https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-image-preview
- https://ai.google.dev/gemini-api/docs/image-generation
- https://www.aifreeapi.com/en/posts/gemini-3-1-flash-image-preview-vs-gemini-3-pro-image-preview
- https://blog.laozhang.ai/en/posts/gemini-image-generation-people-restriction

**API endpoint**：

- `POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent`
- 同 `@google/genai` SDK，model 改為 `"gemini-3.1-flash-image-preview"`
- 也可走 Vertex AI

**Prompt 結構**：

Google 官方 Nano Banana 5 段 narrative：

```
[Subject] + [Action] + [Location/Context] + [Composition] + [Style]
```

寫法：**flowing narrative paragraphs**，不可 keyword list。Exclusions 正向重寫。人像建議**先 emotional tone，再層次堆 photographic specifics**（lens, f-stop, lighting rig, film stock）。

**尺寸 / Aspect ratio**：

- Sizes: **512 (0.5K)** / 1K（預設）/ 2K / 4K — **比 Pro 多 512**
- Aspect: 1:1 / 1:4 / 1:8 / 2:3 / 3:2 / 3:4 / 4:1 / 4:3 / 4:5 / 5:4 / 8:1 / 9:16 / 16:9 / 21:9 — **比 Pro 多支援 1:4 / 1:8 / 4:1 / 8:1 極端比例**
- 同樣大寫 `"1K"`
- 透過 `imageConfig: { aspectRatio: "16:9", imageSize: "1K" }`

**Reference image**：

- 最多 14 張（**10 object + 4 character**，object 比 Pro 多、character 比 Pro 少）
- 同 inlineData base64 + mimeType
- 多輪 chat 支援 iterative editing

**Safety**：

- 比 gpt-image-2 嚴格
- 重點封鎖：
  1. 可辨識的真人 / 公眾人物（face swap / outfit edit / deepfake 全擋）
  2. NSFW 與隱晦的 sexual suggestion（即使無露骨關鍵字）
  3. 非合意親密影像、政治 deepfake、醫療誤導、針對性騷擾
  4. 兒童安全內容（永遠擋）
- 同 SynthID watermark 強制
- 「Grounding with Google Search 不可用於搜尋人物」
- API tier 比消費級 Gemini app 略寬，但核心限制相同

**與 gpt-image-2 相容性**：medium

**主要差異**：

1. 同 Pro 的 narrative paragraph 強制
2. Reference 14 張（10+4 分配）
3. **比 Pro 多支援 512 解析度**（快 / 便宜，draft 用）
4. **比 Pro 多極端比例**（1:4 / 1:8 / 4:1 / 8:1）
5. Safety 比 gpt-image-2 嚴格，特別在 implicit suggestive content

**Trigger keywords**：

`gemini flash image` / `gemini 3.1 flash` / `nano banana 2` / `Nano Banana Flash` / `Gemini Flash 圖像` / `Nano Banana 圖像`

---

### 9. grok-imagine-image-quality（xAI Grok Imagine）

**來源**：

- https://docs.x.ai/developers/model-capabilities/images/generation
- https://docs.x.ai/docs/guides/image-generations
- https://docs.x.ai/developers/model-capabilities/images/editing
- https://runware.ai/docs/models/xai-grok-imagine-image-quality
- https://www.genaintel.com/guides/how-to-prompt-grok-imagine

**API endpoint**：

- `POST https://api.x.ai/v1/images/generations`（xAI API）
- **OpenAI SDK 相容（text-to-image only）**：設 `base_url="https://api.x.ai/v1"`
- Image editing 不相容（xAI 用 application/json + base64 / URL；OpenAI 用 multipart/form-data）—— 編輯要走 xAI SDK 或直接 HTTP
- xAI Python SDK：`client.image.sample()` 與 `client.image.sample_batch()`

**Prompt 結構**：

Grok 用 natural-language narrative 架構（**回應 scene description，不接受 keyword stacking**）。社群共識 5 段：

```
[Scene/Subject] + [Style/Aesthetic] + [Mood/Emotion] + [Lighting] + [Camera/Lens/Framing]
```

每段寫成 plain English，不要 comma-separated tags。範本：

```
Close-up of [subject] in [setting], [emotion/mood] atmosphere, 
[lighting description], shot on [camera/lens], [style keywords].
```

**Negative prompt**：無 `negative_prompt` 參數。Inline `no [X]` 模型理解但**不如 gpt-image-2 `--no` 穩定**。建議**將 negative 意圖自然嵌入 positive description**。

**尺寸 / Aspect ratio**：

- **14 個 aspect ratios**：1:1 / 16:9 / 9:16 / 4:3 / 3:4 / 3:2 / 2:3 / 2:1 / 1:2 / 19.5:9 / 9:19.5 / 20:9 / 9:20 / `auto`
- 兩個解析度 tier：1K / 2K
- 範例 1K 對照：1:1 = 1024×1024、3:4 = 896×1280、2:3 = 864×1296、9:16 = 768×1408
- 範例 2K 對照：1:1 = 2048×2048、3:4 = 1712×2432、2:3 = 1664×2496、9:16 = 1504×2752
- **像素不一定 16 倍數**，無 16 倍數約束
- 人像最佳比例：3:4 / 2:3 / 9:16
- Output format: JPG（預設）/ PNG / WEBP
- 不接受 width/height 自由指定，**必須用 aspect_ratio + resolution tier 配對**

**Reference image**：

- **最多 3 張**（vs Gemini 14 / gpt-image-2 16）
- 透過 public URL 或 base64-encoded data URI（application/json，**不是 multipart**）
- 單張編輯時，output aspect 跟輸入一致
- 多張編輯時，`aspect_ratio` 參數適用
- Reference 圖**額外計費 +$0.01 / image**
- 多輪 chaining 支援（output → 下次 input）
- 支援風格轉換：realistic photo / anime / oil painting / pencil sketch

**Safety**（更新後）：

- **2026 已大幅收緊**：
  - 2025 年中曾有的 "Spicy Mode" NSFW 功能**已移除**（2026-01 deepfake controversy 後）
  - 2026 起 xAI 對疑似 CSAM 通報 NCMEC
- **永遠擋（所有 tier 含 API）**：
  1. CSAM（任何兒童性化）
  2. 非合意親密影像 / deepfake
  3. 真人色情化描繪
  4. 隱私 / 公開權侵犯
- API response 含 `respect_moderation` boolean 標記是否通過 moderation
- 過濾器是**預測性分析**（評估「可能輸出」而非僅 prompt 文字）
- **上傳真人臉部會提升 filter 敏感度**
- 灰色地帶藝術內容是個案審查，無公開白名單
- **真人 likeness 編輯（如改穿著）所有 tier 都擋**，包括付費用戶

**與 gpt-image-2 相容性**：medium

**主要差異**：

1. **Architecture**：xAI 自家架構（非 DALL-E / Imagen），narrative 強過 keyword
2. **Aspect ratio**：named ratios + 1K/2K tier ↔ gpt-image-2 pixel + 16 倍數 — 不能直接平移
3. **Image editing**：application/json body ↔ multipart/form-data — SDK-level 編輯不相容
4. **Negative prompt**：無 dedicated parameter，要嵌入 positive description
5. **Safety**：歷史上較寬，2026 大幅收緊；真人 likeness 編輯比 gpt-image-2 嚴格

**Trigger keywords**：

`grok imagine` / `grok image` / `grok-imagine-image-quality` / `xAI image generation` / `grok portrait` / `grok 圖片生成` / `grok 畫像`

---

### 10. 跨模型差異總表（速查）

| 維度 | gpt-image-2 | gemini-3-pro | gemini-3.1-flash | grok-imagine |
|------|------------|--------------|-----------------|--------------|
| 發布 | 2026-04 | 2025-12 ~ 2026 | 2026 | 2025-2026 持續更新 |
| Prompt 風格 | 5 段條列 OK | **narrative paragraph 強制** | **narrative paragraph 強制** | 平實英文敘事句 |
| Negative prompt | inline `No X` | **無欄位，正向重寫** | **無欄位，正向重寫** | 無參數，嵌入敘事 |
| 尺寸指定 | 像素字串 + 16 倍數 | `aspect_ratio` + tier (1K/2K/4K) | + tier (512/1K/2K/4K) | named ratios + 1K/2K |
| Aspect 數量 | 任意（兩邊 16 倍數 + ratio ≤ 3:1）| 10 種 | 14 種（多 1:4/4:1/8:1）| 14 種（多 19.5:9 等）|
| Reference 上限 | 16 張 | 14（6 obj + 5 char）| 14（10 obj + 4 char）| 3 張 |
| API endpoint | OpenAI `/images/generations` | Google `generateContent` 多模態 | 同上 | xAI `/v1/images/generations` |
| Image edit | multipart/form-data | inlineData base64 | 同上 | application/json + URL/base64 |
| 真人 / 名人 | 預設 auto 過濾、可調 | **model-level baked 強制封鎖** | **同上、額外擋 implicit suggestive** | **真人 likeness 編輯全擋** |
| Watermark | 無 | **SynthID 強制** | **SynthID 強制** | 無 |
| Speed | ~112s | ~28s | 較快 | 取決於 tier |
| OpenAI SDK 相容 | ✓ 原生 | ✗ | ✗ | △（text-to-image only）|

---

### 11. 為何各模型適合不同場景（依研究結論）

| 場景 | 推薦模型 | 理由 |
|------|---------|------|
| 預設、最廣支援、Reference 多 | `gpt-image-2` | 16 張 reference、彈性 pixel size、五段式 + inline exclusions |
| 高品質 + 較快 + Vertex AI 環境 | `gemini-3-pro-image-preview` | ~28s（vs 112s）、Thinking reasoning、narrative paragraph |
| Draft 迭代 / 大量批次 / 低成本 | `gemini-3.1-flash-image-preview` | 512 tier、極端比例、Flash 級成本 |
| X / Grok 平台、3 ref 內 | `grok-imagine-image-quality` | xAI 生態、OpenAI SDK 部分相容 |
| 真人肖像（非名人）寫實照 | `gpt-image-2` | Gemini / Grok 對真人 likeness 限制更嚴 |
| 多角色 character consistency 場景 | `gemini-3-pro-image-preview` | 5 個 character ref + 命名機制 |
| 多角度產品 + 角色 同框 | `gemini-3-pro-image-preview` | 6 object + 5 char 分配 |

---

## 拒絕納入清單

### [拒絕] 安全過濾器 bypass 技術
- **涉及內容**：部分搜尋結果包含「White Smoke Attack」（2026-04，GPT-Image-2 發布數小時內被利用的多模態漏洞）的技術細節，以及多篇「如何繞過 ChatGPT 圖像內容政策」指南
- **來源 URL**：https://www.glbgpt.com/hub/how-to-get-around-chatgpt-content-policy-for-images/ 等（刻意不完整引用）
- **拒絕理由**：這些技術旨在破壞安全系統，違反 OpenAI ToS，可能涉及生成有害內容（deepfake、非合意圖像等），與本 skill 的合規人像生成目標完全相悖。本研究僅記錄「安全過濾器確實存在且有多層架構」，不記錄任何繞過方法。

### [拒絕] NSFW 內容生成指南
- **涉及內容**：搜尋結果中出現多篇「如何用 GPT Image 2 生成 NSFW 圖像」的教學，含具體替代模型推薦
- **拒絕理由**：超出合規人像生成範疇，且此類內容在一般 API 使用中受 moderation 過濾，不應納入 skill 設計參考。

### [拒絕] 特定真實人物的 prompt 範本
- **涉及內容**：部分第三方部落格提供「生成特定名人外貌」的範本（如特定科技業人士）
- **拒絕理由**：即使 OpenAI 已放寬對公眾人物的限制，為特定真實人物提供冒名生成模板仍有肖像權與誤導資訊風險，不納入 skill 設計。

### [拒絕] 利用 Grok 較寬鬆安全策略繞過其他模型限制
- **涉及內容**：2026-01 deepfake controversy 後 Grok 已大幅收緊，但仍有部落格教學「Grok 還能做 X，OpenAI / Gemini 不行」
- **拒絕理由**：本 Skill 對所有支援的模型（gpt-image-2 / Gemini 3 系列 / Grok Imagine）**統一適用相同嚴格安全立場**——不論該模型實際過濾門檻，本 Skill 仍依 §27 反繞過聲明拒絕所有 jailbreak / 繞過 / 真人 likeness / 未成年性化 / 多人親密接觸請求。Grok 預設較寬不等於本 Skill 可以放寬。

---

## 待確認 / 未找到

### 待確認

1. **`gpt-image-2` 的 4K 實際品質**：官方標注 Experimental，但無具體的品質比較數據或社群大量實測報告（截至 2026-05-25，模型發布僅約 1 個月）

2. **`moderation: "low"` 的實際寬鬆幅度**：官方文件有此參數但未明確說明對人像生成有什麼具體效果，社群亦缺乏系統性測試

3. **Responses API 的 `action: "auto"` 行為**：文件說明模型會自動判斷 generate 或 edit，但尚未找到社群對此行為的詳細實測報告

### 未找到

1. **官方對「photorealistic vs 3D/illustration 模式」的明確建議**：官方文件無獨立章節；社群建議是在 prompt 中明確包含「photorealistic」或藝術風格詞彙，但沒有官方 A/B 比較或最佳實踐頁面

2. **人物一致性的官方評估指標**：官方無量化的一致性定義或測試基準（GIE-Bench 是第三方研究，非官方發布）

3. **`gpt-image-2` 的每張圖定價表**：官方僅提供 token-based 定價，未如 gpt-image-1 般提供「每張圖固定價格」清單；第三方計算器提供估算但各有出入

### Phase 2 補充待確認

4. **Gemini-3 4K 實際品質**：tier 制下「4K」實際輸出品質與成本未實測（社群只有 1K/2K 對比）

5. **Grok-Imagine OpenAI SDK 相容性實測**：xAI 宣稱 text-to-image 相容，但本研究未測試實際 API call 的細節差異（如 response 結構、error code 對應）

6. **Gemini 3.1 Flash vs Pro 跨任務 A/B**：兩者價格差異與品質差異的量化對比資料稀少

---

*Phase 1 基於 2026-05-25 的公開資訊（OpenAI 系列）。Phase 2 基於同期 ultrawork 並行研究（Google Gemini 3 系列 + xAI Grok Imagine）。模型規格與政策可能隨各家更新而變動。建議定期以官方文件為準校對：*
- *OpenAI: https://developers.openai.com/api/docs/guides/image-generation*
- *Google Gemini: https://ai.google.dev/gemini-api/docs/image-generation*
- *xAI Grok: https://docs.x.ai/developers/model-capabilities/images/generation*
