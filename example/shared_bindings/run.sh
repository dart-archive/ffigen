set -e

dart run ffigen --config=ffigen_configs/base.yaml

dart run ffigen --config=ffigen_configs/a.yaml

dart run ffigen --config=ffigen_configs/a_shared_base.yaml
