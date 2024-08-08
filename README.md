# void-sh

## Init
This script will install `pd` and `cometbft`, run `pd network join`, configure services, download a polkachu snapshot, and sync from there.

If a DNS record points to the host, it will also automatically enable the HTTPS secured GRPC instance and minifront frontend.

Single line usage example:

`curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/22a435/void-sh/main/init.sh | bash`
