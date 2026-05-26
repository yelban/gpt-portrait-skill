# gpt-image API Reference

> 更新時間：2026-05-25
> 來源：OpenAI Platform docs、OpenAI Cookbook、Community Forum（見 `/docs/research-notes.md`）

需要呼叫 gpt-image API、決定模型 / 尺寸 / 成本時查這份。SKILL.md 只列預設值。

---

## 模型對照表

| 官方 API 名稱 | 發布 | 定位 | 何時用 |
|--------------|------|------|--------|
| `gpt-image-1` | 2025-04-23 | 第一代旗艦（**Legacy，2026-10-23 停用**）| 不建議新案 |
| `gpt-image-1-mini` | 2025-10-06 | 低成本版，比 gpt-image-1 便宜 80% | Draft 迭代、大量批次 |
| `gpt-image-1.5` | 2025-12-16 | 中間旗艦，速度 +4x、成本 -20% | 成本敏感、固定尺寸即可 |
| `gpt-image-2` | 2026-04-21 | 現行旗艦，整合 O-series 推理 | **預設**。最新品質、彈性尺寸、reference image |

---

## API 端點

### Images API

| 端點 | 用途 |
|------|------|
| `POST /v1/images/generations` | 文字生圖 |
| `POST /v1/images/edits` | 圖片編輯（含 reference image，最多 16 張）|

### Responses API（多輪 / 工具用）

支援 `previous_response_id`、`action: auto / generate / edit`，可自動判斷使用者意圖。

---

## 主要參數

| 參數 | 類型 | 說明 | 備注 |
|------|------|------|------|
| `model` | string | 模型名稱 | 必要 |
| `prompt` | string | 文字描述 | 必要 |
| `n` | int | 生成張數 | 預設 1 |
| `size` | string | 圖片尺寸 `WxH` | 見尺寸節 |
| `quality` | `low / medium / high / auto` | 品質檔位 | 預設 `auto` |
| `background` | `opaque / auto` | 背景 | `gpt-image-2` 不支援 transparent |
| `moderation` | `auto / low` | 內容審查嚴格度 | 預設 `auto`，不要預設 `low` |
| `output_format` | `png / jpeg / webp` | 輸出格式 | 預設 `png` |
| `output_compression` | int (0-100) | JPEG/WebP 壓縮率 | 僅 jpeg/webp 適用 |
| `stream` | bool | 啟用串流 | |
| `partial_images` | int (0-3) | 串流中途回傳草稿 | |
| `input_fidelity` | `low / high` | 輸入圖保真度 | `gpt-image-2` 預設高保真，無此參數；gpt-image-1.x 可選 |
| `input_image_mask` | file (PNG with alpha) | 編輯遮罩 | 編輯端點專用，上限 50MB |

### response_format 行為

- `gpt-image-1` 系列：回傳 `b64_json`（**不支援** `url` 格式）
- `gpt-image-2`：同樣 `b64_json`，可指定 `output_format` 改變編碼

---

## 尺寸完整對照

### `gpt-image-1 / 1.5 / mini`（固定三種）

| 比例 | 尺寸 |
|------|------|
| 1:1 | 1024×1024 |
| 2:3 直式 | 1024×1536 |
| 3:2 橫式 | 1536×1024 |
| auto | 由 prompt 決定 |

### `gpt-image-2`（彈性尺寸）

**規則**：
- 最大邊 ≤ 3840px
- 兩邊皆須為 **16 的倍數**
- 長寬比 ≤ 3:1
- 總像素：655,360 ~ 8,294,400

**官方推薦熱門尺寸**：

| 標籤 | 解析度 | 比例 | 狀態 |
|------|--------|------|------|
| HD 直式 | 1024×1536 | 2:3 | 穩定 |
| HD 橫式 | 1536×1024 | 3:2 | 穩定 |
| HD 正方形 | 1024×1024 | 1:1 | 穩定 |
| 2K / QHD 直式 | 1440×2560 | 9:16 | 穩定 |
| 2K / QHD 橫式 | 2560×1440 | 16:9 | 穩定 |
| **4K / UHD 直式** | 2160×3840 | 9:16 | **Experimental** |
| **4K / UHD 橫式** | 3840×2160 | 16:9 | **Experimental** |

### 本 Skill 推薦尺寸（覆蓋常見社群比例）

