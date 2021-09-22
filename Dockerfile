FROM ubuntu:focal

# docker-composeでaptのミラーを設定できるように
ARG APT_SOURCE_BASE=ftp.jaist.ac.jp/pub/Linux/ubuntu/

ENV TZ Asia/Tokyo
# aptでインストール時にインタラクティブな選択肢が表示されなくなる
ENV DEBIAN_FRONTEND noninteractive
# デフォルトだと/root/.poetry以下に作成されてパス通しずらいのでグローバルなディレクトリに配置する
ENV POETRY_HOME /usr/local/lib/poetry
ENV LANG ja_JP.UTF-8

RUN set -eux  \
    &&  if [ -n "${APT_SOURCE_BASE}" ]; then \
            sed -i.bak -e "s|archive.ubuntu.com|${APT_SOURCE_BASE}|g" /etc/apt/sources.list;  \
        fi \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends --no-install-suggests \
            less \
            tzdata \
            curl \
            python3-pip \
    &&  curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 - \
    &&  ln -s ${POETRY_HOME}/bin/poetry /usr/local/bin/

COPY pyproject.toml ./
COPY poetry.lock ./

# コンテナ内なのでvirtualenvを作成しない
RUN set -eux \
    &&  poetry config virtualenvs.create false \
    &&  poetry install

# .dockerignore記載以外の全ファイルをコピー
COPY . .

WORKDIR /app
# /appいかに配置することでイメージをビルドせずにentrypointスクリプトの変更が反映できる
ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
