#!/bin/bash

echo ""
echo "Starting script execution..."

# ----- Set REGION and PROJECT ID -----
REGION="europe-west1"
ID="qwiklabs-gcp-01-4f17e523de19"

# ----- Task 1: Create GenerateImage.py -----
cat > GenerateImage.py <<EOF_END
import vertexai
from vertexai.preview.vision_models import ImageGenerationModel

def generate_image(project_id: str, location: str, output_file: str, prompt: str):
    try:
        vertexai.init(project=project_id, location=location)
        model = ImageGenerationModel.from_pretrained("imagen-3.0-generate-002")
        images = model.generate_images(
            prompt=prompt,
            number_of_images=1,
            seed=1,
            add_watermark=False,
        )
        images[0].save(location=output_file)
        print(f"Image saved to {output_file}")
    except Exception as e:
        print(f"Error generating image: {e}")

generate_image(
    project_id="$ID",
    location="$REGION",
    output_file="image.jpeg",
    prompt="Create an image containing a bouquet of 2 sunflowers and 3 roses",
)
EOF_END

echo "Running GenerateImage.py..."
/usr/bin/python3 /home/student/GenerateImage.py
echo "GenerateImage.py execution completed."

# ----- Task 2: Create AnalyzeImage.py -----
cat > AnalyzeImage.py <<EOF_END
import vertexai
from vertexai.generative_models import GenerativeModel, Part

def analyze_image(project_id: str, location: str, image_path: str):
    try:
        vertexai.init(project=project_id, location=location)
        model = GenerativeModel("gemini-2.0-flash-001")
        parts = [
            Part.from_file(image_path, mime_type="image/jpeg"),
            "Generate birthday wishes based on the image."
        ]
        response = model.generate_content(parts, stream=True)
        print("Generated birthday wishes:")
        for chunk in response:
            print(chunk.text, end="", flush=True)
        print()
    except Exception as e:
        print(f"Error analyzing image: {e}")

analyze_image(
    project_id="$ID",
    location="$REGION",
    image_path="image.jpeg"
)
EOF_END

echo "Running AnalyzeImage.py..."
/usr/bin/python3 /home/student/AnalyzeImage.py
echo "AnalyzeImage.py execution completed."

echo "Script finished."
