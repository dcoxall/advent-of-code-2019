DAY="$2"
PART="part${3}"

case "$1" in
  nim)    nim compile --run --outdir="bin/${DAY}" "${DAY}/nim/${PART}.nim";;
  ruby)   ruby "${DAY}/ruby/${PART}.rb";;
  go)     go run "${DAY}/go/${PART}.go";;
  erlang) escript "${DAY}/erlang/${PART}.erl";;

  # Options just to compile for testing
  nimrelease)
    nim compile -f -d:release --checks:off --assertions:off --opt:speed \
      -o:"bin/release/nim-${DAY}-${PART}" "${DAY}/nim/${PART}.nim";;

  gorelease)
    go build -o "bin/release/go-${DAY}-${PART}" "${DAY}/go/${PART}.go";;
esac
