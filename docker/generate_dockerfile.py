#!/usr/bin/env python3

import yaml
from jinja2 import Template

with open("config.yml") as f:
    config = yaml.safe_load(f)

with open("Dockerfile.template") as f:
    dockerfile = Template(f.read(), trim_blocks=True)

def get_config(profilename):
    if 'base' in config[profilename]:
        conf = get_config(config[profilename]['base']).copy()
        conf.update(config[profilename])
        return conf
    else:
        return config[profilename]



for profilename, profile in config.items():
    conf = get_config(profilename)

    with open(f"dockerfiles/Dockerfile.{profilename}", 'w') as f:
        f.write(dockerfile.render(**conf))
