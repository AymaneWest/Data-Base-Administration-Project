# Data-Base-Administration-Project
#  Oracle Database Administration Project 

This project is part of the **Database Administration module**.  
It aims to design and implement an Oracle Database system that covers:
- User and role management
- Privileges and security
- PL/SQL programming (procedures, functions, triggers)
- Transaction control and error handling

---

## 👥 Team Members and Responsibilities

| Member | Role | Responsibilities |
|--------|------|------------------|
| Student 1 | User & Role Management | Create users, roles, privileges, security policies |
| Student 2 | Database Design | Create tables, relations, keys, constraints |
| Student 3 | PL/SQL Procedures & Functions | Automate operations and data management |
| Student 4 | Triggers & Transactions | Implement triggers, error handling, COMMIT/ROLLBACK logic |

---

## 🗂 Folder Structure
```bash
Database-Administration-Project/
│
├── docs/ → Reports and presentation
├── scripts/ → SQL scripts (creation, privileges, inserts)
├── plsql/ → Procedures, functions, triggers
├── design/ → Diagrams and schema models
├── tests/ → Test scripts
├── team/ → Each member’s individual work
├── backups/ → Dump files or export scripts
└── README.md
```

---

## 📜 Naming Rules for Files

| Type | Example |
|------|----------|
| User creation script | `01_create_users_roles.sql` |
| Privilege assignment | `02_grant_privileges.sql` |
| Table creation | `03_create_tables.sql` |
| PL/SQL procedures | `06_procedures_functions.sql` |
| Triggers | `07_triggers.sql` |
| Tests | `test_procedures.sql` |

✅ Always start files with a **two-digit number** to indicate execution order.  
✅ Use **snake_case** (`lowercase_with_underscores`).  
✅ End each file with a `/` to compile PL/SQL blocks correctly.

---

## ⚙️ SQL Coding Rules

1. Always write SQL keywords in **UPPERCASE** (e.g., `CREATE`, `SELECT`, `GRANT`).
2. Add **comments** using `--` before each logical block.
3. Test each script individually before pushing it.
4. Always handle exceptions in PL/SQL.
5. Use `COMMIT` only when all operations are verified.

---

## 🧠 Git Collaboration Rules

1. Each member works in their **own branch**:  
   - `Ilyass-roles`  
   - `Aymane-design`  
   - `Abdellah-procedures`  
   - `Mouad-triggers`
2. Commit messages must be clear:  
   - ✅ `Add trigger to prevent deleting paid invoices`  
   - ❌ `update file`
3. Merge to `main` only after **team validation**.
4. Never push `.dmp` or `.log` files.

---
---

## 🔒 Important Notes

- Do **not modify** other members’ scripts without discussing it first.
- Keep code clean and consistent.
- Respect Oracle naming conventions and avoid reserved words.

---
