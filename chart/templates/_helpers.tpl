{{- define "canary-web.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "canary-web.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Track-specific name, e.g. web-canary-web-canary. Tracks: stable, canary. */}}
{{- define "canary-web.trackName" -}}
{{- printf "%s-%s" (include "canary-web.fullname" .root) .track | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Selector labels include the track so the two Services never overlap. */}}
{{- define "canary-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "canary-web.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .track }}
{{- end -}}

{{- define "canary-web.labels" -}}
{{ include "canary-web.selectorLabels" . }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
app.kubernetes.io/part-of: canary-web
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .root.Chart.Name .root.Chart.Version }}
{{- end -}}
