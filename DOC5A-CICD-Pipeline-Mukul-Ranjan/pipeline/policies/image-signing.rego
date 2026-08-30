package novapay.compliance.image_signing

# Image-signing policy for CI/CD artifacts.
# The deployment artifact must be immutable, signed, and verifiable.
# Expected input shape:
# {
#   "artifact": {
#     "image": "registry.example/app",
#     "digest": "sha256:...",
#     "signature_verified": true,
#     "signer_identity": "..."
#   }
# }

default allow := false

allow if {
    input.artifact.digest
    startswith(input.artifact.digest, "sha256:")
    input.artifact.signature_verified == true
    input.artifact.signer_identity
}

violation[msg] if {
    not input.artifact.digest
    msg := "BLOCK: deployment artifact digest is missing"
}

violation[msg] if {
    input.artifact.digest
    not startswith(input.artifact.digest, "sha256:")
    msg := "BLOCK: artifact must be referenced by a SHA-256 digest"
}

violation[msg] if {
    input.artifact.signature_verified != true
    msg := "BLOCK: container image signature verification failed"
}

violation[msg] if {
    not input.artifact.signer_identity
    msg := "BLOCK: trusted signer identity is missing"
}
