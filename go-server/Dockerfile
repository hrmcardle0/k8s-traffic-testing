# Use the official Go image as the base image
FROM golang:1.23.3 as builder

# Set the working directory
WORKDIR /app

COPY . .

# Build the Go application
RUN go build -o server .

# Use a minimal base image for the final container
FROM ubuntu:latest

# Copy the built binary from the builder
COPY --from=builder /app/server /server

# Expose the port the application will run on
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["./server"]
