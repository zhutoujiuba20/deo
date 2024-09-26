FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/go-node AS build
RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp

RUN go mod tidy
RUN cd frontend && yarn install && yarn build
RUN go build -o csghub-portal ./cmd/csghub-portal

FROM bitnami/minideb:latest
RUN apt update && apt install -y ca-certificates && update-ca-certificates
WORKDIR /myapp
COPY --from=build /myapp/csghub-portal /myapp/csghub-portal
