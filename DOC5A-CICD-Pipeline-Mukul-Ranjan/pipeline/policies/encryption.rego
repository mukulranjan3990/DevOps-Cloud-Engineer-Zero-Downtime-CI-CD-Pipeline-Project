package novapay.compliance.encryption

# Encryption policy for protected data and service communications.
# Expected input shape:
# {
#   "transport": {
#     "tls_enabled": true,
#     "tls_version": "TLS1.3"
#   },
#   "storage": {
#     "encryption_enabled": true,
#     "algorithm": "AES-256"
#   },
#   "secrets": {
#     "encrypted_at_rest": true
#   }
# }

default allow := false

allow if {
    input.transport.tls_enabled == true
    input.transport.tls_version == "TLS1.3"
    input.storage.encryption_enabled == true
    input.storage.algorithm == "AES-256"
    input.secrets.encrypted_at_rest == true
}

violation[msg] if {
    input.transport.tls_enabled != true
    msg := "BLOCK: encryption in transit must be enabled"
}

violation[msg] if {
    input.transport.tls_enabled == true
    input.transport.tls_version != "TLS1.3"
    msg := "BLOCK: transport encryption must use TLS 1.3"
}

violation[msg] if {
    input.storage.encryption_enabled != true
    msg := "BLOCK: encryption at rest must be enabled"
}

violation[msg] if {
    input.storage.encryption_enabled == true
    input.storage.algorithm != "AES-256"
    msg := "BLOCK: protected storage must use AES-256"
}

violation[msg] if {
    input.secrets.encrypted_at_rest != true
    msg := "BLOCK: secrets must be encrypted at rest"
}
