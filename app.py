import collections
from celery.result import AsyncResult
from flask import Flask, redirect, render_template, request
from flask.json import jsonify
from tasks import make_celery
import glob
import itertools
import json
import os
import re
import sys
import subprocess
import time

app = Flask(__name__)
app.config.from_object('config')
celery = make_celery(app)

@celery.task(bind=True)
def generate(self, text="", sharpen_preset="Off", width=832, height=512, steps=250, out_name=None, init_image=""):
    kwargs = {
        'text': text,
        'root_path': 'out_diffusion',
        'setup': False,
        'out_name': out_name or str(int(time.time())),
        'sharpen_preset': sharpen_preset,
        'width': int(width),
        'height': int(height),
        'init_image': init_image,
        'steps': int(steps),
        'skip_steps': 0,
        'inter_saves': 3
    }
    sys.path.append(".")
    from diffuse import main
    from argparse import Namespace
    main(argparse_args=Namespace(**kwargs), task=self)

@app.route("/tasks", methods=["POST"])
def run_task():
    task = generate.delay(**request.form)
    return redirect(f'/?task_id={task.id}')


@app.route("/tasks/<task_id>")
def get_status(task_id):
    task_result = AsyncResult(task_id)
    result = {
        "task_id": task_id,
        "task_status": task_result.status,
        "task_result": task_result.result,
    }
    return jsonify(result)


def read_settings(fname):
    with open(fname) as f:
        settings = json.load(f)
        return settings.get("text_prompts", {}).get('0', [])

def get_gpus():
    p = subprocess.run("nvidia-smi --query-gpu=name,uuid --format=csv,noheader", capture_output=True, shell=True)
    rows = filter(None, p.stdout.decode("utf-8").split("\n"))
    rows = [row.split(", ") for row in rows]
    return [
        {"name": row[0], "uuid": row[1]}
        for row in rows
    ]


@app.route("/")
def get_generated():
    desired_prompt = request.args.get("prompt", "")
    data_root = os.environ.get("DATA_ROOT", ".")
    srcs = [
        src[len(data_root):]
        for src in glob.glob(os.path.join(data_root, "out_diffusion/images_out/*/*.png"))
    ]
    srcs.reverse()
    thumbs = [src.replace(".png", ".png!md") for src in srcs]
    ids = [re.search(r"out_diffusion/images_out/([^/]+)/.+\.png$", src).group(1) for src in srcs]

    prompts = [
        str(read_settings(fname))
        for fname in glob.glob(os.path.join(os.environ.get("DATA_ROOT", "./"), "out_diffusion/images_out/*/*_settings.txt"), recursive=True)
    ]
    prompts.reverse()
    prompt_attempts = collections.defaultdict(list)
    for prompt, img_id, thumb in zip(prompts, ids, thumbs):
        prompt_attempts[prompt].append(f"<a href=\"#{img_id}\"><img src=\"{thumb}\" /></a>")
    form = render_template("form.html")
    poll = render_template("poll.html")

    index = "<ul>" + "\n".join([f"<li>{prompt}<br/>{''.join(links)}</li>" for prompt, links in prompt_attempts.items()]) + "</ul>"
    images = [
        f"<figure id=\"{img_id}\"><img src=\"{src}\" alt=\"{prompt}\"/><figcaption>{prompt}</figcaption></figure>"
        for img_id, src, prompt in zip(ids, srcs, prompts)
    ]
    return poll + form + index + (f"{desired_prompt}" if desired_prompt else "") + "\n".join(images)


@app.route('/info')
def info():
    resp = {
	    'connecting_ip': request.headers['X-Real-IP'],
	    'proxy_ip': request.headers['X-Forwarded-For'],
	    'host': request.headers['Host'],
	    'user-agent': request.headers['User-Agent']
	    }

    return jsonify(resp)


@app.route('/flask-health-check')
def flask_health_check():
    return "success"
