from sqlalchemy import create_engine,text
import oracledb
import os
from dotenv import load_dotenv
load_dotenv()
connection_string=(
    f"oracle+oracledb://{os.getenv('ORACLE_USER')}:"
    f"{os.getenv('ORACLE_PASSWORD')}@"
    f"{os.getenv('ORACLE_HOST')}:{os.getenv('ORACLE_PORT')}/"
    f"?service_name={os.getenv('ORACLE_SERVICE')}"

)
# Try with a simpler approach - remove schema and use qualified table name
os.system(f'sqlacodegen "{connection_string}" --schema C##PROJET_DB --outfile models_01.py')
print("Models generated successfully in models.py")