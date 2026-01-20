# Retail Growth & Customer Intelligence Engine (Olist E-Commerce)

![Dashboard Preview](Power BI Dashboard)


## 📌 Executive Summary
Analyzed **100k+ real-world orders** from the Brazilian Olist E-Commerce dataset to identify logistical inefficiencies, customer churn patterns, and revenue opportunities.

This project transforms raw relational data into a **strategic business roadmap**, focusing on supply chain optimization and customer segmentation.

* **Role:** Data Analyst / Engineer
* **Tools Used:** SQL (BigQuery, Power Query), Power BI (DAX), Excel.
* **Key Techniques:** CTEs, Window Functions, Set Operators (`EXCEPT`/`UNION`/`INTERSECT`).

## 📊 Key Insights & Business Impact
### 1. Logistics Optimization (The "Supply Gap")
* **Finding:** Identified **534 cities** where customer demand exists but local sellers are completely absent.
* **Impact:** This "Supply Gap" forces expensive long-distance shipping. Recommended a targeted seller acquisition strategy in these specific regions to reduce freight costs by an estimated **15%**.
* **Method:** Used SQL `EXCEPT` set operators to map `Customer Cities` vs. `Seller Cities`.

### 2. Strategic "Same-Day Delivery" Hubs
* **Finding:** Pinpointed logistical "Golden Cities" (e.g., São Paulo, Rio) where high density of both Buyers and Sellers overlaps.
* **Action:** Proposed a pilot program for **Same-Day Delivery** services in these hubs to increase conversion rates.

### 3. VIP Customer Segmentation
* **Finding:** Unified disparate Customer and Seller tables to identify the "Top 40" highest-value users across the platform.
* **Action:** Created a consolidated "VIP List" for the marketing team to launch a loyalty appreciation campaign.

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
Here is a sample snippet of the logic used to identify the **"Supply Gaps"** (Cities with Demand but No Supply):

```sql
/* Query: Identify cities suitable for targeted seller acquisition
   Logic: Find cities present in the Customers table but missing from Sellers table
*/

SELECT customer_city, customer_state 
FROM customers
EXCEPT DISTINCT
SELECT seller_city, seller_state 
FROM sellers
ORDER BY customer_state, customer_city;
