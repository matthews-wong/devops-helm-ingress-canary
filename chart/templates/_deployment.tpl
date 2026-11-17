{{/* Expects: root (top-level context), track (stable|canary), spec (the track's values). */}}
{{- define "canary-web.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "canary-web.trackName" . }}
  labels:
    {{- include "canary-web.labels" . | nindent 4 }}
spec:
  replicas: {{ .spec.replicaCount }}
  selector:
    matchLabels:
      {{- include "canary-web.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "canary-web.labels" . | nindent 8 }}
    spec:
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 101
        runAsGroup: 101
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: web
          image: "{{ .spec.image.repository }}:{{ .spec.image.tag }}"
          imagePullPolicy: {{ .spec.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .root.Values.containerPort }}
          resources:
            {{- toYaml .root.Values.resources | nindent 12 }}
          startupProbe:
            httpGet:
              path: {{ .root.Values.probes.path }}
              port: http
            periodSeconds: 2
            failureThreshold: 15
          livenessProbe:
            httpGet:
              path: {{ .root.Values.probes.path }}
              port: http
            initialDelaySeconds: {{ .root.Values.probes.initialDelaySeconds }}
            periodSeconds: {{ .root.Values.probes.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .root.Values.probes.path }}
              port: http
            initialDelaySeconds: {{ .root.Values.probes.initialDelaySeconds }}
            periodSeconds: {{ .root.Values.probes.periodSeconds }}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: [ALL]
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir:
            sizeLimit: 16Mi
{{- end -}}
