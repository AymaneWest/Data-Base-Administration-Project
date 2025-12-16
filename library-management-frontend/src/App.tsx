import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/login';
import StaffDashboard from './pages/StaffDashboard';
import AdminDashboard from './pages/AdminDashboard';
import PatronDashboard from './pages/PatronDashboard';
import MaterialDetail from './pages/MaterialDetail';
import SignUp from './pages/SignUp';
import { getAuthToken, getUserRoles } from './utils/auth';

const ProtectedRoute: React.FC<{ children: React.ReactElement; allowedRoles?: string[] }> = ({ children, allowedRoles }) => {
  const token = getAuthToken();
  const userRoles = getUserRoles(); // You need to import this

  if (!token) {
    return <Navigate to="/" replace />;
  }

  if (allowedRoles && allowedRoles.length > 0) {
    // Backend returns roles like ROLE_SYS_ADMIN, ROLE_STAFF, ROLE_PATRON
    // Convert everything to uppercase for comparison
    const userRolesUpper = userRoles.map(r => r.toUpperCase());
    const allowedRolesUpper = allowedRoles.map(r => r.toUpperCase());

    // Check if user has at least one of the allowed roles
    // Admin roles (ROLE_SYS_ADMIN, ROLE_ADMIN, ROLE_DIRECTOR) can access everything
    const hasAdminRole = userRolesUpper.some(role =>
      role.includes('ADMIN') || role.includes('DIRECTOR')
    );

    const hasAllowedRole = userRolesUpper.some(role =>
      allowedRolesUpper.some(allowed => role.includes(allowed))
    );

    const hasPermission = hasAdminRole || hasAllowedRole;

    if (!hasPermission) {
      // If Patron tries to access Staff/Admin -> Redirect to Patron
      if (userRoles.includes('Patron')) return <Navigate to="/patron" replace />;
      // If Staff tries to access Admin -> Redirect to Dashboard
      if (userRoles.includes('Staff') || userRoles.includes('Librarian')) return <Navigate to="/dashboard" replace />;

      return (
        <div className="min-h-screen flex flex-col items-center justify-center bg-gray-100 p-4">
          <div className="bg-white p-8 rounded-lg shadow-lg text-center max-w-md w-full">
            <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 mb-4">
              <svg className="h-6 w-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
            </div>
            <h1 className="text-xl font-bold text-gray-900 mb-2">Access Denied</h1>
            <p className="text-gray-600 mb-4">You do not have the required permissions to view this page.</p>
            <div className="text-left bg-gray-50 p-3 rounded-md mb-6 text-xs text-gray-500 font-mono border overflow-x-auto">
              <strong>Debug Info:</strong><br />
              Required: {allowedRoles?.join(', ')}<br />
              Current: {userRoles.length > 0 ? userRoles.join(', ') : 'None'}
            </div>
            <button
              onClick={() => {
                localStorage.clear();
                window.location.href = '/';
              }}
              className="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 text-base font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:text-sm"
            >
              Return to Login
            </button>
          </div>
        </div>
      );
    }
  }

  return children;
};

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/signup" element={<SignUp />} />
        <Route
          path="/patron"
          element={
            <ProtectedRoute allowedRoles={['Patron']}>
              <PatronDashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/patron/material/:id"
          element={
            <ProtectedRoute allowedRoles={['Patron']}>
              <MaterialDetail />
            </ProtectedRoute>
          }
        />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute allowedRoles={['Staff', 'Librarian']}>
              <StaffDashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/admin"
          element={
            <ProtectedRoute allowedRoles={['Admin', 'Administrator', 'Director']}>
              <AdminDashboard />
            </ProtectedRoute>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;
