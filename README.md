# Sylphide
## Overview
This project is intended to be the base of the Rust project.

## Getting started
### Linux
1. Generate `.env` file

```bash
./setDotEnv.sh
```

2. Open [VSCode Remote Container](https://code.visualstudio.com/docs/remote/containers)


## Rust Environment
- Rust : 1.54.0
- toolchain
  - rustfmt
  - clippy
  - rust-analyzer
  - cross

## Development Environment
- [x] Docker
- [x] VSCode Dev container
- GitHub Action
  - [ ] Build
  - [ ] Test
- GitLab CI
  - [X] Build
  - [ ] Test
- Git Hooks
  - [x] pre-commit
    - [x] clippy
    - [x] code format
    - [ ] commit message lint
