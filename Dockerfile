# Use multi-stage build for efficiency

FROM rocker/r-ver:4.1.0 as builder


# Install system dependencies

RUN apt-get update && apt-get install -y \

    libcurl4-openssl-dev \

    libssl-dev \

    libxml2-dev \

    pandoc \

    texlive-latex-base \

    texlive-fonts-recommended \

    texlive-latex-extra \

    && rm -rf /var/lib/apt/lists/*


# Install renv and restore packages

COPY renv.lock renv/activate.R /tmp/

RUN R -e "install.packages('renv')" \

    && R -e "renv::restore(lockfile = '/tmp/renv.lock')"


# Copy only necessary files for build stage

COPY reporting/fda_style_report.Rmd .

COPY modeling/ /app/modeling/

COPY data/ /app/data/


# Precompile report to reduce startup time

RUN Rscript -e "rmarkdown::render('fda_style_report.Rmd', output_file='/tmp/precompiled_report.html')"


# Final lightweight image

FROM rocker/r-ver:4.1.0


# Minimal runtime dependencies

RUN apt-get update && apt-get install -y \

    libcurl4-openssl-dev \

    libssl-dev \

    libxml2-dev \

    && rm -rf /var/lib/apt/lists/*


# Copy from builder stage

COPY --from=builder /usr/local/lib/R/site-library/ /usr/local/lib/R/site-library/

COPY --from=builder /tmp/precompiled_report.html /app/report/final_report.html

COPY --from=builder /app/modeling/ /app/modeling/

COPY --from=builder /app/data/ /app/data/


# Copy API files if exists

COPY api/api.R /app/api/


WORKDIR /app


# Metadata

LABEL maintainer="your-team@email.com"

LABEL version="1.0"

LABEL description="Bayesian Clinical Trial Analysis System"


# Expose ports (API on 8000, Shiny on 3838 if applicable)

EXPOSE 8000


# Health check

HEALTHCHECK --interval=30s --timeout=3s \

  CMD Rscript -e "httr::GET('http://localhost:8000/health')" || exit 1


# Flexible startup command

CMD ["Rscript", "reporting/fda_style_report.Rmd"]