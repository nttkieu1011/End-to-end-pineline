# End-to-End-Pipeline

## I.Overview

An end-to-end data project that explores the complete data workflow, from collecting raw business data to transforming it into structured, analysis-ready datasets for business reporting.

**Key Objectives**
- Collect data from Google Drive using Python and Google Service Account authentication.
- Process and integrate multiple CSV and XLSX files.
- Clean, transform, and validate data using SQL.
- Build a structured data warehouse following the Medallion Architecture (Bronze, Silver, Gold).
- Prepare data for business analysis and reporting.

**Processing**

**Project Architecture** 

The project follows the Medallion Architecture to organize data processing into three layers:

- **Bronze:** Stores raw data ingested from multiple sources.
- **Silver:** Cleans, standardizes, and transforms raw data using SQL, with data quality checks.
- **Gold:** Builds analytical data models using SQL Views, including Dimension, Fact, and Mart views to support business analysis and reporting.

Python handles data ingestion, while SQL is used for data transformation, validation, and data warehouse development.

## II. Tech Stack

![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat&logo=databricks&logoColor=white)
![Google Drive API](https://img.shields.io/badge/Google_Drive_API-4285F4?style=flat&logo=googledrive&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=flat&logo=visualstudiocode&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-333333?style=flat&logo=github&logoColor=white)

| Technology | Purpose |
|---|---|
| Python | Data ingestion and file processing |
| SQL | Data transformation, modeling, and quality testing |
| PostgreSQL | Data storage and data warehouse |
| Google Drive API | Accessing and retrieving source files |
| Visual Studio Code | Development environment |
| Git & GitHub | Version control and project management |

## III. Project Structure

```text
Structure/
│
├── 01_ingestion/
│   ├── connectors/       # Google Drive connection
│   ├── loaders/          # Data loading scripts
│   └── utils/            # File parsing and database utilities
│
├── 02_sql_analytics/
│   ├── raw/              # Bronze layer SQL scripts
│   ├── stg/              # Silver layer SQL scripts and data quality tests
│   └── gold/
│       ├── dim/          # Dimension views
│       ├── fact/         # Fact views
│       └── mart/         # Analytical mart views
│
└── .gitignore
```
