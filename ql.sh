#!/bin/bash

echo ""
echo ""
echo "Starting script execution..."

# ----- Set REGION and PROJECT ID -----
REGION="europe-west1"
ID="qwiklabs-gcp-01-03446d1c9018"

# ----- Create GenerateImage.py -----
cat > GenerateImage.py <<EOF_END
import argparse

import vertexai
from vertexai.preview.vision_models import ImageGenerationModel

def generate_image(
    project_id: str, location: str, output_file: str, prompt: str
) -> vertexai.preview.vision_models.ImageGenerationResponse:
    """Generate an image using a text prompt."""
    vertexai.init(project=project_id, location=location)
    model = ImageGenerationModel.from_pretrained("imagegeneration@002")
    images = model.generate_images(
        prompt=prompt,
        number_of_images=1,
        seed=1,
        add_watermark=False,
    )
    images[0].save(location=output_file)
    return images

generate_image(
    project_id='$ID',
    location='$REGION',
    output_file='image.jpeg',
    prompt='Create an image of a cricket ground in the heart of Los Angeles',
)
EOF_END

# ----- Run GenerateImage.py -----
/usr/bin/python3 /home/student/GenerateImage.py

# ----- Create genai.py -----
cat > genai.py <<EOF_END
import vertexai
from vertexai.generative_models import GenerativeModel, Part

def generate_text(project_id: str, location: str) -> str:
    vertexai.init(project=project_id, location=location)
    multimodal_model = GenerativeModel("gemini-1.0-pro-vision")
    response = multimodal_model.generate_content(
        [
            Part.from_uri(
                "gs://generativeai-downloads/images/scones.jpg", mime_type="image/jpeg"
            ),
            "what is shown in this image?",
        ]
    )
    return response.text

project_id = "$ID"
location = "$REGION"
response = generate_text(project_id, location)
print(response)
EOF_END

# ----- Run genai.py -----
/usr/bin/python3 /home/student/genai.py

# ----- Optional: Wait and run again -----
sleep 30
/usr/bin/python3 /home/student/genai.py
