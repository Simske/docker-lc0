#!/usr/bin/env python3

import argparse
# import subprocess
import yaml
from jinja2 import Template
class subprocess:
    def run(*args, **kwargs):
        print(args, kwargs)

with open("config.yml") as f:
    config = yaml.safe_load(f)

def get_profile(profilename):
    if 'base' in config[profilename]:
        conf = get_profile(config[profilename]['base']).copy()
        conf.update(config[profilename])
        return conf
    else:
        return config[profilename]

def generate_dockerfiles():
    with open("Dockerfile.template") as f:
        dockerfile = Template(f.read(), trim_blocks=True)

    for profilename, profile in config.items():
        conf = get_profile(profilename)

        with open(f"dockerfiles/Dockerfile.{profilename}", 'w') as f:
            f.write(dockerfile.render(**conf))

def build_image(profilename):
    profile = get_profile(profilename)
    imagename = profile['imagename']
    tag = f"{profile['lc0_version']}{profile['tag_suffix']}"
    subprocess.run(['docker', 'build', '-t', f"{imagename}:{tag}", '-f', f'dockerfiles/Dockerfile.{profilename}', '.'], check=True)
    return tag

if __name__ == "__main__":
    # parser = argparse.ArgumentParser()
    # parser.add_argument("-v", "--version", type=str, help="lc0 version")
    # args = parser.parse_args()
    build_image('default')