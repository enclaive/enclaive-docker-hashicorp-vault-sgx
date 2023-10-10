FROM xmarginregistry.azurecr.io/xm-cscore-sgx-base-prod:3.3.1

ENV DEBUG=1
ENV VAULT_DISABLE_MLOCK=1
ENV PCCS_HOST=global.acccache.azure.net

RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ $(lsb_release -sc) main" \
  | tee /etc/apt/sources.list.d/gramine.list

RUN curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu $(lsb_release -sc) main" \
    | tee /etc/apt/sources.list.d/intel-sgx.list

RUN apt-get update && apt-get install -y gramine && gramine-sgx-gen-private-key

RUN  curl -s -o - https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com focal main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends vault \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/

COPY ./vault.manifest.template ./config.hcl ./

RUN gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu vault.manifest.template vault.manifest \
    && gramine-sgx-sign --manifest vault.manifest --output vault.manifest.sgx \
    && gramine-sgx-get-token --output vault.token --sig vault.sig

VOLUME /data/

WORKDIR /app/

COPY --chmod=555 ./entrypoint.sh  /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
