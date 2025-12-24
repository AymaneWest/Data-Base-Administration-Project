import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { logout } from '../services/api';
import { getAuthToken, removeAuthToken, getUserId } from '../utils/auth';
import * as api from '../services/api';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

const AdminDashboard: React.FC = () => {
  const navigate = useNavigate();
  const [activeView, setActiveView] = useState('admin');
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState('');
  const userId = getUserId();

  const handleLogout = async () => {
    try {
      const sessionId = getAuthToken();
      if (sessionId) await logout(sessionId);
      removeAuthToken();
      navigate('/');
    } catch (err) {
      removeAuthToken();
      navigate('/');
    }
  };

  const handleApiCall = async (apiFunc: () => Promise<any>, successMsg: string) => {
    setError('');
    setResult(null);
    try {
      const response = await apiFunc();
      setResult({ success: true, data: response.data, message: successMsg });
    } catch (err: any) {
      setError(err.response?.data?.message || err.message || 'An error occurred');
    }
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-indigo-700 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-white">Admin Dashboard</h1>
          <button onClick={handleLogout} className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md text-sm font-medium">
            Logout
          </button>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* View Selector / Navigation */}
        <div className="bg-white rounded-lg shadow mb-6 p-4">
          <div className="flex space-x-4">
            <button onClick={() => setActiveView('admin')}
              className={`px-6 py-3 rounded-lg font-medium ${activeView === 'admin' ? 'bg-indigo-600 text-white' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'}`}>
              Admin Functions
            </button>
            <button onClick={() => navigate('/dashboard')}
              className={`px-6 py-3 rounded-lg font-medium bg-green-600 text-white hover:bg-green-700`}>
              Go to Staff Dashboard
            </button>
            <button onClick={() => navigate('/patron')}
              className={`px-6 py-3 rounded-lg font-medium bg-teal-600 text-white hover:bg-teal-700`}>
              Go to Patron Dashboard
            </button>
          </div>
        </div>

        {/* Content Area */}
        {activeView === 'admin' && <AdminFunctionsView userId={userId} onApiCall={handleApiCall} />}
        {/* Navigation to other dashboards handled by useEffect or direct links, but here we can render them or redirect */}
        {/* If Admin wants to see Staff/Patron view, navigating to the actual route is better if they share the same layout.
            However, the user wants "links on the admin page". The current toggle is fine if we render components.
            Since StaffDashboard IS a page, we can import it? Or better, just redirect.
            User said: "put links on the admin page to all the other pages"
        */}
        {activeView === 'staff' && (
          <div className="text-center py-10">
            <p className="mb-4">Redirecting to Staff Dashboard...</p>
            {/* We could also just mount <StaffDashboard /> here if it doesn't rely on route params that are missing */}
          </div>
        )}
        {activeView === 'patron' && (
          <div className="text-center py-10">
            <p className="mb-4">Redirecting to Patron Dashboard...</p>
          </div>
        )}

        {/* Results Display */}
        {result && (
          <div className="bg-green-50 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4 mt-6">
            <strong className="font-bold">Success!</strong>
            <span className="block sm:inline"> {result.message}</span>
            <pre className="mt-2 text-xs overflow-auto max-h-96">{JSON.stringify(result.data, null, 2)}</pre>
          </div>
        )}
        {error && (
          <div className="bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded relative mt-6">
            <strong className="font-bold">Error!</strong>
            <span className="block sm:inline"> {error}</span>
          </div>
        )}
      </div>
    </div>
  );
};

// Admin Functions View
const AdminFunctionsView: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  const [activeTab, setActiveTab] = useState('users');

  return (
    <div className="bg-white rounded-lg shadow">
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8 px-6" aria-label="Tabs">
          {['users', 'reporting', 'batch', 'statistics'].map((tab) => (
            <button key={tab} onClick={() => setActiveTab(tab)}
              className={`${activeTab === tab ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'} whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm capitalize`}>
              {tab}
            </button>
          ))}
        </nav>
      </div>

      <div className="p-6">
        {activeTab === 'users' && <UserManagementSection userId={userId} onApiCall={onApiCall} />}
        {activeTab === 'reporting' && <ReportingSection onApiCall={onApiCall} />}
        {activeTab === 'batch' && <BatchOperationsSection onApiCall={onApiCall} />}
        {activeTab === 'statistics' && <StatisticsSection onApiCall={onApiCall} />}
      </div>
    </div>
  );
};

