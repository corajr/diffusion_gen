#!/bin/bash

source $CONDA_PREFIX/etc/profile.d/conda.sh
conda activate diffusion_gen
pip install Redis
ipython3 diffuse.py -- --setup=True
celery -A app.celery worker -c 1 -E
