# GPT-Image-2 Image Edit API — Urban Night Street Portrait (9:16)

## English Prompt

```
A 28-year-old Asian woman with the exact same face, facial features, skin tone, and expression as in the reference image. She is standing on a city street at night, shot in candid street photography style. The background shows a busy urban night scene with bokeh neon signs, glowing storefronts, light trails from passing cars, and wet pavement reflecting colorful lights. The woman is the clear subject in the foreground. Cinematic, natural ambient lighting from streetlights and neon falls softly on her face. The composition is vertical 9:16 portrait orientation. Photorealistic style, 35mm lens look, shallow depth of field. Do not alter her face, facial structure, or identity in any way.
```

## API Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| `model` | `gpt-image-2` | Required |
| `image` | `<reference_image_file>` | The input portrait photo |
| `prompt` | See above | English, descriptive |
| `size` | `1024x1792` | Closest 9:16 ratio supported |
| `n` | `1` | Number of images |
| `quality` | `high` | For best face fidelity |

## JSON Payload (multipart/form-data fields)

```json
{
  "model": "gpt-image-2",
  "prompt": "A 28-year-old Asian woman with the exact same face, facial features, skin tone, and expression as in the reference image. She is standing on a city street at night, shot in candid street photography style. The background shows a busy urban night scene with bokeh neon signs, glowing storefronts, light trails from passing cars, and wet pavement reflecting colorful lights. The woman is the clear subject in the foreground. Cinematic, natural ambient lighting from streetlights and neon falls softly on her face. The composition is vertical 9:16 portrait orientation. Photorealistic style, 35mm lens look, shallow depth of field. Do not alter her face, facial structure, or identity in any way.",
  "size": "1024x1792",
  "n": 1,
  "quality": "high"
}
```

## cURL Example

```bash
curl https://api.openai.com/v1/images/edits \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F model="gpt-image-2" \
  -F image="@reference_portrait.jpg" \
  -F prompt="A 28-year-old Asian woman with the exact same face, facial features, skin tone, and expression as in the reference image. She is standing on a city street at night, shot in candid street photography style. The background shows a busy urban night scene with bokeh neon signs, glowing storefronts, light trails from passing cars, and wet pavement reflecting colorful lights. The woman is the clear subject in the foreground. Cinematic, natural ambient lighting from streetlights and neon falls softly on her face. The composition is vertical 9:16 portrait orientation. Photorealistic style, 35mm lens look, shallow depth of field. Do not alter her face, facial structure, or identity in any way." \
  -F size="1024x1792" \
  -F n=1 \
  -F quality="high"
```

## Python (openai SDK) Example

```python
import openai

client = openai.OpenAI()

with open("reference_portrait.jpg", "rb") as image_file:
    response = client.images.edit(
        model="gpt-image-2",
        image=image_file,
        prompt=(
            "A 28-year-old Asian woman with the exact same face, facial features, "
            "skin tone, and expression as in the reference image. She is standing on "
            "a city street at night, shot in candid street photography style. The "
            "background shows a busy urban night scene with bokeh neon signs, glowing "
            "storefronts, light trails from passing cars, and wet pavement reflecting "
            "colorful lights. The woman is the clear subject in the foreground. "
            "Cinematic, natural ambient lighting from streetlights and neon falls softly "
            "on her face. The composition is vertical 9:16 portrait orientation. "
            "Photorealistic style, 35mm lens look, shallow depth of field. Do not alter "
            "her face, facial structure, or identity in any way."
        ),
        size="1024x1792",
        n=1,
        quality="high",
    )

print(response.data[0].url)
```

## Notes

- **Face consistency**: gpt-image-2 image edit uses the reference image directly, which gives the best chance of preserving facial identity. The prompt explicitly reinforces "do not alter her face."
- **Size**: `1024x1792` is the supported size closest to 9:16 ratio.
- **Mask**: No mask is provided here, letting the model blend the subject into the new background. If you want to strictly preserve only the face region, provide a mask image isolating everything except the face.
- **Input image format**: JPEG or PNG, max 4MB recommended for best results.
