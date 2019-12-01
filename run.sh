DAY="$2"
PART="part${3}"

case "$1" in
  nim)    nim compile --run --outdir="bin/${DAY}" "${DAY}/nim/${PART}.nim";;
  ruby)   ruby "${DAY}/ruby/${PART}.rb";;
  go)     go run "${DAY}/go/${PART}.go";;
  erlang) escript "${DAY}/erlang/${PART}.erl";;
esac
