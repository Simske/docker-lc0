#!/usr/bin/env python3

import argparse
import logging
import os
import subprocess

import yaml
from jinja2 import Template

try:
    os.environ['DEBUG']

    logging.basicConfig(level=logging.DEBUG)
    class subprocess:
        def run(*args, **kwargs):
            print(args, kwargs)
except KeyError:
    logging.basicConfig(level=logging.INFO, format='%(message)s')


class Config:
    def __init__(self, filename):
        with open(filename) as f:
            self.config = yaml.safe_load(f)

    def get_profile(self, profilename):
        if 'base' in self.config[profilename]:
            conf = self.get_profile(self.config[profilename]['base']).copy()
            conf.update(self.config[profilename])
            return conf
        else:
            return self.config[profilename]

    def __iter__(self):
        return iter(self.config)


class DockerfileGenerator:
    def __init__(self, templatefile):
        with open(templatefile) as f:
            self.template = Template(f.read(), trim_blocks=True)
        os.makedirs('dockerfiles', exist_ok=True)

    def render(self, profilename, profile):
        filename = f"dockerfiles/Dockerfile.{profilename}"
        with open(filename, 'w') as f:
            f.write(self.template.render(**profile))
        logging.info(f"Created '{filename}'")


def build_image(profilename, profile):
    imagename = profile['imagename']
    tag = f"{profile['lc0_version']}{profile['tag_suffix']}"
    subprocess.run(['docker', 'build', '--pull', '-t', f"{imagename}:{tag}",
                    '-f', f'dockerfiles/Dockerfile.{profilename}', '.'], check=True)
    logging.info(f"Build docker image '{imagename}:{tag}'")
    return tag


def tag_image(profilename, profile, version_tag):
    imagename = profile['imagename']
    default_tag = f"{profile['lc0_version']}{profile['tag_suffix']}"
    new_tag = f"{version_tag}{profile['tag_suffix']}"
    subprocess.run(
        ['docker', 'tag', f"{imagename}:{default_tag}", f"{imagename}:{new_tag}"], check=True)
    logging.info(f"Added tag '{new_tag}' to image with tag '{default_tag}'")
    return new_tag


def push_image(profile, version_tag=None):
    imagename = profile['imagename']
    if version_tag is None:
        version_tag = profile['lc0_version']
    tag = f"{version_tag}{profile['tag_suffix']}"
    subprocess.run(['docker', 'push', f"{imagename}:{tag}"])
    logging.info(f"Pushed image '{imagename}:{tag}' to DockerHub")


def make_profile(profilename, args):
    dockerfile = DockerfileGenerator('Dockerfile.template')
    config = Config("config.yml")
    profile = config.get_profile(profilename)

    dockerfile.render(profilename, profile)

    if args.build:
        build_image(profilename, profile)
        tag_image(profilename, profile, profile['version_tag'])
    if args.tag_latest:
        tag_image(profilename, profile, "latest")
    if args.tag:
        tag_image(profilename, profile, args.tag)

    if args.push:
        push_image(profile)
        push_image(profile, profile['version_tag'])
        if args.tag_latest:
            push_image(profile, 'latest')
        if args.tag:
            push_image(profile, args.tag)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("profile", default="", nargs="?")
    parser.add_argument("--build", action="store_true", help="Build docker images")
    parser.add_argument("--tag-latest", action="store_true",
            help="Tag build images with 'latest'")
    parser.add_argument("--push", action="store_true", help="Push images to Dockerhub")
    parser.add_argument("--tag", default="", help="use additional custom version tag")
    args = parser.parse_args()

    if args.profile:
        make_profile(args.profile, args)
    else:
        for profilename in config:
            make_profile(profilename, args)
