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
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.general }}
    {{- if .Values.general.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.general.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name (for the metrics image)
*/}}
{{- define "backend-java-patterns.metrics.image" -}}
{{- $registryName := .Values.metrics.image.registry -}}
{{- $repositoryName := .Values.metrics.image.repository -}}
{{- $tag := .Values.metrics.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.general }}
    {{- if .Values.general.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.general.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Storage Class
*/}}
{{- define "backend-java-patterns.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .Values.general -}}
    {{- if .Values.general.storageClass -}}
        {{- if (eq "-" .Values.general.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.general.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.persistence.storageClass -}}
              {{- if (eq "-" .Values.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else }}
                  {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.persistence.storageClass -}}
        {{- if (eq "-" .Values.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}


{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "backend-java-patterns.validateValues" -}}
{{- $messages := list -}}
{{- $messages2 := append $messages (include "backend-java-patterns.validateValues.customDatabase" .) -}}
{{- $messages3 := without $messages2 "" -}}
{{- $message := join "\n" $messages3 -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate both values: username and database that are necessary
to create a custom user and database during initialization
*/}}
{{- define "backend-java-patterns.validateValues.customDatabase" -}}
{{- if or (and .Values.general.username (not .Values.general.database)) (and (not .Values.general.username) .Values.general.database) }}
db: username, database
    Both username and database must be provided to create
    a custom user and database during 1st initialization.
    Please set both of them (--set username="xxxx",database="yyyy")
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "backend-java-patterns.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.general }}
{{- if .Values.general.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.general.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else if or .Values.image.pullSecrets .Values.metrics.image.pullSecrets .Values.volumePermissions.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.volumePermissions.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- else if or .Values.image.pullSecrets .Values.metrics.image.pullSecrets .Values.volumePermissions.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.volumePermissions.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "backend-java-patterns.volumePermissions.image" -}}
{{- $registryName := .Values.volumePermissions.image.registry -}}
{{- $repositoryName := .Values.volumePermissions.image.repository -}}
{{- $tag := .Values.volumePermissions.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.general }}
    {{- if .Values.general.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.general.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return port
*/}}
{{- define "backend-java-patterns.port" -}}
{{- if .Values.general.servicePort }}
    {{- .Values.general.servicePort -}}
{{- else if .Values.service.httpPort }}
    {{- .Values.service.httpPort -}}
{{- else if .Values.service.nodePort }}
  {{- .Values.service.nodePort -}}
{{- else -}}
  {{- .Values.service.port -}}
{{- end -}}
{{- end -}}
