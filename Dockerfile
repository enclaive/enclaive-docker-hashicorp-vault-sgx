FROM gramineproject/gramine:v1.5

RUN curl -s -o - https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com focal main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends vault \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/

COPY ./vault.manifest.template ./config.hcl ./

RUN gramine-sgx-gen-private-key \
    && gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu vault.manifest.template vault.manifest \
    && gramine-sgx-sign --manifest vault.manifest --output vault.manifest.sgx \
    && gramine-sgx-get-token --output vault.token --sig vault.sig

VOLUME /data/

ENTRYPOINT [ "gramine-sgx", "vault" ]