// User Management Section
const UserManagementSection: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  const [userData, setUserData] = useState<any>({});

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold mb-4">User Management</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Get User Status</h3>
          <input type="number" placeholder="User ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setUserData({ ...userData, user_id: parseInt(e.target.value) })} />
          <button onClick={() => onApiCall(() => api.getUserStatus(userData.user_id), 'User status retrieved')}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
            Get Status
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Get User Roles</h3>
          <input type="number" placeholder="User ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setUserData({ ...userData, user_id: parseInt(e.target.value) })} />
          <button onClick={() => onApiCall(() => api.getUserRoles(userData.user_id), 'User roles retrieved')}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
            Get Roles
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Check Permission</h3>
          <input type="number" placeholder="User ID" className="w-full px-3 py-2 border rounded-md mb-2"
            onChange={(e) => setUserData({ ...userData, user_id: parseInt(e.target.value) })} />
          <input type="text" placeholder="Permission Code" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setUserData({ ...userData, permission_code: e.target.value })} />
          <button onClick={() => onApiCall(() => api.checkPermission(userData), 'Permission checked')}
            className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
            Check Permission
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Check Role</h3>
          <input type="number" placeholder="User ID" className="w-full px-3 py-2 border rounded-md mb-2"
            onChange={(e) => setUserData({ ...userData, user_id: parseInt(e.target.value) })} />
          <input type="text" placeholder="Role Code" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setUserData({ ...userData, role_code: e.target.value })} />
          <button onClick={() => onApiCall(() => api.checkRole(userData), 'Role checked')}
            className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
            Check Role
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Assign Role</h3>
          <input type="number" placeholder="User ID" className="w-full px-3 py-2 border rounded-md mb-2"
            onChange={(e) => setUserData({ ...userData, user_id: parseInt(e.target.value) })} />
          <input type="number" placeholder="Role ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setUserData({ ...userData, role_id: parseInt(e.target.value) })} />
          <button onClick={() => onApiCall(() => api.assignRole(userData), 'Role assigned')}
            className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700">
            Assign Role
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Revoke Role</h3>
          <input type="number" placeholder="User ID" className="w-full px-3 py-2 border rounded-md mb-2"
            onChange={(e) => setUserData({ ...userData, user_id: parseInt(e.target.value) })} />
          <input type="number" placeholder="Role ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setUserData({ ...userData, role_id: parseInt(e.target.value) })} />
          <button onClick={() => onApiCall(() => api.revokeRole(userData), 'Role revoked')}
            className="w-full bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700">
            Revoke Role
          </button>
        </div>
      </div>
    </div>
  );
};

// Reporting Section
const ReportingSection: React.FC<{ onApiCall: Function }> = ({ onApiCall }) => {
  const [branchId, setBranchId] = useState('');
  const [patronId, setPatronId] = useState('');
  const [materialId, setMaterialId] = useState('');

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold mb-4">Reporting Functions</h2>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Overdue Count</h3>
          <input type="number" placeholder="Branch ID (Optional)" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setBranchId(e.target.value)} />
          <button onClick={() => onApiCall(() => api.getOverdueCount(branchId ? parseInt(branchId) : undefined), 'Overdue count retrieved')}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
            Get Count
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Total Fines</h3>
          <input type="number" placeholder="Patron ID (Optional)" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setPatronId(e.target.value)} />
          <button onClick={() => onApiCall(() => api.getTotalFines(patronId ? parseInt(patronId) : undefined), 'Total fines calculated')}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
            Calculate
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Material Availability</h3>
          <input type="number" placeholder="Material ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setMaterialId(e.target.value)} />
          <button onClick={() => onApiCall(() => api.checkMaterialAvailability(parseInt(materialId)), 'Availability checked')}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
            Check
          </button>
        </div>
      </div>
    </div>
  );
};

// Batch Operations Section
const BatchOperationsSection: React.FC<{ onApiCall: Function }> = ({ onApiCall }) => {
  const [branchId, setBranchId] = useState('');

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold mb-4">Batch Operations</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Process Overdue Notifications</h3>
          <p className="text-sm text-gray-600 mb-3">Send notifications for all overdue items</p>
          <button onClick={() => onApiCall(() => api.processOverdueNotifications(), 'Notifications processed')}
            className="w-full bg-orange-600 text-white px-4 py-2 rounded-md hover:bg-orange-700">
            Process Notifications
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Expire Memberships</h3>
          <p className="text-sm text-gray-600 mb-3">Mark expired memberships as inactive</p>
          <button onClick={() => onApiCall(() => api.expireMemberships(), 'Memberships expired')}
            className="w-full bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700">
            Expire Memberships
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Cleanup Reservations</h3>
          <p className="text-sm text-gray-600 mb-3">Remove expired reservations</p>
          <button onClick={() => onApiCall(() => api.cleanupReservations(), 'Reservations cleaned')}
            className="w-full bg-yellow-600 text-white px-4 py-2 rounded-md hover:bg-yellow-700">
            Cleanup
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Generate Daily Report</h3>
          <input type="number" placeholder="Branch ID (Optional)" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setBranchId(e.target.value)} />
          <button onClick={() => onApiCall(() => api.generateDailyReport(branchId ? parseInt(branchId) : undefined), 'Report generated')}
            className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700">
            Generate Report
          </button>
        </div>
      </div>
    </div>
  );
};



