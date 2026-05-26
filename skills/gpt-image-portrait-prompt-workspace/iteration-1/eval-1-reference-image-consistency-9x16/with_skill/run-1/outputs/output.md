PROMPT:
Scene: A rain-soaked urban street at night, cinematic neon reflections shimmering on wet pavement, blurred warm street lights and shop signs in the background, shallow depth of field creating soft bokeh, overcast sky with a deep blue-gray cast.
Subject: Use the adult person from Image 1 as the character reference. Preserve her face shape, facial proportions, eye spacing, nose bridge length, mouth width, jawline, head size, hairstyle, hair color, and identity exactly as in the reference. She is a clearly adult East Asian woman, around 28 years old, with a mature adult facial structure. She stands naturally on a wet city sidewalk with a slight three-quarter turn toward the camera, relaxed and quietly confident posture, calm gaze directed slightly past the lens.
Details: She wears a dark tailored wool coat over a refined fitted knit dress, natural fabric texture with soft drape, tasteful silhouette with a clear but subtle waistline and balanced proportions. Framed from upper body to mid-thigh at eye level, 85mm portrait lens, f/2.0 shallow depth of field, slight three-quarter editorial angle.
Lighting: Soft rim light on her shoulder and hair from a warm neon sign behind and to the side, cool ambient fill reflected from wet pavement, subtle cinematic color grading with deep shadows and warm highlight accents, real skin texture preserved, subtle film grain.
Use case: Urban night fashion editorial portrait for a lifestyle magazine, 9:16 portrait format, reference-image character consistency mode.
Constraints: Use the adult person from Image 1 as the character reference. Change only the wardrobe, pose, lighting, background, and camera framing. Do not redesign the character. Do not stylize her face. Do not cartoonize. No anime. No CGI look. No illustration. No nudity. No lingerie styling. No childlike features. No teen styling. No school uniform. No exaggerated anatomy. No voyeuristic angle. No body-part close-up. No wet body sexualization. No nightclub erotic atmosphere. No overly revealing outfit. No low-angle body-focused shot. No plastic skin. No over-smoothing. No AI artifacts. No waxy look. No deformed hands. No extra fingers. No missing fingers. No broken anatomy. No facial distortion. No asymmetric eyes. No fabric warping. No jewelry distortion. No watermark. No logo. No extra text. No frame border.

PARAMETERS:
model: gpt-image-2
size: 1152x2048
quality: high
output_format: png
moderation: auto

API payload（Images API edits 端點）：

```json
{
  "model": "gpt-image-2",
  "image": ["@reference.png"],
  "prompt": "Scene: A rain-soaked urban street at night, cinematic neon reflections shimmering on wet pavement, blurred warm street lights and shop signs in the background, shallow depth of field creating soft bokeh, overcast sky with a deep blue-gray cast.\nSubject: Use the adult person from Image 1 as the character reference. Preserve her face shape, facial proportions, eye spacing, nose bridge length, mouth width, jawline, head size, hairstyle, hair color, and identity exactly as in the reference. She is a clearly adult East Asian woman, around 28 years old, with a mature adult facial structure. She stands naturally on a wet city sidewalk with a slight three-quarter turn toward the camera, relaxed and quietly confident posture, calm gaze directed slightly past the lens.\nDetails: She wears a dark tailored wool coat over a refined fitted knit dress, natural fabric texture with soft drape, tasteful silhouette with a clear but subtle waistline and balanced proportions. Framed from upper body to mid-thigh at eye level, 85mm portrait lens, f/2.0 shallow depth of field, slight three-quarter editorial angle.\nLighting: Soft rim light on her shoulder and hair from a warm neon sign behind and to the side, cool ambient fill reflected from wet pavement, subtle cinematic color grading with deep shadows and warm highlight accents, real skin texture preserved, subtle film grain.\nUse case: Urban night fashion editorial portrait for a lifestyle magazine, 9:16 portrait format, reference-image character consistency mode.\nConstraints: Use the adult person from Image 1 as the character reference. Change only the wardrobe, pose, lighting, background, and camera framing. Do not redesign the character. Do not stylize her face. Do not cartoonize. No anime. No CGI look. No illustration. No nudity. No lingerie styling. No childlike features. No teen styling. No school uniform. No exaggerated anatomy. No voyeuristic angle. No body-part close-up. No wet body sexualization. No nightclub erotic atmosphere. No overly revealing outfit. No low-angle body-focused shot. No plastic skin. No over-smoothing. No AI artifacts. No waxy look. No deformed hands. No extra fingers. No missing fingers. No broken anatomy. No facial distortion. No asymmetric eyes. No fabric warping. No jewelry distortion. No watermark. No logo. No extra text. No frame border.",
  "size": "1152x2048",
  "quality": "high",
  "output_format": "png"
}
```
