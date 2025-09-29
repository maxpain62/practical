{{- define "myapp.labels" -}}
app: {{ .Values.labels.app }}
tier: {{ .Values.labels.tier }}
env: {{ .Values.labels.env }}
version: {{ .Values.labels.version }}
{{- end -}}

{{- define "myapp.matchlabels" -}}
app: {{ .Values.labels.app }}
tier: {{ .Values.labels.tier }}
env: {{ .Values.labels.env }}
{{- end -}}