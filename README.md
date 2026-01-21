# Retail Growth & Customer Intelligence Engine (Olist E-Commerce)

![Dashboard Preview](Power%20BI%20Dashboard/Dashboard.png)

## 📌 Executive Summary
Analyzed **100k+ real-world orders** from the Brazilian Olist E-Commerce dataset to identify logistical inefficiencies, customer churn patterns, and revenue opportunities.

This project transforms raw relational data into a **strategic business roadmap**, focusing on supply chain optimization and customer segmentation.

* **Role:** Data Analyst / Engineer
* **Tools Used:** SQL (BigQuery, Power Quer), Power BI (DAX), Excel.
* **Key Techniques:** CTEs, Window Functions, Set Operators (`EXCEPT`/`UNION`),etc.

---
## SQL Concepts Used
- Joins
- CTEs
- Window Functions
- Set Operators (UNION, INTERSECT, EXCEPT), etc.


## 📊 Key Insights & Business Proposals

### 1. Logistics Optimization (The "Supply Gap")
* **Finding:** Identified **3,779 unique locations** (City/State pairs) where customer demand exists but local sellers are completely absent.
* **Reasoning:** These customers currently rely on long-distance shipping from other states, increasing freight costs and delivery times.
* **Proposal:** Launch a **Targeted Seller Acquisition Campaign** in these specific 3,779 municipalities. Recruiting local vendors here will reduce shipping costs by an estimated **15%** and improve delivery speed.
* **Method:** Used SQL `EXCEPT` set operators to compare `Customer Locations` vs. `Seller Locations`.

### 2. Strategic "Same-Day Delivery" Hubs
* **Finding:** Pinpointed **531 "Golden Cities"** (e.g., São Paulo, Rio) where high density of both Buyers and Sellers overlaps.
* **Reasoning:** Since the product and the customer are in the same city, shipping distance is effectively zero.
* **Proposal:** Pilot a **"Same-Day Delivery"** filter for users in these 531 hubs. This premium service can significantly boost conversion rates and customer satisfaction.
* **Method:** Used SQL `INTERSECT` operator to find the overlap between Supply and Demand.

### 3. VIP Customer Segmentation
* **Finding:** Unified disparate Customer and Seller tables to identify the "Top 40" highest-value users across the platform.
* **Reasoning:** High-value users (both buyers and sellers) drive the majority of platform revenue but were previously siloed in different database tables.
* **Proposal:** Create a consolidated **"Olist VIP Program"** to offer exclusive perks to these top 40 users, increasing retention.
* **Method:** Used SQL `UNION` to stack and rank different user types by total value.

---

## 📂 Project Structure
The repository is organized as follows:

| Folder | Description |
| :--- | :--- |
| **/SQL Query** | Contains all .sql queries used for the analysis (RFM, Logistics, Trends). |
| **/Dashboard** | Screenshot of the interactive Power BI dashboard. |
| **/Data** | Full input dataset link provided. |

---

## 💻 SQL Code Highlight
Here is the sample snippet of logic used to identify the **"Supply Gaps"** (Cities with Demand but No Supply):

```sql
/* Query: Identify cities suitable for targeted seller acquisition
   Logic: Find cities present in the Customers table but missing from Sellers table
*/

WITH Supply_Gap AS (
    SELECT customer_city, customer_state 
    FROM customers
    EXCEPT DISTINCT
    SELECT seller_city, seller_state 
    FROM sellers
)
SELECT * FROM Supply_Gap
ORDER BY customer_state, customer_city;




