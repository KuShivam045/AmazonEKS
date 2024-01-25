# Base image
FROM ubuntu

# Install dependencies
RUN apt-get update && \
    apt-get install -y bash fortune-mod cowsay dos2unix

# WORKDIR
WORKDIR /wisecow

# Copy files
COPY . /wisecow/

# Convert line endings
RUN dos2unix /wisecow/wisecow/wisecow.sh

# Expose port
EXPOSE 4499

# Start the shell script
CMD ["/wisecow/wisecow/wisecow.sh"]
