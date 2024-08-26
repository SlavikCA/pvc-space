#!/usr/bin/env bash
# based on https://gist.github.com/redmcg/60cfff7bca6f32969188008ad4a44c9a

function getNodes() {
  kubectl get --raw /api/v1/nodes | jq -r '.items[].metadata.name'
}

function getPVCs() {
  jq -s '[flatten | .[].pods[].volume[]? | select(has("pvcRef")) | '\
'{namespace: .pvcRef.namespace, name: .pvcRef.name, capacityBytes, usedBytes, availableBytes, '\
'percentageUsed: (.usedBytes / .capacityBytes * 100)}] | sort_by(.namespace)'
}

function column() {
  awk '{ for (i = 1; i <= NF; i++) { d[NR, i] = $i; w[i] = length($i) > w[i] ? length($i) : w[i] } } '\
'END { for (i = 1; i <= NR; i++) { printf("%-*s", w[1], d[i, 1]); for (j = 2; j <= NF; j++ ) { printf("%*s", w[j] + 1, d[i, j]) } print "" } }'
}

function defaultFormat() {
  awk 'BEGIN { print "Namespace PVC 1M-blocks Used Available Use%" } '\
'{$3 = sprintf("%.1f", $3/1048576); $4 = sprintf("%.1f", $4/1048576); $5 = sprintf("%.1f", $5/1048576); $6 = sprintf("%.0f%%", $6); print $0}'
}

function humanFormat() {
  awk 'BEGIN { print "Namespace PVC Size Used Avail Use%" } '\
'{$6 = sprintf("%.0f%%",$6); printf("%s ", $1); printf("%s ", $2); system(sprintf("numfmt --to=iec %s %s %s | sed '\''N;N;s/\\n/ /g'\'' | tr -d \\\\n", $3, $4, $5)); print " " $6 }'
}

function format() {
  jq '.[] | "\(.namespace) \(.name) \(.capacityBytes) \(.usedBytes) \(.availableBytes) \(.percentageUsed)"' |
  sed 's/^"|"$//g' |
  $format | column
}

if [ "$1" == "-h" ]; then
  format=humanFormat
else
  format=defaultFormat
fi

for node in $(getNodes); do
  kubectl get --raw /api/v1/nodes/$node/proxy/stats/summary
done | getPVCs | format
