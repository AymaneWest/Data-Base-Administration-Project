import axios from 'axios';
import { getAuthToken } from '../utils/auth';

const API_BASE_URL = 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = getAuthToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth APIs
export const login = (username: string, password: string) =>
  api.post('/auth/login', { username, password });

export const logout = (session_id: string) =>
  api.post('/auth/logout', { session_id });

// Patron APIs
export const renewMembership = (patron_id: number) =>
  api.post('/patrons/renew-membership', { patron_id });

export const suspendPatron = (patron_id: number, reason: string, staff_id: number) =>
  api.post('/patrons/suspend', { patron_id, reason, staff_id });

export const reactivatePatron = (patron_id: number, staff_id: number) =>
  api.post('/patrons/reactivate', { patron_id, staff_id });

// Material APIs
export const addCopy = (data: any) =>
  api.post('/materials/add-copy', data);

export const updateMaterial = (data: any) =>
  api.put('/materials/update', data);

export const deleteMaterial = (material_id: number, staff_id: number) =>
  api.delete('/materials/delete', { data: { material_id, staff_id } });

// Circulation APIs
export const declareItemLost = (data: any) =>
  api.post('/circulation/declare-item-lost', data);

// Utility APIs
export const checkPatronExists = (patron_id: number) =>
  api.post('/utility/patron-exists', { patron_id });

export const calculateLoanPeriod = (membership_type: string) =>
  api.post('/utility/calculate-loan-period', { membership_type });

export const calculateBorrowLimit = (membership_type: string) =>
  api.post('/utility/calculate-borrow-limit', { membership_type });

export const getActiveLoanCount = (patron_id: number) =>
  api.post('/utility/active-loan-count', { patron_id });

export const calculateFine = (due_date: string, return_date?: string) =>
  api.post('/utility/calculate-fine', { due_date, return_date });

export const checkEligibility = (patron_id: number) =>
  api.post('/utility/check-eligibility', { patron_id });

export default api;

// ... (previous code remains)

// Library Management APIs
export const addPatron = (data: any) =>
  api.post('/library/patrons', data);

export const updatePatron = (patronId: number, data: any) =>
  api.put(`/library/patrons/${patronId}`, data);

export const checkoutItem = (data: any) =>
  api.post('/library/checkout', data);

export const checkinItem = (data: any) =>
  api.post('/library/checkin', data);

export const renewLoan = (loan_id: number) =>
  api.post('/library/renew-loan', { loan_id });

export const addMaterial = (data: any) =>
  api.post('/library/materials', data);

export const payFine = (data: any) =>
  api.post('/library/fines/pay', data);

export const getPatronStatistics = (patronId: number) =>
  api.get(`/library/patrons/${patronId}/statistics`);

// Fine Management APIs
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

// Statistics APIs
export const getDashboardStats = () =>
  api.get('/statistics/dashboard');

export const getPatronDetails = (patronId: number) =>
  api.get(`/statistics/patrons/${patronId}/details`);

export const getExpiringLoans = (daysAhead: number, branchId?: number) =>
  api.get('/statistics/loans/expiring', { params: { days_ahead: daysAhead, branch_id: branchId } });

export const getFinesReport = (statusFilter: string, branchId?: number, dateFrom?: string, dateTo?: string) =>
  api.get('/statistics/fines/report', { params: { status_filter: statusFilter, branch_id: branchId, date_from: dateFrom, date_to: dateTo } });

export const getPopularMaterials = (topN: number, materialType?: string, periodDays?: number) =>
  api.get('/statistics/materials/popular', { params: { top_n: topN, material_type: materialType, period_days: periodDays } });

export const getBranchPerformance = (dateFrom?: string, dateTo?: string) =>
  api.get('/statistics/branches/performance', { params: { date_from: dateFrom, date_to: dateTo } });
