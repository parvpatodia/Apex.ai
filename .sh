#!/bin/bash
cd "$(dirname "$0")"
export NVIDIA_NIM_API_KEY="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"
litellm --config config.yaml
