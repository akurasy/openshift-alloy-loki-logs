# openshift-alloy-loki-logs

To run this script, Change ocp-cluster-01 in the 04-alloy-configmap.yaml file to your real cluster name:
To get the cluster name, run the command :

```
oc get infrastructure cluster -o jsonpath='{.status.infrastructureName}{"\n"}'
```

change the permission for the install.sh and run the script with the command below:
```
chmod +x install.sh
./install.sh
```
To add to grafana dashboard, use this url as the datasource for loki :
```
http://loki.observability.svc.cluster.local:3100
```
use this dashboard ID in grafana dashboard for predefined logs that shows the namespace and the objects. 
```
15324
```

# Happy Logging
