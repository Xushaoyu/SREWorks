apiVersion: core.oam.dev/v1alpha2
kind: ApplicationConfiguration
metadata:
  annotations:
    appId: dataops
    clusterId: master
    namespaceId: ${NAMESPACE_ID}
    stageId: prod
  name: dataops
spec:
  components:
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        clusterController:
          enabled: false
          image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/kubecost1/cluster-controller
          imagePullPolicy: Always
          tag: v0.0.2
        global:
          additionalLabels: {}
          assetReports:
            enabled: false
            reports:
            - accumulate: false
              aggregateBy: type
              filters:
              - property: cluster
                value: cluster-one
              title: Example Asset Report 0
              window: today
          grafana:
            domainName: prod-dataops-grafana.sreworks-dataops
            enabled: false
            proxy: false
          notifications:
            alertmanager:
              enabled: false
          podAnnotations: {}
          prometheus:
            enabled: true
          savedReports:
            enabled: false
            reports:
            - accumulate: false
              aggregateBy: namespace
              filters:
              - property: cluster
                value: cluster-one,cluster*
              - property: namespace
                value: kubecost
              idle: separate
              title: Example Saved Report 0
              window: today
            - accumulate: false
              aggregateBy: controllerKind
              filters:
              - property: label
                value: app:cost*,environment:kube*
              - property: namespace
                value: kubecost
              idle: share
              title: Example Saved Report 1
              window: month
            - accumulate: true
              aggregateBy: service
              filters: []
              idle: hide
              title: Example Saved Report 2
              window: 2020-11-11T00:00:00Z,2020-12-09T23:59:59Z
          thanos:
            enabled: false
        grafana:
          grafana.ini:
            server:
              root_url: '%(protocol)s://%(domain)s:%(http_port)s/grafana'
          sidecar:
            dashboards:
              enabled: true
              label: kubecost_grafana_dashboard
            datasources:
              enabled: false
        ingress:
          annotations: null
          className: nginx
          enabled: false
          hosts:
          - kubecost-cost-analyzer.c38cca9c474484bdc9873f44f733d8bcd.cn-beijing.alicontainer.com
          pathType: ImplementationSpecific
          paths:
          - /
          tls: []
        initChownData:
          resources: {}
        initChownDataImage: busybox
        kubecost:
          disableServer: false
          image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/kubecost1/server
          resources:
            requests:
              cpu: 100m
              memory: 55Mi
        kubecostDeployment:
          replicas: 1
        kubecostFrontend:
          image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/kubecost1/frontend
          imagePullPolicy: Always
          resources:
            requests:
              cpu: 10m
              memory: 55Mi
        kubecostModel:
          etl: true
          etlDailyStoreDurationDays: 91
          etlHourlyStoreDurationHours: 49
          image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/kubecost1/cost-model
          imagePullPolicy: Always
          maxQueryConcurrency: 5
          outOfClusterPromMetricsEnabled: false
          resources:
            requests:
              cpu: 200m
              memory: 55Mi
          warmCache: false
          warmSavingsCache: true
        kubecostToken: MzEyMTg5Mzk3QHFxLmNvbQ==xm343yadf98
        networkCosts:
          additionalLabels: {}
          affinity: {}
          annotations: {}
          config:
            destinations:
              cross-region: []
              direct-classification: []
              in-region: []
              in-zone:
              - 127.0.0.1
              - 169.254.0.0/16
              - 10.0.0.0/8
              - 172.16.0.0/12
              - 192.168.0.0/16
          enabled: false
          image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/kubecost1/kubecost-network-costs
          imagePullPolicy: Always
          nodeSelector: {}
          podMonitor:
            additionalLabels: {}
            enabled: false
          podSecurityPolicy:
            enabled: false
          port: 3001
          priorityClassName: []
          prometheusScrape: false
          resources: {}
          tag: v15.7
          tolerations: []
          trafficLogging: true
        networkPolicy:
          costAnalyzer:
            additionalLabels: {}
            annotations: {}
            enabled: false
          denyEgress: true
          enabled: false
          sameNamespace: true
        persistentVolume:
          accessModes:
          - ReadWriteOnce
          dbSize: 100.0Gi
          enabled: true
          size: 100Gi
          storageClass: '{{ Global.STORAGE_CLASS }}'
        prometheus:
          alertmanager:
            enabled: false
            persistentVolume:
              enabled: true
          extraScrapeConfigs: "- job_name: kubecost\n  honor_labels: true\n  scrape_interval: 1m\n  scrape_timeout: 10s\n  metrics_path: /metrics\n  scheme: http\n  dns_sd_configs:\n  - names:\n    - {{ template \"cost-analyzer.serviceName\" . }}\n    type: 'A'\n    port: 9003\n- job_name: kubecost-networking\n  kubernetes_sd_configs:\n    - role: pod\n  relabel_configs:\n  # Scrape only the the targets matching the following metadata\n    - source_labels: [__meta_kubernetes_pod_label_app]\n      action: keep\n      regex:  {{ template \"cost-analyzer.networkCostsName\" . }}\n"
          kube-state-metrics:
            disabled: false
            image:
              pullPolicy: Always
              repository: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/kube-state-metrics
              tag: v1.9.8
          nodeExporter:
            enabled: true
            service:
              annotations:
                prometheus.io/scrape: 'true'
              clusterIP: None
              hostPort: 9010
              servicePort: 9010
              type: ClusterIP
          pushgateway:
            enabled: false
            persistentVolume:
              enabled: true
          server:
            extraArgs:
              query.max-concurrency: 1
              query.max-samples: 100000000
            global:
              evaluation_interval: 1m
              external_labels:
                cluster_id: cluster123
              scrape_interval: 1m
              scrape_timeout: 10s
            persistentVolume:
              accessModes:
              - ReadWriteOnce
              enabled: true
              size: 100Gi
              storageClass: '{{ Global.STORAGE_CLASS }}'
            resources: {}
            tolerations: []
          serverFiles:
            rules:
              groups:
              - name: CPU
                rules:
                - expr: sum(rate(container_cpu_usage_seconds_total{container_name!=""}[5m]))
                  record: cluster:cpu_usage:rate5m
                - expr: rate(container_cpu_usage_seconds_total{container_name!=""}[5m])
                  record: cluster:cpu_usage_nosum:rate5m
                - expr: avg(irate(container_cpu_usage_seconds_total{container_name!="POD", container_name!=""}[5m])) by (container_name,pod_name,namespace)
                  record: kubecost_container_cpu_usage_irate
                - expr: sum(container_memory_working_set_bytes{container_name!="POD",container_name!=""}) by (container_name,pod_name,namespace)
                  record: kubecost_container_memory_working_set_bytes
                - expr: sum(container_memory_working_set_bytes{container_name!="POD",container_name!=""})
                  record: kubecost_cluster_memory_working_set_bytes
              - name: Savings
                rules:
                - expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod))
                  labels:
                    daemonset: 'false'
                  record: kubecost_savings_cpu_allocation
                - expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod)) / sum(kube_node_info)
                  labels:
                    daemonset: 'true'
                  record: kubecost_savings_cpu_allocation
                - expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod))
                  labels:
                    daemonset: 'false'
                  record: kubecost_savings_memory_allocation_bytes
                - expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod)) / sum(kube_node_info)
                  labels:
                    daemonset: 'true'
                  record: kubecost_savings_memory_allocation_bytes
                - expr: label_replace(sum(kube_pod_status_phase{phase="Running",namespace!="kube-system"} > 0) by (pod, namespace), "pod_name", "$1", "pod", "(.+)")
                  record: kubecost_savings_running_pods
                - expr: sum(rate(container_cpu_usage_seconds_total{container_name!="",container_name!="POD",instance!=""}[5m])) by (namespace, pod_name, container_name, instance)
                  record: kubecost_savings_container_cpu_usage_seconds
                - expr: sum(container_memory_working_set_bytes{container_name!="",container_name!="POD",instance!=""}) by (namespace, pod_name, container_name, instance)
                  record: kubecost_savings_container_memory_usage_bytes
                - expr: avg(sum(kube_pod_container_resource_requests{resource="cpu", unit="core", namespace!="kube-system"}) by (pod, namespace, instance)) by (pod, namespace)
                  record: kubecost_savings_pod_requests_cpu_cores
                - expr: avg(sum(kube_pod_container_resource_requests{resource="memory", unit="byte", namespace!="kube-system"}) by (pod, namespace, instance)) by (pod, namespace)
                  record: kubecost_savings_pod_requests_memory_bytes
        prometheusRule:
          additionalLabels: {}
          enabled: false
        reporting:
          errorReporting: true
          logCollection: true
          productAnalytics: true
          valuesReporting: true
        service:
          annotations: {}
          labels: {}
          port: 9090
          targetPort: 9090
          type: ClusterIP
        serviceMonitor:
          additionalLabels: {}
          enabled: false
        supportNFS: false
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-kubecost'
    revisionName: HELM|kubecost|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        alertmanager:
          enabled: false
        configmapReload:
          alertmanager:
            enabled: false
          prometheus:
            enabled: false
        kubeStateMetrics:
          enabled: false
        nodeExporter:
          enabled: false
        podSecurityPolicy:
          enabled: false
        pushgateway:
          enabled: false
        rbac:
          create: true
        server:
          enabled: true
          persistentVolume:
            accessModes:
            - ReadWriteOnce
            enabled: true
            existingClaim: ''
            mountPath: /data
            size: 20Gi
            storageClass: '{{ Global.STORAGE_CLASS }}'
        serverFiles:
          prometheus.yml:
            rule_files:
            - /etc/config/recording_rules.yml
            - /etc/config/alerting_rules.yml
            scrape_configs:
            - job_name: prometheus
              static_configs:
              - targets:
                - localhost:9090
            - job_name: kubernetes-pods
              kubernetes_sd_configs:
              - role: pod
              relabel_configs:
              - action: keep
                regex: true
                source_labels:
                - __meta_kubernetes_pod_annotation_prometheus_io_scrape
              - action: replace
                regex: (.+)
                source_labels:
                - __meta_kubernetes_pod_annotation_prometheus_io_path
                target_label: __metrics_path__
              - action: replace
                regex: ([^:]+)(?::\d+)?;(\d+)
                replacement: $1:$2
                source_labels:
                - __address__
                - __meta_kubernetes_pod_annotation_prometheus_io_port
                target_label: __address__
              - action: labelmap
                regex: __meta_kubernetes_pod_label_(.+)
              - action: replace
                source_labels:
                - __meta_kubernetes_namespace
                target_label: kubernetes_namespace
              - action: replace
                source_labels:
                - __meta_kubernetes_pod_name
                target_label: kubernetes_pod_name
        serviceAccounts:
          alertmanager:
            annotations: {}
            create: true
            name: null
          nodeExporter:
            annotations: {}
            create: true
            name: null
          pushgateway:
            annotations: {}
            create: true
            name: null
          server:
            annotations: {}
            create: true
            name: null
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-prometheus'
    revisionName: HELM|prometheus|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        clusterHealthCheckEnable: false
        clusterName: '{{ Global.STAGE_ID }}-dataops-elasticsearch'
        esConfig:
          elasticsearch.yml: 'xpack.security.enabled: true

            discovery.type: single-node

            path.data: /usr/share/elasticsearch/data

            '
        extraEnvs:
        - name: cluster.initial_master_nodes
          value: ''
        - name: ELASTIC_PASSWORD
          value: '{{ Global.DATA_ES_PASSWORD }}'
        - name: ELASTIC_USERNAME
          value: '{{ Global.DATA_ES_USER }}'
        image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/elasticsearch
        imageTag: 7.10.2-with-plugins
        minimumMasterNodes: 1
        replicas: 1
        volumeClaimTemplate:
          accessModes:
          - ReadWriteOnce
          resources:
            requests:
              storage: 100Gi
          storageClassName: '{{ Global.STORAGE_CLASS }}'
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-elasticsearch'
    revisionName: HELM|elasticsearch|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        extraEnvs:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        filebeatConfig:
          filebeat.yml: "filebeat.autodiscover:\n  providers:\n    - type: kubernetes\n      node: ${NODE_NAME}\n      resource: pod\n      scope: node\n      templates:\n        - condition:\n            equals:\n              kubernetes.labels.sreworks-telemetry-log: enable\n          config:\n            - type: container\n              paths:\n                - /var/log/containers/*${data.kubernetes.container.id}.log\n              multiline:\n                type: pattern\n                pattern: '^(\\[)?20\\d{2}-(1[0-2]|0?[1-9])-(0?[1-9]|[1-2]\\d|30|31)'\n                negate: true\n                match: after\n              processors:\n                - add_kubernetes_metadata:\n                    host: ${NODE_NAME}\n                    matchers:\n                    - logs_path:\n                        logs_path: \"/var/log/containers/\"\n\nsetup.ilm.enabled: auto\nsetup.ilm.rollover_alias: \"filebeat\"\nsetup.ilm.pattern: \"{now/d}-000001\"\nsetup.template.name: \"filebeat\"\nsetup.template.pattern: \"filebeat-*\"\n\noutput.elasticsearch:\n  hosts: '{{ Global.DATA_ES_HOST }}:{{ Global.DATA_ES_PORT }}'\n  index: \"filebeat-%{+yyyy.MM.dd}\"\n  username: \"{{ Global.DATA_ES_USER }}\"\n  password: \"{{ Global.DATA_ES_PASSWORD }}\""
        hostNetworking: true
        image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/filebeat
        imageTag: 7.10.2
        labels:
          k8s-app: filebeat
        podAnnotations:
          name: filebeat
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-filebeat'
    revisionName: HELM|filebeat|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        adminPassword: sreworks123456
        adminUser: admin
        dashboardProviders:
          dashboardproviders.yaml:
            apiVersion: 1
            providers:
            - disableDeletion: false
              editable: true
              folder: sreworks-dataops
              name: flink
              options:
                path: /var/lib/grafana/dashboards/flink
              orgId: 1
              type: file
            - disableDeletion: false
              editable: true
              folder: sreworks-dataops
              name: cost
              options:
                path: /var/lib/grafana/dashboards/cost
              orgId: 1
              type: file
        dashboards:
          cost:
            cost-dashboard:
              file: dashboards/cost-dashboard.json
          flink:
            flink-dashboard:
              file: dashboards/flink-dashboard.json
        datasources:
          datasources.yaml:
            apiVersion: 1
            datasources:
            - access: proxy
              basicAuth: true
              basicAuthPassword: '{{ Global.DATA_ES_PASSWORD }}'
              basicAuthUser: '{{ Global.DATA_ES_USER }}'
              database: '[metricbeat]*'
              isDefault: true
              jsonData:
                esVersion: 70
                interval: Yearly
                timeField: '@timestamp'
              name: elasticsearch-metricbeat
              type: elasticsearch
              url: http://{{ Global.DATA_ES_HOST }}:{{ Global.DATA_ES_PORT }}
            - access: proxy
              basicAuth: true
              basicAuthPassword: '{{ Global.DATA_ES_PASSWORD }}'
              basicAuthUser: '{{ Global.DATA_ES_USER }}'
              database: '[filebeat]*'
              isDefault: false
              jsonData:
                esVersion: 70
                interval: Yearly
                logLevelField: fields.level
                logMessageField: message
                timeField: '@timestamp'
              name: elasticsearch-filebeat
              type: elasticsearch
              url: http://{{ Global.DATA_ES_HOST }}:{{ Global.DATA_ES_PORT }}
            - access: proxy
              httpMethod: POST
              name: dataops-prometheus
              type: prometheus
              url: http://{{ Global.DATA_PROM_HOST}}:{{ Global.DATA_PROM_PORT }}
            - access: proxy
              httpMethod: POST
              name: prometheus-cluster-default
              type: prometheus
              url: http://{{ Global.DATA_PROM_HOST}}:{{ Global.DATA_PROM_PORT }}
            - access: proxy
              isDefault: false
              name: dataset
              type: marcusolsson-json-datasource
              url: http://{{ Global.STAGE_ID }}-{{ Global.APP_ID }}-dataset.{{ Global.NAMESPACE_ID }}
        grafana.ini:
          auth.anonymous:
            enabled: false
          auth.basic:
            enabled: false
          auth.proxy:
            auto_sign_up: true
            enable_login_token: false
            enabled: true
            header_name: x-auth-user
            headers: Name:x-auth-user Email:x-auth-email-addr
            ldap_sync_ttl: 60
            sync_ttl: 60
          security:
            allow_embedding: true
          server:
            root_url: /gateway/dataops-grafana/
            serve_from_sub_path: true
        image:
          repository: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/grafana
          tag: 7.5.3
        plugins:
        - marcusolsson-json-datasource
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-grafana'
    revisionName: HELM|grafana|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        elasticsearchHosts: http://{{ Global.DATA_ES_HOST }}:{{ Global.DATA_ES_PORT }}
        image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/kibana
        ingress:
          enabled: false
        kibanaConfig:
          kibana.yml: 'elasticsearch.username: {{ Global.DATA_ES_USER }}

            elasticsearch.password: {{ Global.DATA_ES_PASSWORD }}'
        resources:
          limits:
            cpu: 300m
            memory: 512Mi
          requests:
            cpu: 200m
            memory: 512Mi
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-kibana'
    revisionName: HELM|kibana|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        clusterRoleRules:
        - apiGroups:
          - ''
          resources:
          - nodes
          - namespaces
          - events
          - pods
          verbs:
          - get
          - list
          - watch
        - apiGroups:
          - extensions
          resources:
          - replicasets
          verbs:
          - get
          - list
          - watch
        - apiGroups:
          - apps
          resources:
          - statefulsets
          - deployments
          - replicasets
          verbs:
          - get
          - list
          - watch
        - apiGroups:
          - ''
          resources:
          - nodes/stats
          - nodes
          - services
          - endpoints
          - pods
          verbs:
          - get
          - list
          - watch
        - nonResourceURLs:
          - /metrics
          verbs:
          - get
        - apiGroups:
          - coordination.k8s.io
          resources:
          - leases
          verbs:
          - '*'
        daemonset:
          annotations:
            name: metricbeat
          enabled: true
          extraEnvs:
          - name: ELASTICSEARCH_HOSTS
            value: '{{ Global.STAGE_ID }}-dataops-elasticsearch-master.{{ Global.NAMESPACE_ID }}.svc.cluster.local'
          - name: NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          - name: NODE_IP
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          hostNetworking: true
          labels:
            k8s-app: metricbeat
          metricbeatConfig:
            metricbeat.yml: "metricbeat.modules:\n- module: kubernetes\n  metricsets:\n    - container\n    - node\n    - pod\n    - system\n    - volume\n  period: 1m\n  host: \"${NODE_NAME}\"\n  hosts: [\"https://${NODE_IP}:10250\"]\n  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token\n  ssl.verification_mode: \"none\"\n  # If using Red Hat OpenShift remove ssl.verification_mode entry and\n  # uncomment these settings:\n  ssl.certificate_authorities:\n    - /var/run/secrets/kubernetes.io/serviceaccount/ca.crt\n  processors:\n  - add_kubernetes_metadata: ~\n- module: kubernetes\n  enabled: true\n  metricsets:\n    - event\n- module: kubernetes\n  metricsets:\n    - proxy\n  period: 1m\n  host: ${NODE_NAME}\n  hosts: [\"localhost:10249\"]\n- module: system\n  period: 1m\n  metricsets:\n    - cpu\n    - load\n    - memory\n    - network\n    - process\n    - process_summary\n  cpu.metrics: [percentages, normalized_percentages]\n  processes: ['.*']\n  process.include_top_n:\n    by_cpu: 5\n    by_memory: 5\n- module: system\n  period: 1m\n  metricsets:\n    - filesystem\n    - fsstat\n  processors:\n  - drop_event.when.regexp:\n      system.filesystem.mount_point: '^/(sys|cgroup|proc|dev|etc|host|lib)($|/)'\n\nmetricbeat.autodiscover:\n  providers:\n    - type: kubernetes\n      scope: cluster\n      node: ${NODE_NAME}\n      resource: service\n      templates:\n        - condition:\n            equals:\n              kubernetes.labels.sreworks-telemetry-metric: enable\n          config:\n            - module: http\n              metricsets:\n                - json\n              period: 1m\n              hosts: [\"http://${data.host}:10080\"]\n              namespace: \"${data.kubernetes.namespace}#${data.kubernetes.service.name}\"\n              path: \"/\"\n              method: \"GET\"\n\n    - type: kubernetes\n      scope: cluster\n      node: ${NODE_NAME}\n      unique: true\n      templates:\n        - config:\n            - module: kubernetes\n              hosts: [\"kubecost-kube-state-metrics.sreworks-client.svc.cluster.local:8080\"]\n              period: 1m\n              add_metadata: true\n              metricsets:\n                - state_node\n                - state_deployment\n                - state_daemonset\n                - state_replicaset\n                - state_pod\n                - state_container\n                - state_cronjob\n                - state_resourcequota\n                - state_statefulset\n                - state_service\n\nprocessors:\n  - add_cloud_metadata:\n\nsetup.ilm.enabled: auto\nsetup.ilm.rollover_alias: \"metricbeat\"\nsetup.ilm.pattern: \"{now/d}-000001\"\nsetup.template.name: \"metricbeat\"\nsetup.template.pattern: \"metricbeat-*\"\n\noutput.elasticsearch:\n  hosts: '${ELASTICSEARCH_HOSTS:{{ Global.STAGE_ID }}-dataops-elasticsearch-master:9200}'\n  index: \"metricbeat-%{+yyyy.MM.dd}\"\n"
          resources:
            limits:
              cpu: 1000m
              memory: 500Mi
            requests:
              cpu: 100m
              memory: 100Mi
        deployment:
          enabled: false
        image: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/metricbeat
        kube_state_metrics:
          enabled: false
        serviceAccount: metricbeat-sa
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-metricbeat'
    revisionName: HELM|metricbeat|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        auth:
          rootPassword: cb56b5is5e21_c359b42223
        global:
          storageClass: '{{ Global.STORAGE_CLASS }}'
        image:
          registry: sreworks-registry.cn-beijing.cr.aliyuncs.com
          repository: mirror/mysql
          tag: 8.0.22-debian-10-r44
        primary:
          extraFlags: --max-connect-errors=1000 --max_connections=10000
          persistence:
            size: 50Gi
          service:
            type: ClusterIP
        replication:
          enabled: false
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-mysql'
    revisionName: HELM|mysql|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        elasticsearch:
          config:
            host: '{{ Global.STAGE_ID }}-dataops-elasticsearch-master.{{ Global.NAMESPACE_ID }}.svc.cluster.local'
            password: '{{ Global.DATA_ES_PASSWORD }}'
            port:
              http: 9200
            user: '{{ Global.DATA_ES_USER }}'
          enabled: false
        oap:
          image:
            repository: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/skywalking-oap-server-utc-8
            tag: 9.2.0
          javaOpts: -Xmx1g -Xms1g
          replicas: 1
          storageType: elasticsearch
        ui:
          image:
            repository: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror/skywalking-ui:9.2.0
            tag: 9.2.0
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-skywalking'
    revisionName: HELM|skywalking|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dependencies:
    - component: RESOURCE_ADDON|system-env@system-env
    parameterValues:
    - name: values
      toFieldPaths:
      - spec.values
      value:
        acceptCommunityEditionLicense: true
        blobStorageCredentials:
          s3:
            accessKeyId: '{{ Global.MINIO_ACCESS_KEY }}'
            secretAccessKey: '{{ Global.MINIO_SECRET_KEY }}'
        persistentVolume:
          accessModes:
          - ReadWriteOnce
          annotations: {}
          enabled: true
          size: 20Gi
          storageClass: '{{ Global.STORAGE_CLASS }}'
          subPath: ''
        vvp:
          blobStorage:
            baseUri: s3://vvp
            s3:
              endpoint: http://sreworks-minio.sreworks:9000
          globalDeploymentDefaults: "spec:\n  state: RUNNING\n  template:\n    spec:\n      resources:\n        jobmanager:\n          cpu: 0.5\n          memory: 1G\n        taskmanager:\n          cpu: 0.5\n          memory: 1G\n      flinkConfiguration:\n        state.backend: filesystem\n        taskmanager.memory.managed.fraction: 0.0 # no managed memory needed for filesystem statebackend\n        high-availability: vvp-kubernetes\n        metrics.reporter.prom.class: org.apache.flink.metrics.prometheus.PrometheusReporter\n        execution.checkpointing.interval: 10s\n        execution.checkpointing.externalized-checkpoint-retention: RETAIN_ON_CANCELLATION\n"
          persistence:
            type: local
          registry: sreworks-registry.cn-beijing.cr.aliyuncs.com/mirror
          sqlService:
            pool:
              coreSize: 1
              maxSize: 1
    - name: name
      toFieldPaths:
      - spec.name
      value: '{{ Global.STAGE_ID }}-dataops-ververica-platform'
    revisionName: HELM|ververica-platform|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - dataInputs: []
    dataOutputs: []
    dependencies: []
    parameterValues:
    - name: STAGE_ID
      toFieldPaths:
      - spec.stageId
      value: prod
    revisionName: INTERNAL_ADDON|productopsv2|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
    traits: []
  - parameterValues:
    - name: STAGE_ID
      toFieldPaths:
      - spec.stageId
      value: prod
    revisionName: INTERNAL_ADDON|developmentmeta|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
  - parameterValues:
    - name: STAGE_ID
      toFieldPaths:
      - spec.stageId
      value: prod
    - name: OVERWRITE_IS_DEVELOPMENT
      toFieldPaths:
      - spec.overwriteIsDevelopment
      value: 'true'
    revisionName: INTERNAL_ADDON|appmeta|_
    scopes:
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Cluster
        name: '{{ Global.CLUSTER_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Namespace
        name: '{{ Global.NAMESPACE_ID }}'
    - scopeRef:
        apiVersion: apps.abm.io/v1
        kind: Stage
        name: '{{ Global.STAGE_ID }}'
  parameterValues:
  - name: CLUSTER_ID
    value: master
  - name: NAMESPACE_ID
    value: ${NAMESPACE_ID}
  - name: STAGE_ID
    value: prod
  - name: APP_ID
    value: dataops
  - name: KAFKA_ENDPOINT
    value: ${KAFKA_ENDPOINT}:9092
  - name: DATA_ES_HOST
    value: ${DATA_ES_HOST}
  - name: DATA_ES_PORT
    value: ${DATA_ES_PORT}
  policies: []
  workflow:
    steps: []
