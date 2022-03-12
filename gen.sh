#!/bin/bash

if [[ "$CONDA_DEFAULT_ENV" -ne "diffusion_gen" ]]; then
	source ${CONDA_DIR:-~/miniconda3}/etc/profile.d/conda.sh
	conda activate diffusion_gen
fi

python diffuse.py "$@"
