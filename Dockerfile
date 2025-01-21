# Stage 1: Build Angular frontend
FROM node:22-alpine as angular-build

WORKDIR /app

COPY ./frontend/package.json ./frontend/package-lock.json ./
RUN npm install

COPY ./frontend/ ./

RUN npm run build --prod

FROM golang:1.23-alpine as go-build

WORKDIR /go/src/app

COPY ./backend/go.mod ./backend/go.sum ./
RUN go mod tidy

COPY ./backend/ ./

COPY --from=angular-build /app/dist/frontend/browser /go/src/app/cmd/strichliste/frontendDist

RUN CGO_ENABLED=0 go build -o ./strichliste ./cmd/strichliste/main.go

# Stage 3: Final Image
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app


COPY --from=go-build /go/src/app/strichliste /app/

EXPOSE 8080

CMD ["/app/strichliste"]

