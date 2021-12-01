FROM golang:1.16-alpine AS build
WORKDIR /app
COPY go.mod ./
#COPY go.sum ./
RUN go mod download
COPY . .
RUN go build -o manager

##
## Deploy
##
FROM alpine
WORKDIR /
COPY --from=build /app /app
EXPOSE 9091
ENTRYPOINT ["/app/manager"]