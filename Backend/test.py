from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String, Date, Numeric, Text, text
from sqlalchemy.orm import declarative_base
import os
from dotenv import load_dotenv

load_dotenv()

connection_string = (
    f"oracle+oracledb://{os.getenv('ORACLE_USER')}:"
    f"{os.getenv('ORACLE_PASSWORD')}@"
    f"{os.getenv('ORACLE_HOST')}:{os.getenv('ORACLE_PORT')}/"
    f"?service_name={os.getenv('ORACLE_SERVICE')}"
)

engine = create_engine(connection_string)
Base = declarative_base()

def get_column_type(data_type):
    """Map Oracle data types to SQLAlchemy types"""
    type_map = {
        'NUMBER': Numeric,
        'VARCHAR2': String,
        'DATE': Date,
        'CHAR': String,
        'CLOB': Text,
        'BLOB': Text,
        'TIMESTAMP': Date,
        'FLOAT': Numeric
    }
    return type_map.get(data_type, String)

def generate_model_for_table(table_name):
    """Generate a SQLAlchemy model for a specific table"""
    with engine.connect() as conn:
        # Get column information
        result = conn.execute(text(f"""
            SELECT column_name, data_type, nullable, data_default, data_length, data_precision, data_scale
            FROM all_tab_columns 
            WHERE owner = 'SYSTEM' AND table_name = '{table_name}'
            ORDER BY column_id
        """))
        
        columns_info = []
        for row in result:
            columns_info.append({
                'name': row[0],
                'type': row[1],
                'nullable': row[2] == 'Y',
                'default': row[3],
                'data_length': row[4],
                'data_precision': row[5],
                'data_scale': row[6]
            })
        
        # Get primary key information
        result = conn.execute(text(f"""
            SELECT cols.column_name
            FROM all_constraints cons, all_cons_columns cols
            WHERE cons.constraint_type = 'P'
            AND cons.constraint_name = cols.constraint_name
            AND cons.owner = 'SYSTEM'
            AND cols.table_name = '{table_name}'
            ORDER BY cols.position
        """))
        
        primary_keys = [row[0] for row in result]
        
        return columns_info, primary_keys

def create_model_class(table_name, columns_info, primary_keys):
    """Create the model class code"""
    
    # Convert table name to class name (PascalCase)
    class_name = ''.join(word.title() for word in table_name.split('_'))
    
    class_code = f"""
class {class_name}(Base):
    __tablename__ = '{table_name}'
    __table_args__ = {{'schema': 'SYSTEM'}}
    
"""
    
    for col_info in columns_info:
        col_name = col_info['name'].lower()
        sqlalchemy_type = get_column_type(col_info['type'])
        
        # Handle primary key
        is_primary_key = col_info['name'] in primary_keys
        
        # Build column definition
        col_def = f"    {col_name} = Column({sqlalchemy_type.__name__}"
        
        # Add primary key
        if is_primary_key:
            col_def += ", primary_key=True"
        
        # Add nullable
        if not col_info['nullable'] and not is_primary_key:
            col_def += ", nullable=False"
        
        # Add length for string types
        if col_info['type'] in ['VARCHAR2', 'CHAR'] and col_info['data_length']:
            col_def += f", length={col_info['data_length']}"
        
        # Add precision and scale for NUMBER type
        if col_info['type'] == 'NUMBER' and col_info['data_precision']:
            if col_info['data_scale'] and col_info['data_scale'] > 0:
                col_def += f", precision={col_info['data_precision']}, scale={col_info['data_scale']}"
            else:
                col_def += f", precision={col_info['data_precision']}"
        
        col_def += ")"
        
        class_code += col_def + "\n"
    
    return class_code

# List of tables you want to generate models for

tables_to_generate = [
'FINES',
'MATERIAL_AUTHORS',
'MATERIAL_GENRES',
'USERS',
'ROLES',
'PERMISSIONS',
'USER_ROLES',
'ROLE_PERMISSIONS',
'AUDIT_LOG',
'PASSWORD_HISTORY',
'LOGIN_ATTEMPTS',
'LIBRARIES',
'BRANCHES',
'PATRONS',
'STAFF',
'PUBLISHERS',
'AUTHORS',
'GENRES',
'MATERIALS',
'COPIES',
'LOANS',
'RESERVATIONS',
'SESSION_MANAGEMENT'
]
# Generate the models file
with open('models.py', 'w') as f:
    f.write('''from sqlalchemy import Column, Integer, String, Date, Numeric, Text
from sqlalchemy.orm import declarative_base

Base = declarative_base()

''')
    
    successful_tables = []
    failed_tables = []
    
    for table_name in tables_to_generate:
        print(f"Generating model for {table_name}...")
        try:
            columns_info, primary_keys = generate_model_for_table(table_name)
            if columns_info:  # Only generate if we found columns
                model_code = create_model_class(table_name, columns_info, primary_keys)
                f.write(model_code)
                f.write('\n\n')
                successful_tables.append(table_name)
                print(f"✅ Successfully generated model for {table_name}")
            else:
                print(f"❌ No columns found for {table_name} - table might not exist")
                failed_tables.append(table_name)
        except Exception as e:
            print(f"❌ Failed to generate model for {table_name}: {e}")
            failed_tables.append(table_name)

print(f"\n=== GENERATION SUMMARY ===")
print(f"✅ Successful: {len(successful_tables)} tables")
print(f"❌ Failed: {len(failed_tables)} tables")

if successful_tables:
    print(f"Generated models for: {', '.join(successful_tables)}")

if failed_tables:
    print(f"Failed tables: {', '.join(failed_tables)}")
    print("\nTroubleshooting failed tables...")
    
    # Check which tables actually exist
    with engine.connect() as conn:
        for table in failed_tables:
            result = conn.execute(text(f"""
                SELECT COUNT(*) 
                FROM all_tables 
                WHERE owner = 'SYSTEM' AND table_name = '{table}'
            """))
            exists = result.scalar()
            if exists:
                print(f"  - {table}: EXISTS but failed to generate model")
            else:
                print(f"  - {table}: DOES NOT EXIST in SYSTEM schema")

print("\nModels generated in models.py!")