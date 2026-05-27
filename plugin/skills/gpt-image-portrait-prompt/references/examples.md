# 五段式 Prompt 完整範例

> 本檔案為 SKILL.md §22–§25 的完整輸出範例。
> 主 SKILL.md 僅說明「何時使用五段式」與基本結構，詳細 few-shot 範例請閱讀本檔。

**重要**：這些範例的主要目的是告訴模型「五段式 + Constraints 應該長什麼樣子」。在實際使用時，**不要直接複製**，而是根據當前使用者需求重新組裝。

---

## 範例 1：預設寫真 prompt（Mode A）

使用者輸入：「幫我生成一張女性寫真 prompt，風格你決定，3:4。」

**輸出結構參考**：

PROMPT:
Scene: ...
Subject: ...
Details: ...
Lighting: ...
Use case: ...
Constraints: Do not stylize the face. ...（四層防禦 + 物理瑕疵）

PARAMETERS:
model: gpt-image-2
size: 1152x1536
...

---

## 範例 2：Reference Image 人物一致性

使用者輸入：「用參考圖的人物，換成都市夜景街拍，9:16，保持臉一樣。」

**關鍵寫法參考**：
- 明確標註 "Use the adult person from Image 1 as the character reference."
- "Preserve her face shape, facial proportions... exactly as in the reference."
- "Change only the wardrobe, pose, lighting, background, and camera framing."
- "Do not redesign the character."

---

## 範例 3：Backlit Elegant Back Editorial

使用者輸入：「逆光美背，窗邊，3:4，高級克制。」

**關鍵寫法參考**：
- tasteful open-back silk dress
- backlit elegant back silhouette
- refined shoulder and neck line, subtle shoulder blade contour
- gentle over-the-shoulder glance
- "The visual focus is on the refined back silhouette with graceful fabric drapery..."

---

## 範例 4：3D CG 模式

使用者輸入：「生成一個成年東方幻想系女性角色，3D CG，9:16。」

**關鍵寫法參考**：
- 明確切換語氣："high-end 3D CG character render"
- subsurface scattering
- "Do not photograph. No real-camera realism."
- 避免混入 photorealistic 詞彙

---

**使用提醒**：
這些範例展示了五段式 + 完整 Constraints 的正確寫法與安全語氣。
實際生成時，請根據 §18.1–18.6 的結構 + 當前 preset + 使用者鎖定參數重新撰寫，不要直接複製範例文字。