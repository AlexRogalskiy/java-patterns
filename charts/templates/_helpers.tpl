{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "backend-java-patterns.name" -}}
{{- default .Chart.Name .Values.general.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the app version of the chart.
*/}}
{{- define "backend-java-patterns.appVersion" -}}
{{- default .Chart.AppVersion | trunc 33 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "backend-java-patterns.fullname" -}}
{{- if .Values.general.fullnameOverride }}
{{- .Values.general.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.general.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backend-java-patterns.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "backend-java-patterns.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backend-java-patterns.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | lower | quote }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "backend-java-patterns.labels" -}}
helm.sh/chart: {{ include "backend-java-patterns.chart" . }}
{{ include "backend-java-patterns.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create the name of the tls secret for secure port
*/}}
{{- define "backend-java-patterns.tlsSecretName" -}}
{{- $fullname := include "backend-java-patterns.name" . -}}
{{- default (printf "%s-tls" $fullname) .Values.tls.secretName -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "backend-java-patterns.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled }}
    {{- default (include "backend-java-patterns.fullname" .) .Values.serviceAccount.name }}
{{- else }}
    {{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for NetworkPolicy.
*/}}
{{- define "backend-java-patterns.networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <=1.7-0" .Capabilities.KubeVersion.GitVersion -}}
    {{- print "extensions/v1beta1" -}}
{{- else if semverCompare "^1.7-0" .Capabilities.KubeVersion.GitVersion -}}
    {{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for StatefulSets
*/}}
{{- define "backend-java-patterns.statefulset.apiVersion" -}}
{{- if semverCompare "<1.12-0" .Capabilities.KubeVersion.GitVersion -}}
    {{- print "apps/v1beta1" -}}
{{- else -}}
    {{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "backend-java-patterns.image" -}}
{{- $registryName := .Values.deployment.container.image.registry -}}
{{- $repositoryName := .Values.deployment.container.image.repository -}}
{{- $tag := .Values.deployment.container.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
