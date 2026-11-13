#!/usr/bin/env bash
# based on https://gist.github.com/redmcg/60cfff7bca6f32969188008ad4a44c9a

function getNodes() {
  kubectl get --raw /api/v1/nodes | jq -r '.items[].metadata.name'
}


function getPVCs() {
  jq -s '[flatten | .[].pods[].volume[]? | select(has("pvcRef")) | '\
'{namespace: .pvcRef.namespace, name: .pvcRef.name, capacityBytes, usedBytes, availableBytes, '\
'percentageUsed: (.usedBytes / .capacityBytes * 100)}] | sort_by(.percentageUsed) | reverse'
}


function column() {
  awk '{ for (i = 1; i <= NF; i++) { d[NR, i] = $i; w[i] = length($i) > w[i] ? length($i) : w[i] } } '\
'END { for (i = 1; i <= NR; i++) { printf("%-*s", w[1], d[i, 1]); for (j = 2; j <= NF; j++ ) { printf("%*s", w[j] + 1, d[i, j]) } print "" } }'
}


function defaultFormat() {
  awk 'BEGIN { print "Namespace PVC Used(GB) Available(GB) Use%" }
  {
    printf "%s %s %.1f %.1f %.0f%%\n",
      $1, $2, $4/1000000000, $5/1000000000, $6
  }'
}

function format() {
  jq '.[] | "\(.namespace) \(.name) \(.capacityBytes) \(.usedBytes) \(.availableBytes) \(.percentageUsed)"' |
  sed 's/^"|"$//g' |
  defaultFormat | column
}

for node in $(getNodes); do
  kubectl get --raw /api/v1/nodes/$node/proxy/stats/summary
done | getPVCs | format
