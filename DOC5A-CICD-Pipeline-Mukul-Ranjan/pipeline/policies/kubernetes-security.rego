package novapay.compliance.kubernetes_security

# Kubernetes security policy for CI/CD admission/deployment.
# The workload must run with a restricted security posture.
# Expected input shape:
# {
#   "kind": "Deployment",
#   "spec": {
#     "template": {
#       "spec": {
#         "containers": [...],
#         "securityContext": {...},
#         "serviceAccountName": "..."
#       }
#     }
#   }
# }

default allow := false

pod_spec := input.spec.template.spec

allow if {
    pod_spec.securityContext.runAsNonRoot == true
    pod_spec.securityContext.seccompProfile.type == "RuntimeDefault"
    every container in pod_spec.containers {
        container.securityContext.allowPrivilegeEscalation == false
        container.securityContext.privileged == false
        container.securityContext.readOnlyRootFilesystem == true
        container.securityContext.capabilities.drop[_] == "ALL"
    }
}

violation[msg] if {
    pod_spec.securityContext.runAsNonRoot != true
    msg := "BLOCK: Kubernetes workload must run as non-root"
}

violation[msg] if {
    pod_spec.securityContext.seccompProfile.type != "RuntimeDefault"
    msg := "BLOCK: seccomp profile must be RuntimeDefault"
}

violation[msg] if {
    some container in pod_spec.containers
    container.securityContext.privileged == true
    msg := "BLOCK: privileged containers are not allowed"
}

violation[msg] if {
    some container in pod_spec.containers
    container.securityContext.allowPrivilegeEscalation != false
    msg := "BLOCK: privilege escalation must be disabled"
}

violation[msg] if {
    some container in pod_spec.containers
    container.securityContext.readOnlyRootFilesystem != true
    msg := "BLOCK: container root filesystem must be read-only"
}

violation[msg] if {
    some container in pod_spec.containers
    not "ALL" in container.securityContext.capabilities.drop
    msg := "BLOCK: containers must drop ALL Linux capabilities"
}
