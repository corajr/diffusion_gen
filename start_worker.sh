#!/bin/bash

if [[ "$CONDA_DEFAULT_ENV" != "diffusion_gen" ]]; then
	source ${CONDA_DIR:-~/miniconda3}/etc/profile.d/conda.sh
	conda activate diffusion_gen
fi

celery -A app.celery worker -c 1 -E
