import axios, { AxiosError } from 'axios';
import { getAuthToken } from './auth-utils';
import type { LoginResponse, LogoutResponse, SessionValidationResponse } from './types';

const API_BASE_URL = 'http://localhost:8000';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Add auth token to requests
api.interceptors.request.use((config: any) => {
    const token = getAuthToken();
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Add response interceptor for error handling
api.interceptors.response.use(
    (response: any) => response,
    (error: AxiosError) => {
        if (error.response?.status === 401) {
            // Session expired or invalid - could redirect to login
            console.error('Authentication failed:', error);
        }
        return Promise.reject(error);
    }
);

// Auth APIs
export const login = (username: string, password: string) =>
    api.post<LoginResponse>('/auth/login', { username, password });

export const logout = (session_id: string) =>
    api.post<LogoutResponse>('/auth/logout', { session_id });

export const validateSession = (session_id: string) =>
    api.post<SessionValidationResponse>('/auth/validate-session', { session_id });

// User Management APIs
export const getUserStatus = (userId: number) =>
    api.get(`/users/${userId}/status`);

export const getUserRoles = (userId: number) =>
    api.get(`/users/${userId}/roles`);

export const checkPermission = (data: any) =>
    api.post('/users/check-permission', data);

export const checkRole = (data: any) =>
    api.post('/users/check-role', data);

export const assignRole = (data: any) =>
    api.post('/users/assign-role', data);

export const revokeRole = (data: any) =>
    api.post('/users/revoke-role', data);

// Statistics APIs (for dashboards)
export const getDashboardStats = () =>
    api.get('/statistics/dashboard');

export const getDashboardOverview = () =>
    api.get('/dashboard/stats');

export const getMonthlyActivity = () =>
    api.get('/dashboard/activity');

export const getRecentActivity = () =>
    api.get('/dashboard/recent-activity');

export const getDashboardAlerts = () =>
    api.get('/dashboard/alerts');

// Material APIs
export const browseMaterials = (filters?: {
  search?: string;
  genre?: string;
  material_type?: string;
  availability?: string;
  sort_by?: string;
}) =>
    api.get('/materials/browse', { params: filters });

export const getSearchSuggestions = (query: string, limit: number = 10) =>
    api.get('/materials/search/suggestions', { params: { q: query, limit } });

export const getGenres = () =>
    api.get('/materials/genres');

export const getMaterialDetail = (materialId: number) =>
    api.get(`/materials/${materialId}`);

export const addMaterial = (data: any) =>
    api.post('/library/materials', data);

export const updateMaterial = (data: any) =>
    api.put('/materials/update', data);

export const deleteMaterial = (material_id: number, staff_id: number) =>
    api.delete('/materials/delete', { data: { material_id, staff_id } });

// Patron APIs
export const searchPatrons = (searchTerm: string) =>
    api.get('/patrons/search', { params: { search_term: searchTerm } });

export const registerPatron = (data: any) =>
    api.post('/library/patrons', data);

export const renewMembership = (patron_id: number) =>
    api.post('/patrons/renew-membership', { patron_id });

export const suspendPatron = (patron_id: number, reason: string, staff_id: number) =>
    api.post('/patrons/suspend', { patron_id, reason, staff_id });

export const reactivatePatron = (patron_id: number, staff_id: number) =>
    api.post('/patrons/reactivate', { patron_id, staff_id });

// Circulation APIs - Updated to use material_route endpoints
export const checkoutItem = (data: any) =>
    api.post('/materials/checkout', data);

export const checkinItem = (data: any) =>
    api.post('/materials/return', data);

export const renewLoan = (loan_id: number) =>
    api.post('/library/renew-loan', { loan_id });

// Reservation APIs
export const getActiveReservations = (status?: string) =>
    api.get('/reservations/active', { params: status ? { status } : {} });

export const fulfillReservation = (reservation_id: number, copy_id: number, staff_id: number) =>
    api.post('/reservations/fulfill', { reservation_id, copy_id, staff_id });

export const cancelReservation = (reservation_id: number, patron_id: number) =>
    api.post('/reservations/cancel', { reservation_id, patron_id });

// Fine Management APIs
export const getAllFines = (status?: string) =>
    api.get('/fines/list', { params: status ? { status } : {} });

export const payFine = (data: any) =>
    api.post('/library/fines/pay', data);

export const waiveFine = (data: any) =>
    api.post('/fines/waive', data);

export const assessFine = (data: any) =>
    api.post('/fines/assess', data);

// Reporting APIs
export const getOverdueCount = (branch_id?: number) =>
    api.post('/reports/overdue-count', { branch_id });

export const getTotalFines = (patron_id?: number) =>
    api.post('/reports/total-fines', { patron_id });

export const checkMaterialAvailability = (material_id: number) =>
    api.post('/reports/material-availability', { material_id });

// Batch Operations APIs
export const processOverdueNotifications = () =>
    api.post('/batch/process-overdue', {});

export const expireMemberships = () =>
    api.post('/batch/expire-memberships', {});

export const cleanupReservations = () =>
    api.post('/batch/cleanup-reservations', {});

export const generateDailyReport = (branch_id?: number) =>
    api.post('/batch/daily-report', { branch_id });

// Branches APIs
export const getBranches = () =>
    api.get('/library/branches');

// Popular Materials APIs
export const getPopularMaterials = (topN: number = 10, materialType?: string, periodDays: number = 30) =>
    api.get('/statistics/materials/popular', { params: { top_n: topN, material_type: materialType, period_days: periodDays } });

// Public APIs (no auth required)
export const getPublicStats = () =>
    api.get('/public/stats');

// Patron APIs
export const getMyPatronDetails = () =>
    api.get('/statistics/patrons/me');

export const getPatronDetails = (patronId: number) =>
    api.get(`/statistics/patrons/${patronId}/details`);

export default api;

// Patron Statistics
export const getPatronStatistics = () => 
  api.get('/patrons/statistics');

export const getPatronOverview = () => 
  api.get('/patrons/statistics/overview');

export const getActiveLoans = () => 
  api.get('/patrons/statistics/active-loans');

export const getReservations = () => 
  api.get('/patrons/statistics/reservations');

export const getFines = () => 
  api.get('/patrons/statistics/fines');

// Material Details & Actions
export const getMaterialDetails = (materialId: string | number) =>
  api.get(`/materials/${materialId}/details`);

export const checkoutMaterial = (data: { 
  copy_id: number; 
  patron_id: number;
  staff_id?: number;
}) => api.post('/materials/checkout', data);

export const placeReservation = (data: { 
  material_id: number; 
  patron_id: number;
}) => api.post('/reservations/place', data);

export const returnMaterial = (data: {
  loan_id: number;
  staff_id: number;
}) => api.post('/materials/return', data);
