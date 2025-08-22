Data Catalog ue

### `gold.dim_customer`

| Column Name      | Data Type | Description                                                                    | Example                    |
| ---------------- | --------- | ------------------------------------------------------------------------------ | -------------------------- |
| customer\_key    | INT       | Surrogate primary key for the customer dimension (generated via `ROW_NUMBER`). | `1`                        |
| customer\_id     | NVARCHAR  | Business key from CRM source (`cst_id`).                                       | `CST10045`                 |
| customer\_number | NVARCHAR  | Alternate customer identifier from ERP (`cst_key`).                            | `101004`                   |
| first\_name      | NVARCHAR  | Customer’s first name.                                                         | `John`                     |
| last\_name       | NVARCHAR  | Customer’s last name.                                                          | `Doe`                      |
| marital\_status  | NVARCHAR  | Customer’s marital status (standardized, full text or `n/a`).                  | `Single`, `Married`, `n/a` |
| gender           | NVARCHAR  | Customer gender (standardized, full text or `n/a`).                            | `Male`, `Female`, `n/a`    |
| country          | NVARCHAR  | Country of residence (standardized).                                           | `United States`, `Germany` |
| birth\_date      | DATE      | Customer’s date of birth.                                                      | `1985-04-12`               |
| create\_date     | DATE      | Date the customer record was created.                                          | `2020-06-15`               |

---

### `gold.dim_product`

| Column Name                | Data Type | Description                                                                   | Example          |
| -------------------------- | --------- | ----------------------------------------------------------------------------- | ---------------- |
| product\_key               | INT       | Surrogate primary key for the product dimension (generated via `ROW_NUMBER`). | `101`            |
| product\_id                | NVARCHAR  | Business key from CRM source (`prd_id`).                                      | `PRD1001`        |
| product\_number            | NVARCHAR  | Alternate product identifier (`prd_key`).                                     | `P-202`          |
| product\_name              | NVARCHAR  | Name of the product.                                                          | `Wireless Mouse` |
| category\_id               | NVARCHAR  | Identifier linking product to ERP category.                                   | `CAT-10`         |
| category                   | NVARCHAR  | Product category (standardized).                                              | `Electronics`    |
| subcategory                | NVARCHAR  | Product subcategory (standardized).                                           | `Accessories`    |
| product\_line              | NVARCHAR  | Product line grouping.                                                        | `Consumer Goods` |
| maintenance                | NVARCHAR  | Maintenance classification from ERP.                                          | `Standard`       |
| product\_cost              | INT       | Unit cost of the product (whole numbers only).                                | `25`             |
| product\_cost\_start\_date | DATE      | Effective start date of product cost record.                                  | `2022-01-01`     |

---

### `gold.fact_sales`

| Column Name    | Data Type | Description                                                     | Example      |
| -------------- | --------- | --------------------------------------------------------------- | ------------ |
| order\_number  | NVARCHAR  | Business key of the sales order (`sls_ord_num`).                | `SO-78945`   |
| product\_key   | INT       | Foreign key referencing `dim_product.product_key`.              | `101`        |
| customer\_key  | INT       | Foreign key referencing `dim_customer.customer_key`.            | `1`          |
| order\_date    | DATE      | Date of order placement.                                        | `2023-08-05` |
| shipping\_date | DATE      | Date the order was shipped.                                     | `2023-08-06` |
| due\_date      | DATE      | Expected due date of the order.                                 | `2023-08-10` |
| unit\_price    | INT       | Unit price of the product at time of sale (whole numbers only). | `30`         |
| quantity       | INT       | Quantity of items sold.                                         | `3`          |
| sales\_amount  | INT       | Total sales amount (`unit_price * quantity`).                   | `90`         |

---
