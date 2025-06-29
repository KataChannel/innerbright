#!/bin/bash
export PATH="$HOME/.bun/bin:$PATH"
bun run build
bun run start:prod
