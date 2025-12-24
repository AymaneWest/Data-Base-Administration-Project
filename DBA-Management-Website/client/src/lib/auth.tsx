import { createContext, useContext, useState, ReactNode, useEffect } from 'react';
import { login as apiLogin, logout as apiLogout } from './api';
import {
  setAuthToken,
  setUserId,
  setUserRoles,
  setUsername,
  setOracleCredentials,
  clearAuthData,
  getUserId,
  getUserRoles,
  getUsername,
  getAuthToken,
  isAdmin,
  isStaff,
  isPatron
} from './auth-utils';
import type { BackendRole } from './types';

export type UserRole = BackendRole;

export interface User {
  id: number;
  username: string;
  roles: BackendRole[];
  oracleUsername?: string;
  oraclePassword?: string;
  patron_id?: number;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (username: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => Promise<void>;
  hasRole: (role: string) => boolean;
  isAdmin: () => boolean;
  isStaff: () => boolean;
  isPatron: () => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Initialize user from localStorage on mount
  useEffect(() => {
    const initializeAuth = () => {
      const token = getAuthToken();
      const userId = getUserId();
      const username = getUsername();
      const roles = getUserRoles();

      if (token && userId && username && roles.length > 0) {
        setUser({
          id: userId,
          username,
          roles: roles as BackendRole[],
        });
      }
      setIsLoading(false);
    };

    initializeAuth();
  }, []);

  const login = async (username: string, password: string): Promise<{ success: boolean; error?: string }> => {
    setIsLoading(true);
    try {
      const response = await apiLogin(username, password);
      const data = response.data;

      if (data.success) {
        // Store auth data in localStorage
        setAuthToken(data.session_id);
        setUserId(data.user_id);
        setUsername(username);

        // Parse roles string (format: "ROLE_SYS_ADMIN,ROLE_DIRECTOR")
        const rolesArray = data.roles
          .split(',')
          .map((r: string) => r.trim())
          .filter((r: string) => r.length > 0);

        setUserRoles(rolesArray);

        // Store Oracle credentials if needed
        if (data.oracle_username && data.oracle_password) {
          setOracleCredentials(data.oracle_username, data.oracle_password);
        }

        // Update user state
        setUser({
          id: data.user_id,
          username,
          roles: rolesArray as BackendRole[],
          oracleUsername: data.oracle_username,
          oraclePassword: data.oracle_password,
          patron_id: data.patron_id
        });

        setIsLoading(false);
        return { success: true };
      } else {
        setIsLoading(false);
        return { success: false, error: data.message || 'Login failed' };
      }
    } catch (err: any) {
      const errorMsg = err.response?.data?.detail || err.message || 'An error occurred during login';
      console.error('Login error:', err);
      setIsLoading(false);
      return { success: false, error: errorMsg };
    }
  };

  const logout = async () => {
    const sessionId = getAuthToken();
    if (sessionId) {
      try {
        await apiLogout(sessionId);
      } catch (err) {
        console.error('Logout error:', err);
      }
    }

    clearAuthData();
    setUser(null);
  };

  const hasRole = (role: string): boolean => {
    if (!user) return false;
    return user.roles.some((r: string) => r.toUpperCase().includes(role.toUpperCase()));
  };

  return (
    <AuthContext.Provider value={{
      user,
      isLoading,
      login,
      logout,
      hasRole,
      isAdmin,
      isStaff,
      isPatron
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}