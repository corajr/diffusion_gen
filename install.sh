#!/bin/bash

if [[ "$CONDA_DEFAULT_ENV" != "diffusion_gen" ]]; then
	source ${CONDA_DIR:-~/miniconda3}/etc/profile.d/conda.sh
	conda activate diffusion_gen
fi

python3 -m pip install torch lpips datetime timm ipywidgets omegaconf>=2.0.0 pytorch-lightning>=1.0.8 torch-fidelity einops wandb Redis opencv-python-headless
git clone https://github.com/CompVis/latent-diffusion.git
git clone https://github.com/openai/CLIP
pip3 install -e ./CLIP
git clone https://github.com/assafshocher/ResizeRight.git
git clone https://github.com/crowsonkb/guided-diffusion
python3 -m pip install -e ./guided-diffusion
# SuperRes
# git clone https://github.com/CompVis/latent-diffusion.git
# git clone https://github.com/CompVis/taming-transformers
# pip install -e ./taming-transformers
ipython3 diffuse.py -- --setup=True --gpu=""