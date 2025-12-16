import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { logout } from '../services/api';
import { getAuthToken, removeAuthToken, getUserId } from '../utils/auth';
import * as api from '../services/api';

const StaffDashboard: React.FC = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('library');
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
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">Staff Dashboard</h1>
          <button onClick={handleLogout} className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md text-sm font-medium">
            Logout
          </button>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow mb-6">
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8 px-6" aria-label="Tabs">
              {['library', 'patrons', 'materials', 'circulation', 'fines', 'utility'].map((tab) => (
                <button key={tab} onClick={() => setActiveTab(tab)}
                  className={`${activeTab === tab ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'} whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm capitalize`}>
                  {tab}
                </button>
              ))}
            </nav>
          </div>

          <div className="p-6">
            {activeTab === 'library' && <LibrarySection userId={userId} onApiCall={handleApiCall} />}
            {activeTab === 'patrons' && <PatronSection userId={userId} onApiCall={handleApiCall} />}
            {activeTab === 'materials' && <MaterialSection userId={userId} onApiCall={handleApiCall} />}
            {activeTab === 'circulation' && <CirculationSection userId={userId} onApiCall={handleApiCall} />}
            {activeTab === 'fines' && <FineSection userId={userId} onApiCall={handleApiCall} />}
            {activeTab === 'utility' && <UtilitySection onApiCall={handleApiCall} />}
          </div>
        </div>

        {result && (
          <div className="bg-green-50 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4">
            <strong className="font-bold">Success!</strong>
            <span className="block sm:inline"> {result.message}</span>
            <pre className="mt-2 text-xs overflow-auto max-h-96">{JSON.stringify(result.data, null, 2)}</pre>
          </div>
        )}
        {error && (
          <div className="bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded relative">
            <strong className="font-bold">Error!</strong>
            <span className="block sm:inline"> {error}</span>
          </div>
        )}
      </div>
    </div>
  );
};

