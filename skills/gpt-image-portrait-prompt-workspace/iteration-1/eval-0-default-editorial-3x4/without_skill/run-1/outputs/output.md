# GPT-Image-2 Portrait Prompt

## Prompt

A photorealistic portrait of a young East Asian woman in her late twenties, standing near a large window with soft natural daylight streaming in. She has smooth skin, dark straight hair falling past her shoulders, and subtle natural makeup. She wears a relaxed cream-colored linen blouse. Her expression is calm and contemplative, eyes glancing slightly away from the camera. The background is a softly blurred minimalist interior — warm neutral tones, a hint of green foliage. Shot in the style of a high-end editorial fashion photograph: shallow depth of field, film-like color grading with gentle warm tones, sharp facial detail, cinematic mood. Vertical composition, 3:4 aspect ratio.

## 參數

| 參數 | 值 |
|------|-----|
| model | gpt-image-2 |
| size | 1024x1536 |
| quality | high |
| output_format | png |

## API 呼叫範例（Python）

```python
import openai

client = openai.OpenAI()

response = client.images.generate(
    model="gpt-image-2",
    prompt="A photorealistic portrait of a young East Asian woman in her late twenties, standing near a large window with soft natural daylight streaming in. She has smooth skin, dark straight hair falling past her shoulders, and subtle natural makeup. She wears a relaxed cream-colored linen blouse. Her expression is calm and contemplative, eyes glancing slightly away from the camera. The background is a softly blurred minimalist interior — warm neutral tones, a hint of green foliage. Shot in the style of a high-end editorial fashion photograph: shallow depth of field, film-like color grading with gentle warm tones, sharp facial detail, cinematic mood. Vertical composition, 3:4 aspect ratio.",
    size="1024x1536",
    quality="high",
    output_format="png",
)

print(response.data[0].url)
```
