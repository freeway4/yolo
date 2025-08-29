#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Usage: docker run -it freeway4/yolo <IMAGE_URL_or_PATH>"
  exit 1
fi

INPUT=$1
IMG_PATH="/app/input.jpg"
OUT_DIR="/app/output"

mkdir -p "$OUT_DIR"

# URL인지 로컬 경로인지 확인
if echo "$INPUT" | grep -Eqi '^https?://'; then
  echo "[+] Downloading image from URL..."
  wget -q "$INPUT" -O "$IMG_PATH"
else
  echo "[+] Copying local image..."
  cp "$INPUT" "$IMG_PATH"
fi

# 원본 이미지도 output 폴더에 저장
cp "$IMG_PATH" "$OUT_DIR/original.jpg"

echo "[+] Running YOLOv3 detection..."
cd /darknet
./darknet detector test cfg/coco.data cfg/yolov3.cfg yolov3.weights "$IMG_PATH" \
    -thresh 0.25 -dont_show -ext_output -out "$OUT_DIR/result.json"

# darknet은 predictions.png 파일을 생성함
#cp predictions.png "$OUT_DIR/predictions.png"

echo "[+] Detection complete! Results saved in $OUT_DIR"
ls -lh "$OUT_DIR"