# lab-scs

Deploy and operate a Sovereign Cloud Stack (SCS) cloud with OSISM.

## Quick start
```bash
git clone --recurse-submodules https://github.com/infraguide-org/lab-scs.git
cd lab-scs
make init
```

## Repository layout
| Path | Content |
|---|---|
| `conf/` | `env.yaml` - network and host layout of the environment, `net-diagram.yaml` - what the network diagrams show, `tmuxp.yaml` - tmux session with a window per host group, `user-data.yaml` - cloud-init of the sandbox. Still the example from `lab-template` |
| `deploy/openstack/` | submodule [lab-scs-config](https://github.com/infraguide-org/lab-scs-config), the OSISM configuration repository |
| `modules/` | additional modules, none yet |
| `scripts/` | `create-env.sh` - creates the lab environment on the sandbox |
| `slides/` | slide sources (`src`) and the scripts that build the decks and the index page with `index.json` (`scripts`) |
| `status/` | `build.yml` - result of the automatic lab build, shown on the lab page |

Repository conventions: [lab-template](https://github.com/infraguide-org/lab-template).
