// Type definitions for authentication and user management

export type BackendRole =
    | 'ROLE_SYS_ADMIN'
    | 'ROLE_DIRECTOR'
    | 'ROLE_IT_SUPPORT'
    | 'ROLE_CATALOGER'
    | 'ROLE_CIRCULATION_CLERK'
    | 'ROLE_PATRON';

export interface LoginResponse {
    success: boolean;
    message: string;
    session_id: string;
    user_id: number;
    oracle_username: string;
    oracle_password: string;
    roles: string;  // Comma-separated string
    patron_id?: number;
}

export interface LogoutResponse {
    success: boolean;
    message: string;
}

export interface SessionValidationResponse {
    success: boolean;
    message: string;
    is_valid: boolean;
    user_id?: number;
}

export interface User {
    id: number;
    username: string;
    roles: BackendRole[];
    oracleUsername?: string;
    oraclePassword?: string;
}

export interface ApiError {
    detail: string;
    status?: number;
}
