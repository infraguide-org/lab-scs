# Source: https://github.com/infraguide-org/lab-scs
# Copyright (c) 2026 infraguide.org, MIT License
.PHONY: init update status
init:    ; git submodule update --init --recursive
update:  ; git submodule update --remote --merge
status:  ; git submodule status; git status --short
