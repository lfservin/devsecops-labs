docker run -d -p 8080:8080 -v dependency-track:/data owasp/dependency-track
cyclonedx-bom -o bom.xml