#!/bin/bash

source ${CONDA_ROOT:-~/miniconda3}/etc/profile.d/conda.sh
conda activate diffusion_gen

python3 -m pip install torch lpips datetime timm ipywidgets omegaconf>=2.0.0 pytorch-lightning>=1.0.8 torch-fidelity einops wandb
git clone https://github.com/CompVis/latent-diffusion.git
git clone https://github.com/openai/CLIP
pip3 install -e ./CLIP
git clone https://github.com/assafshocher/ResizeRight.git
git clone https://github.com/crowsonkb/guided-diffusion
python3 -m pip install -e ./guided-diffusion
git clone https://github.com/CompVis/latent-diffusion.git
git clone https://github.com/CompVis/taming-transformers
pip install -e ./taming-transformers
