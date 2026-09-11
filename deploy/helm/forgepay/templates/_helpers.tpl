{{/* AI Attribution Block: AI-assisted Helm helper definitions; requires human review. */}}
{{- define "forgepay.name" -}}{{ default .Chart.Name .Values.nameOverride }}{{- end }}
{{- define "forgepay.labels" -}}
app.kubernetes.io/name: {{ include "forgepay.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: forgepay
{{- end }}
{{- define "forgepay.pod" -}}
metadata:
  labels:
    {{- include "forgepay.labels" . | nindent 4 }}
spec:
  serviceAccountName: forgepay
  securityContext:
    runAsNonRoot: true
    seccompProfile: { type: RuntimeDefault }
  containers:
    - name: forgepay
      image: {{ required "image.reference must be set to a signed immutable digest" .Values.image.reference | quote }}
      imagePullPolicy: IfNotPresent
      ports: [{ name: http, containerPort: {{ .Values.service.port }} }]
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities: { drop: [ALL] }
      readinessProbe: { httpGet: { path: /actuator/health/readiness, port: http } }
      livenessProbe: { httpGet: { path: /actuator/health/liveness, port: http } }
      resources: {{- toYaml .Values.resources | nindent 8 }}
{{- end }}
