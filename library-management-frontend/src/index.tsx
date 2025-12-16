import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
// ... (previous types remain)

// Library Management Types
export interface AddPatronRequest {
  card_number: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  address: string;
  date_of_birth: string;
  membership_type: string;
  branch_id: number;
}

export interface CheckoutItemRequest {
  patron_id: number;
  copy_id: number;
  staff_id: number;
}

export interface CheckinItemRequest {
  loan_id: number;
  staff_id: number;
}

export interface AddMaterialRequest {
  title: string;
  subtitle?: string;
  material_type: string;
  isbn?: string;
  publication_year?: number;
  publisher_id?: number;
  language: string;
  pages?: number;
  description?: string;
  total_copies: number;
}

export interface PayFineRequest {
  fine_id: number;
  payment_amount: number;
  payment_method: string;
  staff_id: number;
}

// Fine Management Types
export interface WaiveFineRequest {
  fine_id: number;
  waiver_reason: string;
  staff_id: number;
}

export interface AssessFineRequest {
  patron_id: number;
  loan_id?: number;
  fine_type: string;
  amount: number;
  staff_id: number;
}

// Reporting Types
export interface OverdueCountRequest {
  branch_id?: number;
}

export interface TotalFinesRequest {
  patron_id?: number;
}

export interface MaterialAvailabilityRequest {
  material_id: number;
}

// Batch Operations Types
export interface DailyReportRequest {
  branch_id?: number;
}

// User Management Types
export interface AssignRoleRequest {
  user_id: number;
  role_id: number;
}

export interface RevokeRoleRequest {
  user_id: number;
  role_id: number;
}

export interface CheckPermissionRequest {
  user_id: number;
  permission_code: string;
}

export interface CheckRoleRequest {
  user_id: number;
  role_code: string;
}