// Library Section Component (NEW)
const LibrarySection: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  const [formData, setFormData] = useState<any>({});

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold mb-4">Library Management Operations</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Add Patron */}
        <div className="bg-gray-50 p-4 rounded-lg col-span-full">
          <h3 className="text-lg font-semibold mb-3">Add Patron</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
            <input type="text" placeholder="Card Number" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, card_number: e.target.value})} />
            <input type="text" placeholder="First Name" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, first_name: e.target.value})} />
            <input type="text" placeholder="Last Name" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, last_name: e.target.value})} />
            <input type="email" placeholder="Email" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, email: e.target.value})} />
            <input type="tel" placeholder="Phone" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, phone: e.target.value})} />
            <input type="text" placeholder="Address" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, address: e.target.value})} />
            <input type="date" placeholder="Date of Birth" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, date_of_birth: e.target.value})} />
            <select className="px-3 py-2 border rounded-md" onChange={(e) => setFormData({...formData, membership_type: e.target.value})}>
              <option value="">Membership Type</option>
              <option value="STUDENT">Student</option>
              <option value="ADULT">Adult</option>
              <option value="SENIOR">Senior</option>
            </select>
            <input type="number" placeholder="Branch ID" className="px-3 py-2 border rounded-md"
              onChange={(e) => setFormData({...formData, branch_id: parseInt(e.target.value)})} />
            <button onClick={() => onApiCall(() => api.addPatron(formData), 'Patron added')}
              className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
              Add Patron
            </button>
          </div>
        </div>

        {/* Checkout Item */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Checkout Item</h3>
          <input type="number" placeholder="Patron ID" className="w-full px-3 py-2 border rounded-md mb-2"
            onChange={(e) => setFormData({...formData, patron_id: parseInt(e.target.value)})} />
          <input type="number" placeholder="Copy ID" className="w-full px-3 py-2 border rounded-md mb-2"
            onChange={(e) => setFormData({...formData, copy_id: parseInt(e.target.value)})} />
          <button onClick={() => onApiCall(() => api.checkoutItem({...formData, staff_id: userId}), 'Item checked out')}
            className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
            Checkout
          </button>
        </div>

        {/* Checkin Item */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Checkin Item</h3>
          <input type="number" placeholder="Loan ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setFormData({...formData, loan_id: parseInt(e.target.value)})} />
          <button onClick={() => onApiCall(() => api.checkinItem({loan_id: formData.loan_id, staff_id: userId}), 'Item checked in')}
            className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700">
            Checkin
          </button>
        </div>

        {/* Renew Loan */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Renew Loan</h3>
          <input type="number" placeholder="Loan ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setFormData({...formData, loan_id: parseInt(e.target.value)})} />
          <button onClick={() => onApiCall(() => api.renewLoan(formData.loan_id), 'Loan renewed')}
            className="w-full bg-purple-600 text-white px-4 py-2 rounded-md hover:bg-purple-700">
            Renew Loan
          </button>
        </div>

        {/* Get Patron Statistics */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">Patron Statistics</h3>
          <input type="number" placeholder="Patron ID" className="w-full px-3 py-2 border rounded-md mb-3"
            onChange={(e) => setFormData({...formData, patron_id: parseInt(e.target.value)})} />
          <button onClick={() => onApiCall(() => api.getPatronStatistics(formData.patron_id), 'Statistics retrieved')}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
            Get Statistics
          </button>
        </div>
      </div>
    </div>
  );
};

// Patron Section Component (Previous)
const PatronSection: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  const [patronId, setPatronId] = useState('');
  const [reason, setReason] = useState('');

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Renew Membership</h3>
        <input type="number" placeholder="Patron ID" value={patronId} onChange={(e) => setPatronId(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.renewMembership(parseInt(patronId)), 'Membership renewed')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Renew
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Suspend Patron</h3>
        <input type="number" placeholder="Patron ID" className="w-full px-3 py-2 border border-gray-300 rounded-md mb-2"
          onChange={(e) => setPatronId(e.target.value)} />
        <input type="text" placeholder="Reason" value={reason} onChange={(e) => setReason(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.suspendPatron(parseInt(patronId), reason, userId), 'Patron suspended')}
          className="w-full bg-yellow-600 text-white px-4 py-2 rounded-md hover:bg-yellow-700">
          Suspend
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Reactivate Patron</h3>
        <input type="number" placeholder="Patron ID" onChange={(e) => setPatronId(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.reactivatePatron(parseInt(patronId), userId), 'Patron reactivated')}
          className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700">
          Reactivate
        </button>
      </div>
    </div>
  );
};

// Material, Circulation, Fine, Utility sections remain the same as before...
// (Include the previous implementations)

const MaterialSection: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  const [materialData, setMaterialData] = useState<any>({});

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Add Copy</h3>
        <input type="number" placeholder="Material ID" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setMaterialData({...materialData, material_id: parseInt(e.target.value)})} />
        <input type="text" placeholder="Barcode" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setMaterialData({...materialData, barcode: e.target.value})} />
        <input type="number" placeholder="Branch ID" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setMaterialData({...materialData, branch_id: parseInt(e.target.value)})} />
        <input type="number" placeholder="Acquisition Price" className="w-full px-3 py-2 border rounded-md mb-3"
          onChange={(e) => setMaterialData({...materialData, acquisition_price: parseFloat(e.target.value)})} />
        <button onClick={() => onApiCall(() => api.addCopy(materialData), 'Copy added')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Add Copy
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Update Material</h3>
        <input type="number" placeholder="Material ID" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setMaterialData({...materialData, material_id: parseInt(e.target.value)})} />
        <input type="text" placeholder="Title" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setMaterialData({...materialData, title: e.target.value})} />
        <input type="text" placeholder="Description" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setMaterialData({...materialData, description: e.target.value})} />
        <input type="text" placeholder="Language" className="w-full px-3 py-2 border rounded-md mb-3"
          onChange={(e) => setMaterialData({...materialData, language: e.target.value})} />
        <button onClick={() => onApiCall(() => api.updateMaterial(materialData), 'Material updated')}
          className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
          Update
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Delete Material</h3>
        <input type="number" placeholder="Material ID" className="w-full px-3 py-2 border rounded-md mb-3"
          onChange={(e) => setMaterialData({...materialData, material_id: parseInt(e.target.value)})} />
        <button onClick={() => onApiCall(() => api.deleteMaterial(materialData.material_id, userId), 'Material deleted')}
          className="w-full bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700">
          Delete
        </button>
      </div>
    </div>
  );
};

const CirculationSection: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  const [loanId, setLoanId] = useState('');
  const [replacementCost, setReplacementCost] = useState('');

  return (
    <div className="bg-gray-50 p-4 rounded-lg max-w-md">
      <h3 className="text-lg font-semibold mb-3">Declare Item Lost</h3>
      <input type="number" placeholder="Loan ID" value={loanId} onChange={(e) => setLoanId(e.target.value)}
        className="w-full px-3 py-2 border border-gray-300 rounded-md mb-2" />
      <input type="number" placeholder="Replacement Cost" value={replacementCost}
        onChange={(e) => setReplacementCost(e.target.value)}
        className="w-full px-3 py-2 border border-gray-300 rounded-md mb-3" />
      <button
        onClick={() => onApiCall(() => api.declareItemLost({
          loan_id: parseInt(loanId),
          staff_id: userId,
          replacement_cost: parseFloat(replacementCost)
        }), 'Item declared lost')}
        className="w-full bg-orange-600 text-white px-4 py-2 rounded-md hover:bg-orange-700">
        Declare Lost
      </button>
    </div>
  );
};