// Statistics Section
const StatisticsSection: React.FC<{ onApiCall: Function }> = ({ onApiCall }) => {
  const [patronId, setPatronId] = useState('');
  const [daysAhead, setDaysAhead] = useState('3');
  const [topN, setTopN] = useState('10');
  const [statsData, setStatsData] = useState<any>(null);
  const [activityData, setActivityData] = useState<any[]>([]);

  React.useEffect(() => {
    loadCharts();
  }, []);

  const loadCharts = async () => {
    try {
      const stats = await api.getDashboardOverview();
      const activity = await api.getMonthlyActivity();
      setStatsData(stats.data);
      setActivityData(activity.data);
    } catch (e) {
      console.error("Failed to load charts", e);
    }
  };

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold mb-4">Statistics & Reports</h2>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {/* Key Metrics */}
        {statsData && (
          <div className="bg-white p-4 rounded-lg shadow">
            <h3 className="text-lg font-semibold mb-4">Key Metrics</h3>
            <div className="grid grid-cols-2 gap-4 text-center">
              <div className="p-4 bg-blue-50 rounded">
                <p className="text-gray-500">Total Patrons</p>
                <p className="text-2xl font-bold text-blue-600">{statsData.total_patrons}</p>
              </div>
              <div className="p-4 bg-green-50 rounded">
                <p className="text-gray-500">Active Loans</p>
                <p className="text-2xl font-bold text-green-600">{statsData.active_loans}</p>
              </div>
              <div className="p-4 bg-yellow-50 rounded">
                <p className="text-gray-500">Materials</p>
                <p className="text-2xl font-bold text-yellow-600">{statsData.total_materials}</p>
              </div>
              <div className="p-4 bg-red-50 rounded">
                <p className="text-gray-500">Outstanding Fines</p>
                <p className="text-2xl font-bold text-red-600">${statsData.outstanding_fines || 0}</p>
              </div>
            </div>
          </div>
        )}

        {/* Activity Chart */}
        {activityData.length > 0 && (
          <div className="bg-white p-4 rounded-lg shadow h-80">
            <h3 className="text-lg font-semibold mb-4">Monthly Activity</h3>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={activityData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month_year" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="total_checkouts" fill="#8884d8" name="Checkouts" />
                <Bar dataKey="total_returns" fill="#82ca9d" name="Returns" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Existing buttons... */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Patron Details</h3>
          <input type="number" placeholder="Patron ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setPatronId(e.target.value)} />
          <button onClick={() => onApiCall(() => api.getPatronDetails(parseInt(patronId)), 'Details retrieved')}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
            Get Details
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Expiring Loans</h3>
          <input type="number" placeholder="Days Ahead" value={daysAhead} className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setDaysAhead(e.target.value)} />
          <button onClick={() => onApiCall(() => api.getExpiringLoans(parseInt(daysAhead)), 'Expiring loans retrieved')}
            className="w-full bg-orange-600 text-white px-4 py-2 rounded-md hover:bg-orange-700">
            Get Loans
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Fines Report</h3>
          <select className="w-full px-3 py-2 border rounded-md mb-3">
            <option value="ALL">All Fines</option>
            <option value="UNPAID">Unpaid</option>
            <option value="PAID">Paid</option>
          </select>
          <button onClick={() => onApiCall(() => api.getFinesReport('ALL'), 'Fines report retrieved')}
            className="w-full bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700">
            Get Report
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Popular Materials</h3>
          <input type="number" placeholder="Top N" value={topN} className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setTopN(e.target.value)} />
          <button onClick={() => onApiCall(() => api.getPopularMaterials(parseInt(topN)), 'Popular materials retrieved')}
            className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700">
            Get Materials
          </button>
        </div>

        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Branch Performance</h3>
          <p className="text-sm text-gray-600 mb-3">Performance metrics for all branches</p>
          <button onClick={() => onApiCall(() => api.getBranchPerformance(), 'Performance data retrieved')}
            className="w-full bg-purple-600 text-white px-4 py-2 rounded-md hover:bg-purple-700">
            Get Performance
          </button>
        </div>
      </div>
    </div>
  );
};

// Staff Functions View (reuse components from StaffDashboard)
const StaffFunctionsView: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  return (
    <div className="bg-gray-50 p-6 rounded-lg">
      <p className="text-gray-600">This section contains the same functions as the Staff Dashboard. You can integrate the StaffDashboard components here.</p>
    </div>
  );
};

// Patron View Placeholder
const PatronViewPlaceholder: React.FC = () => {
  return (
    <div className="bg-white rounded-lg shadow p-8 text-center">
      <h2 className="text-2xl font-bold text-gray-800 mb-4">Patron View</h2>
      <p className="text-gray-600">This view will be available in the future to show patron-specific features and information.</p>
    </div>
  );
};

export default AdminDashboard;
