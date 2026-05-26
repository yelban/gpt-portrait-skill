# 攝影語言詞庫（完整版）

> 寫實人像 prompt 的詞彙工具箱。SKILL.md 只列高頻速查；需要完整選項時查這份。

核心原則（出自 OpenAI Cookbook + Fal.ai + 社群實測）：

**用攝影師的技術語言描述影像，不要堆抽象形容詞。** 模型對「85mm f/1.8 single 45° key light」的反應遠強於「stunning portrait amazing lighting」。

---

## 1. 攝影脈絡 / Editorial Context

把 prompt 定位在一個明確的視覺脈絡，能大幅提升模型輸出穩定度。

### 雜誌類

- photorealistic editorial portrait
- premium fashion magazine spread
- Vogue-style editorial（避免冠名特定刊物，但「magazine spread」是安全的）
- lifestyle magazine cover story
- 寫真集 photobook spread
- documentary-style portrait
- brand lookbook photography
- commercial portrait photography
- cinematic portrait

### 攝影師類

- studio editorial portrait
- natural light portrait
- environmental portrait
- candid lifestyle shot
- street fashion photography
- behind-the-scenes editorial moment

### 日文社群驗證（適合東亞 editorial 美學）

- 日本のファッション誌 → Japanese fashion magazine editorial
- ネイチャービジュアル特集 → nature visual feature
- 写真集の見開きページ → photobook double-page spread
- ドキュメンタリースタイル → documentary style portrait

---

## 2. 鏡頭與光圈（gpt-image-2 寫實觸發器）

### 鏡頭焦距

| 焦距 | 用途 | 視覺效果 |
|------|------|----------|
| `24mm` | 環境人像 | 廣角、空間感、邊緣輕微變形 |
| `35mm` | 街拍 / 環境人像 | 自然視角、含環境 |
| `50mm` | 標準 | 接近人眼視角、自然 |
| `85mm` | 人像標準 | 壓縮空間、人像主流 |
| `135mm` | 特寫人像 | 強壓縮、絲滑散景 |
| `medium format tight crop` | 中片幅緊構圖 | 高細節、商業質感 |

### 光圈（數字越小景深越淺）

- `f/1.4` — 極淺，前景背景強烈散景
- `f/1.8` — 人像常用，眼睛清晰其他柔散
- `f/2.0` — 通用人像
- `f/2.8` — 半身 + 環境
- `f/4.0` — 全身 + 環境清晰
- `shallow depth of field`、`creamy bokeh`、`bokeh background`、`out-of-focus background` 為輔助描述

### 構圖

- `medium close-up` — 胸口以上
- `upper-body portrait` — 半身
- `framed from upper body to mid-thigh` — 七分身
- `three-quarter body framing` — 大腿中段
- `full-body fashion lookbook shot` — 全身
- `eye-level composition` — 平視
- `slight three-quarter angle` — 微側
- `slightly high editorial angle` — 微俯（避免低角度俯瞰身體）

---

## 3. 光線（方向 + 性質 + 時段）

### 方向（最關鍵）

- `single key light from the left at 45°` — 標準人像光
- `single soft key light from above at 30°` — 林布蘭光
- `side backlight from the right` — 側逆光，勾輪廓
- `golden-hour backlight` — 黃金時段逆光
- `north-window light` — 北面窗光，柔和均勻
- `rim light outlining the shoulder and hair` — 輪廓光
- `soft fill from a pale wall` — 反光板柔和填充

### 性質

- `soft diffused window light` — 柔和擴散
- `hard sunlight with sharp shadows` — 硬光
- `overcast daylight` — 陰天均勻光
- `cinematic neon glow` — 電影感霓虹
- `warm tungsten interior lighting` — 暖色室內燈
- `clean studio softbox lighting` — 影棚柔光箱
- `subtle film grain` — 輕微底片顆粒

### 時段

- `warm morning light` — 晨光
- `golden hour, around sunset` — 黃金時段
- `blue hour, just after sunset` — 藍調時刻
- `late afternoon soft light` — 午後柔光
- `cool overcast midday` — 陰天正午

### 日文社群有效詞

- `木漏れ日が横顔に細く差し込む` → `dappled tree light grazing the side of her face`
- `逆光の眩しい光が全身を包み込む` → `bright backlight wrapping her entire silhouette`
- `水しぶきが逆光でキラキラと輝く` → `backlit splashing water glittering against the light`（注意：濕潤感僅能作用於環境）

### 應該避免的「魔法光」抽象詞

- ❌ `magical lighting` / `epic lighting` / `dreamy lighting` / `perfect lighting` / `god rays everywhere`

