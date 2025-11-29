# Configuration.py
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Use the exact field names from your environment variables
    oracle_user: str
    oracle_password: str
    oracle_dsn: str = "localhost:1521/XE"  # Default value

    # OR if you have separate host, port, service:
    oracle_host: Optional[str] = "localhost"
    oracle_port: Optional[str] = "1521"
    oracle_service: Optional[str] = "XE"

    # Build DSN from components if needed
    @property
    def dsn(self) -> str:
        if hasattr(self, 'oracle_host') and self.oracle_host:
            return f"{self.oracle_host}:{self.oracle_port}/{self.oracle_service}"
        return self.oracle_dsn

    oracle_min_connections: int = 2
    oracle_max_connections: int = 5
    secret_key: str = "your-secret-key"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    class Config:
        env_file = ".env"
        extra = 'ignore'  # This allows extra fields without errors


settings = Settings()