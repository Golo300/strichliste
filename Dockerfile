FROM node:22-alpine as angular-build

WORKDIR /app

COPY ./frontend/package.json ./frontend/package-lock.json ./
RUN npm ci

COPY ./frontend/ ./

RUN npx ng build

FROM golang:1.23-alpine as go-build

WORKDIR /go/src/app

COPY ./backend/go.mod ./backend/go.sum ./
RUN go mod download

COPY ./backend/ ./

COPY --from=angular-build /app/dist/frontend/browser /go/src/app/cmd/strichliste/frontendDist

RUN CGO_ENABLED=0 go build -o ./strichliste ./cmd/strichliste/main.go

FROM gcr.io/distroless/static-debian12

WORKDIR /app

COPY --from=go-build /go/src/app/strichliste /app/

EXPOSE 8080

CMD ["/app/strichliste"]
