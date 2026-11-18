# Hello World Lambda (local AWS, no Node install needed)

A minimal JavaScript AWS Lambda, deployed with **Serverless Framework v3** to
**[MiniStack](https://github.com/ministackorg/ministack)**, a free local AWS
emulator running in Docker. Nothing gets deployed to a real AWS account, and you
don't need Node.js installed: everything runs in containers.

## Prerequisites

- **Docker** with Compose v2 (`docker compose version` should work)
  - macOS / Windows: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Linux: Docker Engine + the `docker-compose-plugin` package

That's all. No Node.js, npm, AWS CLI or AWS account required.

## Quick start

1. Start **MiniStack** (the local AWS emulator) on `http://localhost:4566`:

   ```sh
   docker compose up -d
   ```

2. Install the npm packages, then deploy and invoke the Lambda. These commands use
   the wrappers in `bin/` (see the next section). On Windows, write `bin\npm`
   instead of `./bin/npm`.

   ```sh
   ./bin/npm install
   ./bin/npm run deploy    # creates a CloudFormation stack containing your Lambda
   ./bin/npm run invoke    # calls the Lambda once and prints what it returns
   ```

The last command prints the function's return value:

```
"Test"
```

MiniStack keeps running in the background until you run `docker compose down`.

> The first run downloads the Docker images and npm packages, so it takes a
> minute. Later runs are much faster.

## Using `node`, `npm`, `npx` and `sls` without installing Node

The `bin/` folder contains small wrapper scripts. Each one forwards the command to
a Node.js container (the `node` service in `docker-compose.yml`). Activate them once
per terminal, **from the project root**:

| Shell | Activate | Undo |
|---|---|---|
| macOS / Linux (bash, zsh) | `source bin/activate` | `deactivate_node` |
| Windows PowerShell | `.\bin\activate.ps1` | close the window |
| Windows cmd.exe | `bin\activate.cmd` | close the window |

If PowerShell says *"running scripts is disabled on this system"*, paste this line
instead:

```powershell
$env:PATH = "$PWD\bin;$env:PATH"
```

After that, use the commands as if Node were installed:

```sh
node --version          # v22.x, from the container
npm install
npm run deploy          # serverless deploy --stage local
npm run invoke          # serverless invoke --function helloworld --stage local
npm run info            # show what's deployed
sls --help              # the Serverless CLI
```

Notes:

- Commands always run in the **project root** (it's mounted at `/app` in the container).
- `deploy`, `invoke`, `info` and `remove` talk to MiniStack, so MiniStack must
  be running (`docker compose up -d`).
- You can also call a wrapper without activating, e.g. `./bin/npm run invoke`
  (macOS/Linux) or `bin\npm run invoke` (Windows).

## Edit → redeploy loop

1. Change the return value in `functions/helloworld.js`
2. Redeploy and invoke:
   - with the wrappers activated: `npm run deploy && npm run invoke`
   - or without them: `./bin/npm run deploy && ./bin/npm run invoke`

## Project layout

```
├── functions/
│   └── helloworld.js     # the Lambda function
├── serverless.yml        # Serverless Framework v3 config (function, plugin, packaging)
├── package.json          # serverless@3.40.0 + serverless-localstack plugin, npm scripts
├── docker-compose.yml    # ministack (emulator), node (used by bin/)
└── bin/                  # node/npm/npx/sls wrappers (sh for macOS/Linux, .cmd for Windows)
```

## How it works

- **MiniStack** emulates AWS on port 4566. It's limited (`SERVICES=`) to what this
  project needs: Lambda and CloudFormation, plus the S3, IAM, CloudWatch Logs and
  STS services that a Serverless deploy uses behind the scenes.
- **serverless-localstack** is a Serverless plugin that sends the `local` stage's
  AWS calls to the emulator instead of real AWS. It works with MiniStack because
  MiniStack implements the LocalStack-compatible API.
- The Node containers reach the emulator at `http://ministack:4566` (its service
  name on the Compose network). From your own machine it's `http://localhost:4566`.
- MiniStack keeps everything in memory. After `docker compose down` the stack is
  gone: start MiniStack again and run `npm run deploy` to recreate it.

## Cleaning up

```sh
docker compose down
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `Cannot connect to the Docker daemon` | Start Docker Desktop (or `sudo systemctl start docker` on Linux) |
| `port is already allocated` (4566) | Something else (e.g. LocalStack) is using port 4566. Stop it, or change the left side of `"4566:4566"` in `docker-compose.yml` |
| ``Inaccessible host: `ministack'`` from `npm run deploy` / `invoke` | MiniStack isn't running. Run `docker compose up -d` |
| Linux: `EACCES: permission denied` when writing files | The containers run as user `node` (uid 1000). If your Linux user's uid differs (`id -u`), change `user: node` in `docker-compose.yml` to `user: "<your uid>:<your gid>"` |
| Windows: `'docker' is not recognized` | Docker Desktop isn't installed, or wasn't added to PATH. Reinstall it and open a new terminal |
| Serverless prints deprecation warnings | Expected: Serverless v3 is no longer updated. They're harmless |

> **Note for maintainers:** the Windows wrappers (`bin/*.cmd`, `bin/activate.ps1`,
> `bin/activate.cmd`) haven't been tested on a real Windows machine yet.
