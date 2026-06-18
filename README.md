# 🏗️ SQL Data Warehouse Project

A **SQL Server Data Warehouse** built using the **Medallion Architecture** (Bronze → Silver → Gold), integrating data from CRM and ERP source systems into a clean, business-ready **Star Schema** for analytics and reporting.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Star Schema (Gold Layer)](#-star-schema-gold-layer)
- [Project Structure](#-project-structure)
- [Data Sources](#-data-sources)
- [ETL Pipeline](#-etl-pipeline)
- [Setup & Installation](#-setup--installation)
- [Usage](#-usage)
- [Quality Checks](#-quality-checks)
- [Naming Conventions](#-naming-conventions)
- [Technologies Used](#-technologies-used)
- [License](#-license)

---

## 🎯 Project Overview

This project demonstrates a complete **end-to-end data warehouse** solution that:

1. **Ingests** raw CSV data from two source systems (CRM & ERP) into a Bronze layer
2. **Cleanses & transforms** the data in a Silver layer (deduplication, standardization, validation)
3. **Models** the data into a **Star Schema** in the Gold layer for analytical consumption

| Layer | Purpose | Objects | Pattern |
|-------|---------|---------|---------|
| 🥉 **Bronze** | Land raw data exactly as-is from CSV | 6 tables | `BULK INSERT` → tables |
| 🥈 **Silver** | Cleanse, standardize, deduplicate | 6 tables | `INSERT INTO … SELECT` with transforms |
| 🥇 **Gold** | Business-ready star schema | 3 views | `CREATE VIEW` joining silver tables |

---

## 🏛️ Architecture

```
          ┌──────────────┐
          │  CSV Files   │
          │  (CRM & ERP) │
          └──────┬───────┘
                 │  BULK INSERT
                 ▼
        ┌────────────────┐
        │  🥉 BRONZE     │
        │  (Raw Landing) │
        │  6 tables      │
        └────────┬───────┘
                 │  Cleanse & Transform
                 ▼
        ┌────────────────┐
        │  🥈 SILVER     │
        │  (Cleansed)    │
        │  6 tables      │
        └────────┬───────┘
                 │  Star Schema Views
                 ▼
        ┌────────────────┐
        │  🥇 GOLD       │
        │  (Business)    │
        │  3 views       │
        └────────┬───────┘
                 │
                 ▼
        ┌────────────────┐
        │  📊 Analytics  │
        │  & Reporting   │
        └────────────────┘
```

---

## ⭐ Star Schema (Gold Layer)

The Gold layer exposes three views forming a classic **Star Schema** design:

```
                ┌──────────────────┐
                │  dim_customers   │
                │──────────────────│
                │ customer_key (PK)│
                │ customer_id      │
                │ customer_number  │
                │ first_name       │
                │ last_name        │
                │ country          │
                │ marital_status   │
                │ gender           │
                │ birthdate        │
                │ create_date      │
                └────────┬─────────┘
                         │
                         │ customer_key
                         ▼
              ┌─────────────────────┐
              │    fact_sales       │
              │─────────────────────│
              │ order_number        │
              │ product_key    (FK) │◄──────┐
              │ customer_key   (FK) │       │
              │ order_date          │       │
              │ shipping_date       │       │
              │ due_date            │       │
              │ sales_amount        │       │
              │ quantity            │       │
              │ price               │       │
              └─────────────────────┘       │
                                            │ product_key
                                  ┌─────────┴──────────┐
                                  │   dim_products     │
                                  │────────────────────│
                                  │ product_key   (PK) │
                                  │ product_id         │
                                  │ product_number     │
                                  │ product_name       │
                                  │ category_id        │
                                  │ category           │
                                  │ subcategory        │
                                  │ maintenance        │
                                  │ cost               │
                                  │ product_line       │
                                  │ start_date         │
                                  └────────────────────┘
```

---

## 📁 Project Structure

```
SQL_Data_Warehouse_Project/
│
├── datasets/
│   ├── source_crm/              # CRM source CSV files
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/              # ERP source CSV files
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── docs/
│   ├── data_catalog.md          # Gold layer column descriptions
│   ├── naming_conventions.md    # Project naming standards
│   ├── data_architecture.png    # Architecture diagram
│   ├── data_flow.png            # Data flow diagram
│   ├── data_integration.png     # Integration diagram
│   ├── data_model.png           # Star schema diagram
│   └── ETL.png                  # ETL process diagram
│
├── scripts/
│   ├── init_database.sql        # Step 1: Create DB & schemas
│   ├── bronze/
│   │   ├── ddl_bronze.sql       # Step 2: Create bronze tables
│   │   └── proc_load_bronze.sql # Step 3: Bronze load procedure
│   ├── silver/
│   │   ├── ddl_silver.sql       # Step 5: Create silver tables
│   │   └── proc_load_silver.sql # Step 6: Silver load procedure
│   └── gold/
│       └── ddl_gold.sql         # Step 8: Create gold views
│
├── tests/
│   ├── quality_checks_silver.sql # Silver layer data validation
│   └── quality_checks_gold.sql   # Gold layer data validation
│
├── .gitignore
└── README.md
```

---

## 📊 Data Sources

### CRM System (3 files)

| File | Description | Key Columns |
|------|-------------|-------------|
| `cust_info.csv` | Customer master data | `cst_id`, `cst_key`, `cst_firstname`, `cst_lastname`, `cst_gndr`, `cst_marital_status` |
| `prd_info.csv` | Product catalog | `prd_id`, `prd_key`, `prd_nm`, `prd_cost`, `prd_line` |
| `sales_details.csv` | Sales transactions | `sls_ord_num`, `sls_prd_key`, `sls_cust_id`, `sls_sales`, `sls_quantity`, `sls_price` |

### ERP System (3 files)

| File | Description | Key Columns |
|------|-------------|-------------|
| `CUST_AZ12.csv` | Customer demographics | `cid`, `bdate`, `gen` |
| `LOC_A101.csv` | Customer locations | `cid`, `cntry` |
| `PX_CAT_G1V2.csv` | Product categories | `id`, `cat`, `subcat`, `maintenance` |

---

## 🔄 ETL Pipeline

### Bronze Layer — Raw Ingestion
- **Full refresh** pattern: `TRUNCATE` + `BULK INSERT` for each table
- No transformations — data is landed exactly as-is from CSV
- 6 tables: `bronze.crm_cust_info`, `bronze.crm_prd_info`, `bronze.crm_sales_details`, `bronze.erp_cust_az12`, `bronze.erp_loc_a101`, `bronze.erp_px_cat_g1v2`

### Silver Layer — Cleansing & Transformation

| Table | Key Transformations |
|-------|-------------------|
| `crm_cust_info` | Deduplication via `ROW_NUMBER()`, gender/marital status standardization, `TRIM()` on names |
| `crm_prd_info` | Composite key splitting (`prd_key` → `cat_id` + `prd_key`), product line mapping, `LEAD()` for end dates |
| `crm_sales_details` | INT → DATE conversion with validation, sales recalculation (`qty × price`), price derivation |
| `erp_cust_az12` | `NAS` prefix stripping from `cid`, future birthdate → `NULL`, gender standardization |
| `erp_loc_a101` | Dash removal from `cid`, country name normalization (`DE` → `Germany`, `US`/`USA` → `United States`) |
| `erp_px_cat_g1v2` | Direct copy (no transformation needed) |

### Gold Layer — Star Schema Views
- **`dim_customers`**: Joins CRM customer info + ERP demographics + ERP locations, with CRM-priority gender resolution
- **`dim_products`**: Joins CRM products + ERP categories, filtered to current products only (`prd_end_dt IS NULL`)
- **`fact_sales`**: Links sales transactions to dimension surrogate keys

### Join Key Map

| From Table | Join Column | → | To Table | Join Column |
|------------|-------------|---|----------|-------------|
| `silver.crm_cust_info` | `cst_key` | → | `silver.erp_cust_az12` | `cid` |
| `silver.crm_cust_info` | `cst_key` | → | `silver.erp_loc_a101` | `cid` |
| `silver.crm_prd_info` | `cat_id` | → | `silver.erp_px_cat_g1v2` | `id` |
| `silver.crm_sales_details` | `sls_prd_key` | → | `gold.dim_products` | `product_number` |
| `silver.crm_sales_details` | `sls_cust_id` | → | `gold.dim_customers` | `customer_id` |

---

## 🚀 Setup & Installation

### Prerequisites

- **SQL Server** (2016 or later)
- **SQL Server Management Studio (SSMS)** or any SQL client
- Windows OS (for `BULK INSERT` file paths)

### Installation Steps

> ⚠️ **Important**: Before running Step 3, update the file paths in `proc_load_bronze.sql` to match the location of your CSV files on disk.

```
Step 1  →  scripts/init_database.sql          (Create database & schemas)
Step 2  →  scripts/bronze/ddl_bronze.sql      (Create bronze tables)
Step 3  →  scripts/bronze/proc_load_bronze.sql (Create the bronze load procedure)
Step 4  →  EXEC bronze.load_bronze             (Execute — loads CSVs into bronze)
Step 5  →  scripts/silver/ddl_silver.sql       (Create silver tables)
Step 6  →  scripts/silver/proc_load_silver.sql (Create the silver load procedure)
Step 7  →  EXEC silver.load_silver             (Execute — transforms bronze → silver)
Step 8  →  scripts/gold/ddl_gold.sql           (Create gold star schema views)
Step 9  →  tests/quality_checks_silver.sql     (Validate silver layer)
Step 10 →  tests/quality_checks_gold.sql       (Validate gold layer)
```

---

## 💡 Usage

Once the warehouse is set up, query the Gold layer views directly for analytics:

```sql
-- Top 10 customers by total sales
SELECT TOP 10
    c.first_name,
    c.last_name,
    c.country,
    SUM(f.sales_amount) AS total_sales,
    COUNT(f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.first_name, c.last_name, c.country
ORDER BY total_sales DESC;

-- Sales by product category
SELECT
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category, p.subcategory
ORDER BY total_sales DESC;

-- Monthly sales trend
SELECT
    YEAR(f.order_date) AS order_year,
    MONTH(f.order_date) AS order_month,
    SUM(f.sales_amount) AS monthly_sales,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
GROUP BY YEAR(f.order_date), MONTH(f.order_date)
ORDER BY order_year, order_month;
```

---

## ✅ Quality Checks

### Silver Layer Checks (`tests/quality_checks_silver.sql`)
- ✔️ Primary key uniqueness & NULL detection
- ✔️ Unwanted leading/trailing spaces in string fields
- ✔️ Data standardization validation (gender, marital status, product line, country)
- ✔️ Date range and order validation
- ✔️ Sales consistency: `sales = quantity × price`

### Gold Layer Checks (`tests/quality_checks_gold.sql`)
- ✔️ Surrogate key uniqueness in `dim_customers` and `dim_products`
- ✔️ Referential integrity: all `fact_sales` rows link to valid dimension records

---

## 📝 Naming Conventions

| Scope | Pattern | Example |
|-------|---------|---------|
| **Bronze/Silver Tables** | `<source_system>_<entity>` | `crm_cust_info`, `erp_loc_a101` |
| **Gold Views** | `<category>_<entity>` | `dim_customers`, `fact_sales` |
| **Surrogate Keys** | `<table>_key` | `customer_key`, `product_key` |
| **Technical Columns** | `dwh_<column_name>` | `dwh_create_date` |
| **Stored Procedures** | `load_<layer>` | `load_bronze`, `load_silver` |

See [docs/naming_conventions.md](docs/naming_conventions.md) for full details.

---

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| **SQL Server** | Database engine |
| **T-SQL** | DDL, stored procedures, views, window functions |
| **SSMS** | SQL client & administration |
| **BULK INSERT** | CSV data ingestion |
| **Medallion Architecture** | Data layering pattern (Bronze → Silver → Gold) |
| **Star Schema** | Dimensional modeling (facts + dimensions) |

---

## 🌟 About Me

Hello, I'm **Salah Gueroui**, a Master's student in Computer Science passionate about **Data Analytics**, **Business Intelligence**, **Data Engineering**, and **Artificial Intelligence**.

This project demonstrates my ability to design and implement data warehouse solutions using SQL Server, including ETL pipelines, dimensional modeling, and data quality validation. I enjoy transforming raw data into valuable insights and exploring how AI can enhance decision-making and business intelligence.

I am continuously expanding my skills in data, analytics, and AI through hands-on projects and real-world challenges.

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/salahgueroui)

---

## 📄 License

This project is for educational and portfolio purposes.
