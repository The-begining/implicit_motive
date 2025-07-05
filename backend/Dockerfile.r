FROM r-base:latest

# Install system dependencies for plumber
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

# Set CRAN mirror (use the correct path)
RUN echo 'options(repos = c(CRAN = "https://cloud.r-project.org"))' >> /etc/R/Rprofile.site

# Install plumber and jsonlite
RUN R -e "install.packages(c('plumber', 'jsonlite'))"

WORKDIR /app
COPY r_server.R .

EXPOSE 8001

CMD ["R", "-e", "pr <- plumber::plumb('r_server.R'); pr$run(host='0.0.0.0', port=8001)"]