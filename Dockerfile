FROM postgres:15-alpine

# Set default database environment credentials inside the image
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgrespassword
ENV POSTGRES_DB=jobready_db

# Auto-execute schema initialization script on first container startup
COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
