// Authentication utility functions for managing auth state in localStorage

export const setAuthToken = (token: string) => {
    localStorage.setItem('session_id', token);
};

export const getAuthToken = (): string | null => {
    return localStorage.getItem('session_id');
};

export const removeAuthToken = () => {
    localStorage.removeItem('session_id');
};

export const getUserId = (): number => {
    return parseInt(localStorage.getItem('user_id') || '0');
};

export const setUserId = (userId: number) => {
    localStorage.setItem('user_id', userId.toString());
};

export const getUserRoles = (): string[] => {
    const roles = localStorage.getItem('user_roles');
    return roles ? JSON.parse(roles) : [];
};

export const setUserRoles = (roles: string[]) => {
    localStorage.setItem('user_roles', JSON.stringify(roles));
};

export const removeUserRoles = () => {
    localStorage.removeItem('user_roles');
};

export const getUsername = (): string | null => {
    return localStorage.getItem('username');
};

export const setUsername = (username: string) => {
    localStorage.setItem('username', username);
};

export const removeUsername = () => {
    localStorage.removeItem('username');
};

export const getOracleCredentials = (): { username: string; password: string } | null => {
    const username = localStorage.getItem('oracle_username');
    const password = localStorage.getItem('oracle_password');

    if (username && password) {
        return { username, password };
    }
    return null;
};

export const setOracleCredentials = (username: string, password: string) => {
    localStorage.setItem('oracle_username', username);
    localStorage.setItem('oracle_password', password);
};

export const removeOracleCredentials = () => {
    localStorage.removeItem('oracle_username');
    localStorage.removeItem('oracle_password');
};

export const clearAuthData = () => {
    removeAuthToken();
    removeUserRoles();
    removeUsername();
    removeOracleCredentials();
    localStorage.removeItem('user_id');
};

// Role checking utilities
export const hasRole = (role: string): boolean => {
    const userRoles = getUserRoles();
    return userRoles.some(r => r.toUpperCase().includes(role.toUpperCase()));
};

export const isAdmin = (): boolean => {
    const userRoles = getUserRoles();
    return userRoles.some(role =>
        role.includes('ROLE_SYS_ADMIN') || role.includes('ROLE_DIRECTOR')
    );
};

export const isStaff = (): boolean => {
    const userRoles = getUserRoles();
    return userRoles.some(role =>
        role.includes('ROLE_IT_SUPPORT') ||
        role.includes('ROLE_CIRCULATION_CLERK') ||
        role.includes('ROLE_CATALOGER')
    );
};

export const isPatron = (): boolean => {
    return hasRole('ROLE_PATRON');
};
