import React, { useState, useEffect } from 'react';
import { getUserId } from '../utils/auth';
import { logout } from '../services/api';
import { useNavigate } from 'react-router-dom';
import {
    getPatronStatistics,
    getDashboardOverview,
    getPopularBooks,
    checkoutItem,
    checkinItem
} from '../services/api';

const PatronDashboard: React.FC = () => {
    const navigate = useNavigate();
    const [activeTab, setActiveTab] = useState('browse');
    const [stats, setStats] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    // Mock data for browser
    const [materials, setMaterials] = useState<any[]>([]);

    useEffect(() => {
        loadDashboardData();
    }, []);

    const loadDashboardData = async () => {
        try {
            const userId = getUserId();
            // In a real app, we'd fetch Patron ID from User ID first, 
            // or the backend would handle "me" endpoint.
            // For now, let's assume we can get some general stats or use a mock patron ID if needed.
            // Or better, fetch popular books for the "Browse" tab initial state.
            const popularParams = await getPopularBooks();
            if (popularParams.data) setMaterials(popularParams.data);

        } catch (error) {
            console.error("Error loading dashboard", error);
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = () => {
        logout('current_session'); // backend requires session_id
        sessionStorage.clear();
        localStorage.clear();
        navigate('/');
    };

    const renderBrowse = () => (
        <div className="space-y-6">
            <div className="flex gap-4">
                <input
                    type="text"
                    placeholder="Search by title, author, or ISBN..."
                    className="flex-1 p-3 border rounded-lg shadow-sm focus:ring-2 focus:ring-indigo-500"
                />
                <button className="px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700">
                    Search
                </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {materials.length > 0 ? materials.map((book: any, idx) => (
                    <div key={idx} className="bg-white p-6 rounded-lg shadow hover:shadow-md transition-shadow">
                        <div className="h-40 bg-gray-200 rounded-md mb-4 flex items-center justify-center text-gray-400">
                            Book Cover
                        </div>
                        <h3 className="font-bold text-lg text-gray-800">{book.title}</h3>
                        <p className="text-gray-600 text-sm mb-4">Available Copies: {book.loan_count ? 'High Demand' : 'Available'}</p>
                        <button className="w-full py-2 border border-indigo-600 text-indigo-600 rounded hover:bg-indigo-50">
                            Reserve
                        </button>
                    </div>
                )) : (
                    <div className="col-span-3 text-center text-gray-500 py-10">
                        No materials found. Try searching.
                    </div>
                )}
            </div>
        </div>
    );

    const renderLoans = () => (
        <div className="bg-white rounded-lg shadow overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                    <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Due Date</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Action</th>
                    </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                    {/* Mock Data */}
                    <tr>
                        <td className="px-6 py-4 whitespace-nowrap">The Great Gatsby</td>
                        <td className="px-6 py-4 whitespace-nowrap">2023-12-25</td>
                        <td className="px-6 py-4 whitespace-nowrap"><span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Active</span></td>
                        <td className="px-6 py-4 whitespace-nowrap">
                            <button className="text-indigo-600 hover:text-indigo-900">Renew</button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    );

    const renderSelfService = () => (
        <div className="max-w-xl mx-auto bg-white p-8 rounded-lg shadow-md">
            <h3 className="text-xl font-bold mb-6 text-center">Self Checkout / Checkin</h3>
            <div className="space-y-4">
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Item Barcode</label>
                    <input
                        type="text"
                        className="w-full p-3 border rounded-md focus:ring-indigo-500 focus:border-indigo-500"
                        placeholder="Scan or type barcode"
                    />
                </div>
                <div className="grid grid-cols-2 gap-4">
                    <button className="w-full py-3 bg-green-600 text-white rounded-md hover:bg-green-700 shadow-lg transform active:scale-95 transition-all">
                        Check Out
                    </button>
                    <button className="w-full py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700 shadow-lg transform active:scale-95 transition-all">
                        Check In
                    </button>
                </div>
            </div>
        </div>
    );

    return (
        <div className="min-h-screen bg-gray-100">
            {/* Header */}
            <nav className="bg-white shadow">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        <div className="flex items-center">
                            <span className="text-2xl font-bold text-indigo-600">Patron Portal</span>
                        </div>
                        <div className="flex items-center">
                            <button onClick={handleLogout} className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
                                Sign Out
                            </button>
                        </div>
                    </div>
                </div>
            </nav>

            {/* Main Content */}
            <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
                {/* Tabs */}
                <div className="mb-8 border-b border-gray-200">
                    <nav className="-mb-px flex space-x-8" aria-label="Tabs">
                        {['browse', 'loans', 'reservations', 'fines', 'self-service'].map((tab) => (
                            <button
                                key={tab}
                                onClick={() => setActiveTab(tab)}
                                className={`${activeTab === tab
                                    ? 'border-indigo-500 text-indigo-600'
                                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                                    } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm capitalize`}
                            >
                                {tab.replace('-', ' ')}
                            </button>
                        ))}
                    </nav>
                </div>

                {/* Tab Panels */}
                <div className="min-h-[400px]">
                    {activeTab === 'browse' && renderBrowse()}
                    {activeTab === 'loans' && renderLoans()}
                    {activeTab === 'self-service' && renderSelfService()}
                    {activeTab === 'reservations' && <div className="text-center py-10 text-gray-500">No active reservations.</div>}
                    {activeTab === 'fines' && <div className="text-center py-10 text-gray-500">No outstanding fines.</div>}
                </div>
            </main>
        </div>
    );
};

export default PatronDashboard;
