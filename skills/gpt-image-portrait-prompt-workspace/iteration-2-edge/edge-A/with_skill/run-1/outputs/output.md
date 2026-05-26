## 1. 參數鎖定覆核

✓ 寫真風格【鎖定】：電影故事感
✓ 五官方向【鎖定】：清冷高級臉
✓ 場景方向【鎖定】：城市街頭
✓ 服裝方向【鎖定】：西裝外套
✓ 氣質標籤【鎖定】：故事感
✓ 身形方向【鎖定】：豐腴曲線
✓ 線條強調【鎖定】：中
✓ 鏡頭方向【鎖定】：半身到大腿
✓ 畫幅比例【鎖定】：9:16

---

## 2. 完整生成 Prompt

Scene: A city street in the late afternoon — muted overcast daylight filtering through urban buildings, shallow background of blurred pedestrians and storefronts rendered in soft cinematic bokeh, wet pavement catching residual light, a quiet atmospheric tension between stillness and movement.

Subject: A clearly adult East Asian woman, around 22–28 years old, with a mature adult facial structure and no teen-coded styling. Oval face with a refined sculpted jawline and subtle cheekbones. Long narrow eyes with flat double eyelids and a cool composed gaze directed slightly away from camera — no smile, no warmth, a quiet gravity. Straight refined nose bridge with a defined tip. Thin refined lips in a neutral expression. Clean angular bone structure with subtle balanced asymmetry. Her presence reads as cinematic and story-heavy, like a character mid-scene. She carries a healthy mature voluptuous figure with an elegant S-shaped silhouette — soft fullness at the bust, a clearly defined waistline with natural hip transition, and gracefully rounded body line, balanced proportions without exaggeration, mature feminine form with composed dignity. Natural curves shaped by tailored clothing and refined posture.

Details: She wears a structured oversized blazer in charcoal or dark camel, tailored fit with precise shoulder line, lapels sharp, worn slightly open over a fitted inner layer — the blazer silhouette skims the body, emphasizing waistline and hip transition through tailoring rather than tightness. One hand rests near the jacket lapel or at her side, shoulders relaxed, neck elongated. Framed from upper body to mid-thigh, 85mm portrait lens feel, f/1.8 shallow depth of field, slight three-quarter editorial angle, eye-level composition. The blazer's structured shoulder line and body-skimming cut reveal natural curves with restraint — refined silhouette with clear waistline and balanced hip transition visible through drape and posture rather than explicit fit.

Lighting: Single 45° key light from the left, soft diffused quality mimicking overcast city light, gentle fill from a pale building facade on the right, cool-neutral cinematic color grading with slight desaturation, subtle film grain, real skin texture preserved — natural pores, no beauty retouching, no over-smoothing. A faint rim light traces the edge of her right shoulder and jaw from a distant reflective surface, reinforcing depth without drama.

Use case: Cinematic editorial portrait for a fashion film lookbook or narrative magazine spread, 9:16 portrait format.

Constraints: Do not stylize the face. Do not cartoonize. No anime. No CGI look. No illustration. No fantasy styling. No nudity. No lingerie styling. No erotic pose. No explicit cleavage focus. No body-part close-up. No low-angle body gaze. No voyeuristic framing. No childlike features. No teen styling. No school uniform. No exaggerated anatomy. No oversized anatomy. No bursting or bulging clothes. No skintight clothing emphasizing breasts or hips. No plastic skin. No over-smoothing. No AI artifacts. No waxy look. No deformed hands. No extra fingers. No missing fingers. No broken anatomy. No facial distortion. No asymmetric eyes. No fabric warping. No melted clothing. No watermark. No logo. No extra text. No frame border. No additional characters.

PARAMETERS:
model: gpt-image-2
size: 1152x2048
quality: high
output_format: png
moderation: auto

---

## 3. 本次自動補全部分

本次 9 個參數全部由使用者明確填寫，無自動補全項。以下說明各鎖定參數的細化展開邏輯：

- **髮型**（參數表未列，自動補全）：深棕色或黑色直髮，微微散落，長度至肩下，髮絲細節自然——與「清冷高級臉」骨相和「電影故事感」氛圍吻合，不做過度造型
- **妝容**（參數表未列，自動補全）：極簡妝容，皮膚質感為重——subtle skin base, barely-there contour, no bright lip color——冷感氣質的配妝邏輯
- **內搭**（服裝方向僅指定「西裝外套」，內搭自動補全）：fitted dark tonal inner layer（高領針織或簡約上衣），保持整體色調沉穩，避免打斷視覺語言

---

## 4. 主要吸睛點

- **第一眼**：清冷骨相 + 西裝銳利肩線——冷感眼神與挺括西裝形成「冰川邊緣」視覺記憶點，觀者會先被臉抓住，再被肩線留住
- **第二層**：豐腴曲線在西裝剪裁下的優雅 S 線——腰線與臀腿過渡在西裝版型的節制下若隱若現，感知到而非被強調，形成高級張力
- **第三層**：城市漫射光 + 電影色調——muted overcast 光質 + 冷中性 grading + 淡淡膠片顆粒，構成「一個女人在城市某個角落等待或剛剛離開」的敘事情緒層

---

## 5. 負面限制詞（已嵌入 Prompt Constraints 段）

**物理瑕疵防禦（§17.4）**
- No deformed hands, no extra fingers, no missing fingers, no broken anatomy
- No facial distortion, no asymmetric eyes
- No fabric warping, no melted clothing
- No plastic skin, no over-smoothing, no AI artifacts, no waxy look

**安全邊界（§17.3 四層）**
- Style 排除：Do not stylize the face. Do not cartoonize. No anime. No CGI look. No illustration.
- Subject 排除：No childlike features. No teen styling. No school uniform. No exaggerated anatomy.
- Environment 排除：No additional characters. No scenery clutter.
- Output 排除：No watermark. No logo. No extra text. No frame border.

**豐腴曲線安全護欄（§9.3）**
- No explicit cleavage focus. No body-part close-up. No low-angle body gaze. No bursting or bulging clothes. No skintight clothing emphasizing breasts or hips. No oversized anatomy.

**風格污染防禦**
- No voyeuristic framing. No erotic pose. No lingerie styling. No nudity.
