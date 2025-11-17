FROM postgres:14

ARG PG_MAJOR=14

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      python3 \
      python3-dev \
      libpython3-dev \
      postgresql-server-dev-${PG_MAJOR} \
      postgresql-plpython3-${PG_MAJOR} \
      build-essential \
      curl \
      ca-certificates \
      postgresql-client-${PG_MAJOR} \
      pgxnclient \
      python3-pip; \
    \
    pip3 install --break-system-packages faker; \
    [ -x /usr/bin/gmake ] || ln -s /usr/bin/make /usr/bin/gmake; \
    pgxn install postgresql_faker; \
    apt-mark manual postgresql-client-${PG_MAJOR}; \
    apt-get purge -y \
      postgresql-server-dev-${PG_MAJOR} \
      build-essential; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*