| 比例 | 標準 | 2K 高品質 | 4K Experimental |
|------|------|-----------|----------------|
| 1:1  | 1024×1024 | 2048×2048 | — |
| 3:4  | 1152×1536 | 1536×2048 | — |
| 4:5  | 1024×1280 | 1536×1920 | — |
| 2:3  | 1024×1536 | 1536×2304 | — |
| 9:16 | 1152×2048 | 1440×2560 | 2160×3840 |
| 16:9 | 2048×1152 | 2560×1440 | 3840×2160 |

驗算：所有上列尺寸兩邊都是 16 倍數（如 1152 = 72×16、1536 = 96×16、2048 = 128×16、2560 = 160×16、3840 = 240×16）。

---

## 成本估算

### `gpt-image-1` per-image 定價

| 品質 | 1024×1024 | 1024×1536 |
|------|-----------|-----------|
| Low | $0.011 | $0.016 |
| Medium | $0.042 | $0.063 |
| High | $0.167 | $0.25 |

### `gpt-image-2` Token 定價

| 項目 | 價格 |
|------|------|
| Image 輸入 | $8 / 1M tokens |
| Image 輸出 | $30 / 1M tokens |
| Text 輸入 | $5 / 1M tokens |
| Text 輸出 | $10 / 1M tokens |

### 成本控制工作流（社群推薦）

1. **Draft 階段**：`gpt-image-1-mini` + `quality: low` → 約 $0.005-0.006 / 張，5-10 次迭代驗構圖
2. **構圖確認**：`gpt-image-1.5` + `quality: medium` → 平衡速度與品質
3. **最終出圖**：`gpt-image-2` + `quality: high` → 一次出圖即用

每月 50 張 `gpt-image-1` 人像（1024×1536, high）約 **$13.50**。`gpt-image-2` 估算略高，無官方 per-image 表，需依 token 估算。

---

## Reference Image 完整工作流

### Images API 編輯端點

```bash
curl -X POST https://api.openai.com/v1/images/edits \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F model="gpt-image-2" \
  -F image[]="@anchor.png" \
  -F image[]="@outfit-ref.png" \
  -F prompt="Image 1: character reference. Image 2: outfit reference. ..." \
  -F size="1152x1536" \
  -F quality="high"
```

```python
from openai import OpenAI
client = OpenAI()

response = client.images.edit(
    model="gpt-image-2",
    image=[
        open("anchor.png", "rb"),
        open("outfit-ref.png", "rb"),
    ],
    prompt="Image 1: character reference. Image 2: outfit reference. ...",
    size="1152x1536",
    quality="high",
)
```

### Responses API（file_id 重複使用）

```python
# 第一次上傳
upload = client.files.create(
    file=open("anchor.png", "rb"),
    purpose="vision",
)
anchor_file_id = upload.id

# 後續多次請求重用同一個 file_id（節省上傳 token）
response = client.responses.create(
    model="gpt-image-2",
    input=[{
        "role": "user",
        "content": [
            {"type": "input_text", "text": "<prompt>"},
            {"type": "input_image", "file_id": anchor_file_id},
        ]
    }],
)
```

### 參數注意

- `images.edit` 並非「像素精準保留」——未遮蔽區域也可能被重新生成。必須在 prompt 明列要保留的元素
- 多張 reference 時在 prompt 明確標注角色，如 `Image 1: character reference. Image 2: jacket style reference.`
- 編輯模式的約束格式：`change only X` + `keep everything else the same`

---

## moderation 參數

| 值 | 行為 |
|----|------|
| `auto`（預設）| 標準年齡適切性過濾 |
| `low` | 較寬鬆，適用於**特定平台已做年齡驗證**後使用 |

**注意**：`moderation: "low"` 不會打開色情或未成年內容；只是降低部分 false positive。官方未提供量化說明，社群實測差異不顯著。本 Skill 不預設 `low`。

---

## 三層安全審查（背景）

| 層 | 審查對象 |
|----|---------|
| 文字層 | Prompt 文字 safety classifier |
| 輸入圖層 | 上傳的 reference image |
| 輸出圖層 | 生成完成後再次審查，不過則不回傳 |

`gpt-image-2` 改為「脈絡理解型審查」（評估整體意圖而非關鍵字比對），對偽裝詞、藝術詞包裝的性化內容更敏感。

---

## 待確認

- `gpt-image-2` 的 4K 實際品質（發布僅約 1 個月，社群實測稀少）
- `moderation: "low"` 對人像生成的具體寬鬆幅度
- Responses API 的 `action: "auto"` 在 reference image 情境的行為
- `gpt-image-2` per-image 固定定價（目前只有 token-based）
