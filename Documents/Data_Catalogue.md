# 📊 Data Catalogue

This document provides a comprehensive overview of the tables in the Gold layer, including column names, data types, descriptions, and example values. It serves as a reference for analysts, developers, and stakeholders to understand the structure and content of each table.


### `gold.dim_customer`

| Column Name      | Data Type | Description                                                                    | Example                    |
| ---------------- | --------- | ------------------------------------------------------------------------------ | -------------------------- |
| customer\_key    | INT       | Surrogate primary key for the customer dimension (generated via `ROW_NUMBER`). | `1`                        |
| customer\_id     | NVARCHAR  | Business key from CRM source (`cst_id`).                                       | `10045`                    |
| customer\_number | NVARCHAR  | Alternate customer identifier from ERP (`cst_key`).                            | `AW00011000`               |
| first\_name      | NVARCHAR  | Customer’s first name.                                                         | `John`                     |
| last\_name       | NVARCHAR  | Customer’s last name.                                                          | `Doe`                      |
| marital\_status  | NVARCHAR  | Customer’s marital status (standardized, full text or `n/a`).                  | `Single`, `Married`, `n/a` |
| gender           | NVARCHAR  | Customer gender (standardized, full text or `n/a`).                            | `Male`, `Female`, `n/a`    |
| country          | NVARCHAR  | Country of residence (standardized).                                           | `United States`            |
| birth\_date      | DATE      | Customer’s date of birth.                                                      | `1985-04-12`               |
| create\_date     | DATE      | Date the customer record was created.                                          | `2020-06-15`               |

---

### `gold.dim_product`

| Column Name                | Data Type | Description                                                                   | Example          |
| -------------------------- | --------- | ----------------------------------------------------------------------------- | ---------------- |
| product\_key               | INT       | Surrogate primary key for the product dimension (generated via `ROW_NUMBER`). | `11`             |
| product\_id                | NVARCHAR  | Business key from CRM source (`prd_id`).                                      | `200`            |
| product\_number            | NVARCHAR  | Alternate product identifier (`prd_key`).                                     | `FR-R92R-58`     |
| product\_name              | NVARCHAR  | Name of the product.                                                          | `Road-15 Red-5`  |
| category\_id               | NVARCHAR  | Identifier linking product to ERP category.                                   | `CL-SO`          |
| category                   | NVARCHAR  | Product category (standardized).                                              | `Clothing`       |
| subcategory                | NVARCHAR  | Product subcategory (standardized).                                           | `Socks`          |
| product\_line              | NVARCHAR  | Product line grouping.                                                        | `Mountain`       |
| maintenance                | NVARCHAR  | Maintenance classification from ERP.                                          | `Yes`, `No`      |
| product\_cost              | INT       | Unit cost of the product (whole numbers only).                                | `25`             |
| product\_cost\_start\_date | DATE      | Effective start date of product cost record.                                  | `2022-01-01`     |

---

### `gold.fact_sales`

| Column Name    | Data Type | Description                                                     | Example      |
| -------------- | --------- | --------------------------------------------------------------- | ------------ |
| order\_number  | NVARCHAR  | Business key of the sales order (`sls_ord_num`).                | `SO78945`    |
| product\_key   | INT       | Foreign key referencing `dim_product.product_key`.              | `14`         |
| customer\_key  | INT       | Foreign key referencing `dim_customer.customer_key`.            | `1781`       |
| order\_date    | DATE      | Date of order placement.                                        | `2023-08-05` |
| shipping\_date | DATE      | Date the order was shipped.                                     | `2023-08-06` |
| due\_date      | DATE      | Expected due date of the order.                                 | `2023-08-10` |
| unit\_price    | INT       | Unit price of the product at time of sale (whole numbers only). | `30`         |
| quantity       | INT       | Quantity of items sold.                                         | `3`          |
| sales\_amount  | INT       | Total sales amount (`unit_price * quantity`).                   | `90`         |

---
