export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  success: boolean;
  message: string;
  session_id: string;
  user_id: number;
  oracle_username: string;
  oracle_password: string;
  roles: string;
}

export interface BaseResponse {
  success: boolean;
  message: string;
}

// Patron Types
export interface RenewMembershipRequest {
  patron_id: number;
}

export interface SuspendPatronRequest {
  patron_id: number;
  reason: string;
  staff_id: number;
}

export interface ReactivatePatronRequest {
  patron_id: number;
  staff_id: number;
}

// Material Types
export interface AddCopyRequest {
  material_id: number;
  barcode: string;
  branch_id: number;
  acquisition_price: number;
}

export interface UpdateMaterialRequest {
  material_id: number;
  title?: string;
  description?: string;
  language?: string;
}

export interface DeleteMaterialRequest {
  material_id: number;
  staff_id: number;
}

// Circulation Types
export interface DeclareItemLostRequest {
  loan_id: number;
  staff_id: number;
  replacement_cost: number;
}

// Utility Types
export interface PatronExistsRequest {
  patron_id: number;
}

export interface CalculateLoanPeriodRequest {
  membership_type: string;
}

export interface CalculateBorrowLimitRequest {
  membership_type: string;
}

export interface ActiveLoanCountRequest {
  patron_id: number;
}

export interface CalculateFineRequest {
  due_date: string;
  return_date?: string;
}

export interface CheckEligibilityRequest {
  patron_id: number;
}