模型對抽象光描述會「平光化」（變成平淡均勻光）。寫明方向 + 性質才有效。

---

## 4. 材質（服裝與布料）

### 布料類型

- `natural fabric texture` — 通用，必加
- `soft knit texture` — 柔針織
- `silk fabric with gentle sheen` — 真絲微光
- `cotton-linen texture` — 棉麻
- `tailored wool blazer` — 修身羊毛西外
- `cashmere coat` — 喀什米爾大衣
- `flowing chiffon dress fabric` — 雪紡垂墜
- `crepe fabric with subtle pleats` — 縐紗微褶
- `denim with visible weave` — 牛仔布

### 細節描述

- `subtle pleats` — 細褶
- `soft drape` — 柔垂感
- `refined fabric layering` — 精緻分層
- `slight surface texture, no flat plastic look` — 表面紋理，避免塑膠感
- `visible fabric weave` — 可見織紋
- `delicate stitching detail` — 細緻車線

### 飾品

- `simple gold-tone earrings` — 簡約金色耳環
- `delicate silver necklace` — 細緻銀項鍊
- `minimal jewelry, no fashion accessories overload` — 飾品克制

---

## 5. 膚質與妝容

### 寫實膚質

- `real skin texture` — 必加
- `natural skin pores` — 自然毛孔
- `subtle imperfections preserved` — 保留輕微瑕疵（雀斑、毛孔）
- `visible pores and hair detail` — 可見毛孔與細毛
- `realistic complexion` — 真實膚色
- `subtle skin undertones` — 自然底色

### 妝容

- `subtle makeup` — 自然妝感
- `clean makeup` — 乾淨妝
- `soft blush` — 柔和腮紅
- `natural lip color` — 自然唇色
- `dewy skin finish, not glossy` — 輕透不油亮
- `matte finish makeup` — 啞光妝感

### 強制排除（必加，避免塑膠感）

- `no plastic skin`
- `no over-smoothing`
- `no beauty retouching`
- `no airbrushed look`
- `no waxy look`
- `no AI artifacts`

省略以上排除語句的最常見後果：塑膠感皮膚立即出現（社群實測）。

---

## 6. 髮絲與動態

- `detailed hair strands` — 髮絲細節（3D CG 模式必加）
- `natural flyaway hairs` — 自然碎髮
- `subtle wind in hair` — 髮絲輕微飄動
- `soft hair backlight` — 髮絲逆光高光
- `silky hair texture` — 絲滑質感
- `slight hair imperfection, not perfectly groomed` — 微亂不假

---

## 7. 色調與後製

- `warm-neutral color grading` — 暖中性
- `cool desaturated color grading` — 冷低飽和
- `cinematic color grading` — 電影感調色
- `editorial muted tones` — 雜誌低飽和
- `slight teal-and-orange grading` — 青橙
- `natural daylight color temperature` — 自然色溫
- `subtle film grain` — 底片顆粒（增加質感）

---

## 8. 物理瑕疵負面詞（必加進 Constraints）

### 手部 / 肢體

- `no deformed hands`
- `no extra fingers`
- `no missing fingers`
- `no fused fingers`
- `no broken anatomy`
- `no disproportionate limbs`

### 臉部

- `no facial distortion`
- `no asymmetric eyes`
- `no melted features`
- `no doll-like uncanny face`

### 布料 / 飾品

- `no fabric warping`
- `no melted clothing`
- `no broken straps`
- `no pattern misalignment`
- `no jewelry distortion`

### 品質

- `no AI artifacts`
- `no oversharpened edges`
- `no low resolution`
- `no collage feel`
- `no banding`

### 風格污染

- `do not stylize the face`
- `do not cartoonize`
- `no anime style`
- `no CGI look`
- `no illustration`
- `no fantasy armor`（除非 3D CG 模式）

---

## 9. 完整視覺語言檢查清單

寫 prompt 時，每個欄位至少有一個具體詞：

| 欄位 | 至少要有 |
|------|---------|
| Scene | 場所 + 時段 + 氛圍 |
| Subject | 年齡 + 族裔 + 表情 + 姿態 |
| Wardrobe | 版型 + 材質 + 顏色 |
| Camera | 焦距 + 光圈 + 角度 + 構圖 |
| Lighting | 方向 + 性質 + 時段 |
| Mood | 情緒詞 + 色調 |
| Quality | photorealistic + skin texture + fabric texture |
| Constraints | Style + Subject + Environment + Output + 物理瑕疵 |

每個欄位都缺則模型自由發揮，結果不可控。每個欄位都有則 prompt 約 150-300 字，可以穩定出商業品質。