const FineSection: React.FC<{ userId: number; onApiCall: Function }> = ({ userId, onApiCall }) => {
  const [fineData, setFineData] = useState<any>({});

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Waive Fine</h3>
        <input type="number" placeholder="Fine ID" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setFineData({...fineData, fine_id: parseInt(e.target.value)})} />
        <input type="text" placeholder="Waiver Reason" className="w-full px-3 py-2 border rounded-md mb-3"
          onChange={(e) => setFineData({...fineData, waiver_reason: e.target.value})} />
        <button onClick={() => onApiCall(() => api.waiveFine({...fineData, staff_id: userId}), 'Fine waived')}
          className="w-full bg-yellow-600 text-white px-4 py-2 rounded-md hover:bg-yellow-700">
          Waive Fine
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Assess Fine</h3>
        <input type="number" placeholder="Patron ID" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setFineData({...fineData, patron_id: parseInt(e.target.value)})} />
        <input type="number" placeholder="Loan ID (Optional)" className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setFineData({...fineData, loan_id: parseInt(e.target.value)})} />
        <select className="w-full px-3 py-2 border rounded-md mb-2"
          onChange={(e) => setFineData({...fineData, fine_type: e.target.value})}>
          <option value="">Select Fine Type</option>
          <option value="OVERDUE">Overdue</option>
          <option value="LOST">Lost Item</option>
          <option value="DAMAGE">Damage</option>
        </select>
        <input type="number" placeholder="Amount" className="w-full px-3 py-2 border rounded-md mb-3"
          onChange={(e) => setFineData({...fineData, amount: parseFloat(e.target.value)})} />
        <button onClick={() => onApiCall(() => api.assessFine({...fineData, staff_id: userId}), 'Fine assessed')}
          className="w-full bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700">
          Assess Fine
        </button>
      </div>
    </div>
  );
};

const UtilitySection: React.FC<{ onApiCall: Function }> = ({ onApiCall }) => {
  const [patronId, setPatronId] = useState('');
  const [membershipType, setMembershipType] = useState('');
  const [dueDate, setDueDate] = useState('');
  const [returnDate, setReturnDate] = useState('');

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Check Patron Exists</h3>
        <input type="number" placeholder="Patron ID" onChange={(e) => setPatronId(e.target.value)}
          className="w-full px-3 py-2 border rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.checkPatronExists(parseInt(patronId)), 'Patron check complete')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Check
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Loan Period</h3>
        <input type="text" placeholder="Membership Type" onChange={(e) => setMembershipType(e.target.value)}
          className="w-full px-3 py-2 border rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.calculateLoanPeriod(membershipType), 'Loan period calculated')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Calculate
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Borrow Limit</h3>
        <input type="text" placeholder="Membership Type" onChange={(e) => setMembershipType(e.target.value)}
          className="w-full px-3 py-2 border rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.calculateBorrowLimit(membershipType), 'Borrow limit calculated')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Calculate
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Active Loans</h3>
        <input type="number" placeholder="Patron ID" onChange={(e) => setPatronId(e.target.value)}
          className="w-full px-3 py-2 border rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.getActiveLoanCount(parseInt(patronId)), 'Loan count retrieved')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Get Count
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Calculate Fine</h3>
        <input type="date" placeholder="Due Date" onChange={(e) => setDueDate(e.target.value)}
          className="w-full px-3 py-2 border rounded-md mb-2" />
        <input type="date" placeholder="Return Date (Optional)" onChange={(e) => setReturnDate(e.target.value)}
          className="w-full px-3 py-2 border rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.calculateFine(dueDate, returnDate || undefined), 'Fine calculated')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Calculate
        </button>
      </div>

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="text-lg font-semibold mb-3">Check Eligibility</h3>
        <input type="number" placeholder="Patron ID" onChange={(e) => setPatronId(e.target.value)}
          className="w-full px-3 py-2 border rounded-md mb-3" />
        <button onClick={() => onApiCall(() => api.checkEligibility(parseInt(patronId)), 'Eligibility checked')}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700">
          Check
        </button>
      </div>
    </div>
  );
};

export default StaffDashboard;
