// =============================================================================
// Master Resume — Ghazi Alchammat
// NEVER edit this file directly for tailoring runs.
// The pipeline creates a working copy in .resumes/<company>_<role>/tailored.typ
// =============================================================================
#import "@preview/basic-resume:0.2.9": *

#show: resume.with(
  author: "Ghazi Alchammat",
  location: "Calgary, Alberta",
  email: "alchammatg@gmail.com",
  github: "github.com/galchammat",
  phone: "(778) 682-5526",
  accent-color: "#26428b",
  font: "New Computer Modern",
  paper: "us-letter",
)

== Summary

Software Engineer with 6+ years building full-stack platforms and distributed systems, turning ideas into production with a focus on resilience, scalability, and cost efficiency.

== Work Experience

#work(
  title: "Senior Platform Engineer",
  company: "Rihal",
  location: "Calgary, AB (Remote)",
  dates: dates-helper(start-date: "Apr 2025", end-date: "Present"),
)
- Built a centralized data lakehouse consolidating 600+ government and private datasets to support national-level audit initiatives, and built a full-stack observability platform (Go, S3, PostgreSQL, Vite) exposing ingestion metrics and file metadata for audit traceability and compliance monitoring.
- Built a full-stack observability platform, developing a Vite-based UI and Go REST APIs to expose metrics and file metadata across the centralized data platform.
- Standardized Kubernetes-based CI/CD workflows across distributed data engineering projects, improving release reliability and reducing operational risk.

#work(
  title: "Developer (Contractor)",
  company: "Mekar Srl",
  location: "Calgary, AB (Remote)",
  dates: dates-helper(start-date: "Oct 2024", end-date: "Apr 2025"),
)
- Replaced manual spreadsheet-driven workflows with automated backend ingestion services, reducing reporting turnaround from days to same-day delivery.
- Designed and implemented a retrieval-augmented support system, exposing backend APIs to automate product inquiries and reduce customer response time by 80%.

#work(
  title: "Systems Engineer",
  company: "Hifi Engineering Inc.",
  location: "Calgary, AB",
  dates: dates-helper(start-date: "Jan 2020", end-date: "Oct 2024"),
)
- Optimized AWS infrastructure, reducing annual spend by 82% (~\$192k) while maintaining performance and deployment reliability.
- Built and scaled a distributed ML platform across 100+ servers, defining service APIs and a web-based control plane that increased training throughput and reduced deployment time from hours to minutes.
- Established CI/CD and infrastructure-as-code (Terraform) standards, introducing observability practices that reduced production incidents and increased deployment frequency.

== Education

#edu(
  institution: "University of British Columbia",
  location: "Vancouver, BC",
  dates: dates-helper(start-date: "Aug 2014", end-date: "Apr 2019"),
  degree: "Bachelor of Applied Science, Electrical & Computer Engineering",
)

== Skills

- *Languages:* Go, TypeScript, Python, Bash, Lua
- *Infrastructure & Cloud:* AWS Serverless, Terraform, IAM, Ansible, CI/CD, Ubuntu
- *Databases:* SQL, MongoDB, Redis, Timestream, DynamoDB
- *Full-Stack:* React, REST, GraphQL, OpenAPI
