# PAN Number Validation Project

A project that demonstrates **data validation in SQL** by checking the correctness of **PAN (Permanent Account Number) formats** using a sample dataset.

This project showcases SQL skills such as **pattern matching, constraints, and data quality checks**.

---

## 📌 Project Overview
- **Goal**: The goal is to ensure that each PAN 
number adheres to the official format and is categorized as either Valid or Invalid. 
- **Technology Used**: SQL (PostgreSQL RDBMS).
- **Dataset**: A sample dataset of PAN card entries (valid & invalid). (The dataset is given in a separate Excel file.)
- **PAN Validation Requirements and Constrains**: [PAN Card Validation Requirements and Problem Statements (PDF)](https://github.com/ankusnayak/pan-card-validation-sql/blob/main/problem_statement/PAN%20Number%20Validation%20-%20Problem%20Statement.pdf)

---

## 🛠️ How to Run

1. **Clone this repository**  
   ```bash
   git clone https://github.com/ankusnayak/pan-card-validation-sql.git
   cd pan-card-validation-sql

2. Open your SQL client (PostgreSQL).
3. Import sample data (csv file) into the table.
4. Run the SQL script `pan-number-validation-project.sql`.
5. Query the results from the validation logic.