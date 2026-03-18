#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="observability"

echo "Creating namespace..."
oc apply -f 01-namespace.yaml

echo "Adding Grafana Helm repo..."
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update

echo "Installing or upgrading Loki..."
helm upgrade --install loki grafana/loki \
  -n "${NAMESPACE}" \
  --create-namespace \
  -f loki-values-filesystem.yaml

echo "Applying Alloy RBAC and SCC..."
oc apply -f 02-alloy-rbac.yaml
oc apply -f 03-alloy-scc.yaml
oc adm policy add-scc-to-user alloy-nonroot -z alloy -n "${NAMESPACE}"

echo "Applying Alloy config..."
oc apply -f 04-alloy-configmap.yaml

echo "Applying Alloy DaemonSet..."
oc apply -f 05-alloy-daemonset.yaml

echo "Restarting Alloy pods to pick up latest config..."
oc delete pod -n "${NAMESPACE}" -l app=alloy --ignore-not-found

echo "Cleaning up old unused MinIO PVCs if they exist..."
oc delete pvc export-0-loki-minio-0 export-1-loki-minio-0 -n "${NAMESPACE}" --ignore-not-found

echo
echo "Deployment complete."
echo
echo "Check resources:"
echo "  oc get pods -n ${NAMESPACE}"
echo "  oc get ds -n ${NAMESPACE}"
echo "  oc get statefulset -n ${NAMESPACE}"
echo "  oc get svc -n ${NAMESPACE}"
echo
echo "Test Loki readiness:"
echo "  oc run curltest --rm -it --restart=Never -n ${NAMESPACE} --image=curlimages/curl -- curl -s http://loki.observability.svc.cluster.local:3100/ready"
echo
echo "Query logs:"
echo "  oc run curltest --rm -it --restart=Never -n ${NAMESPACE} --image=curlimages/curl -- curl -G \"http://loki.observability.svc.cluster.local:3100/loki/api/v1/query_range\" --data-urlencode 'query={namespace=\"energynp\"}'"
