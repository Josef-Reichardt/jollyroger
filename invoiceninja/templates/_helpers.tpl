{{/*
Expand the name of the chart.
*/}}
{{- define "invoiceninja.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "invoiceninja.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "invoiceninja.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "invoiceninja.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "invoiceninja.selectorLabels" -}}
app.kubernetes.io/name: {{ include "invoiceninja.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MySQL host – explizit oder automatisch auf den StatefulSet-Service
*/}}
{{- define "invoiceninja.mysqlHost" -}}
{{- if .Values.env.DB_HOST }}
{{- .Values.env.DB_HOST }}
{{- else }}
{{- printf "%s-mysql-0.%s-mysql" (include "invoiceninja.fullname" .) (include "invoiceninja.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Redis host – explizit oder automatisch auf den StatefulSet-Service
*/}}
{{- define "invoiceninja.redisHost" -}}
{{- if .Values.env.REDIS_HOST }}
{{- .Values.env.REDIS_HOST }}
{{- else }}
{{- printf "%s-redis-0.%s-redis" (include "invoiceninja.fullname" .) (include "invoiceninja.fullname" .) }}
{{- end }}
{{- end }}

{{/*
QUEUE_CONNECTION: "redis" wenn redis aktiviert, sonst "database"
Kann durch env.QUEUE_CONNECTION überschrieben werden.
WICHTIG: Alles in einer Zeile – kein Newline im Rückgabewert.
*/}}
{{- define "invoiceninja.queueConnection" -}}
{{- if .Values.env.QUEUE_CONNECTION -}}{{ .Values.env.QUEUE_CONNECTION }}{{- else if .Values.redis.enabled -}}redis{{- else -}}database{{- end -}}
{{- end -}}

{{/*
CACHE_DRIVER: "redis" wenn redis aktiviert, sonst "file"
WICHTIG: Alles in einer Zeile – kein Newline im Rückgabewert.
*/}}
{{- define "invoiceninja.cacheDriver" -}}
{{- if .Values.env.CACHE_DRIVER -}}{{ .Values.env.CACHE_DRIVER }}{{- else if .Values.redis.enabled -}}redis{{- else -}}file{{- end -}}
{{- end -}}
