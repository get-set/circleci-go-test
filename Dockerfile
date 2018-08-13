# Build Stage
FROM lacion/alpine-golang-buildimage:1.10.3 AS build-stage

LABEL app="build-circleci-go-test"
LABEL REPO="https://github.com/get-set/circleci-go-test"

ENV PROJPATH=/go/src/github.com/get-set/circleci-go-test

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/get-set/circleci-go-test
WORKDIR /go/src/github.com/get-set/circleci-go-test

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/get-set/circleci-go-test"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/circleci-go-test/bin

WORKDIR /opt/circleci-go-test/bin

COPY --from=build-stage /go/src/github.com/get-set/circleci-go-test/bin/circleci-go-test /opt/circleci-go-test/bin/
RUN chmod +x /opt/circleci-go-test/bin/circleci-go-test

# Create appuser
RUN adduser -D -g '' circleci-go-test
USER circleci-go-test

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/circleci-go-test/bin/circleci-go-test"]
