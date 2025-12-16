import React, { useState, useEffect } from 'react';
import { getUserId } from '../utils/auth';
import { logout, browseMaterials } from '../services/api';
import { useNavigate } from 'react-router-dom';

interface Material {
    material_id: number;
    title: string;
    subtitle?: string;
    authors?: string;
    genres?: string;
    material_type: string;
    isbn?: string;
    publication_year?: number;
    available_copies: number;
    total_copies: number;
    is_new_release?: string;
    publisher_name?: string;
}

const PatronDashboard: React.FC = () => {
    const navigate = useNavigate();
    const [activeTab, setActiveTab] = useState('browse');
    const [materials, setMaterials] = useState<Material[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        loadMaterials();
    }, []);

    const loadMaterials = async (search?: string) => {
        try {
            setLoading(true);
            const response = await browseMaterials(search);
            if (response.data) {
                setMaterials(response.data);
            }
        } catch (error) {
            console.error("Error loading materials", error);
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = () => {
        logout('current_session');
        sessionStorage.clear();
        localStorage.clear();
        navigate('/');
    };

    const handleSearch = (e: React.FormEvent) => {
        e.preventDefault();
        loadMaterials(searchTerm);
    };

    const renderBrowse = () => (
        <div className="space-y-6 animate-fadeIn">
            {/* Search Bar */}
            <form onSubmit={handleSearch} className="relative">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <svg className="h-6 w-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
                <input
                    type="text"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    placeholder="Search by title, author, or ISBN..."
                    className="block w-full pl-12 pr-4 py-4 text-lg border-2 border-gray-200 rounded-xl bg-white placeholder-gray-400 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 shadow-sm transition-all"
                />
            </form>

            {/* Loading */}
            {loading && (
                <div className="flex justify-center items-center py-20">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
                    <span className="ml-3 text-gray-600">Loading materials...</span>
                </div>
            )}

            {/* Material Cards */}
            {!loading && (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    {materials.length > 0 ? materials.map((material) => (
                        <div
                            key={material.material_id}
                            onClick={() => navigate(`/patron/material/${material.material_id}`)}
                            className="group bg-white flex flex-col rounded-2xl shadow-md hover:shadow-2xl transition-all duration-300 overflow-hidden border border-gray-100 transform hover:-translate-y-2 cursor-pointer"
                        >
                            {/* Cover */}
                            <div className="relative h-72 bg-gradient-to-br from-indigo-100 via-purple-100 to-pink-100">
                                <div className="absolute inset-0 flex items-center justify-center text-indigo-400/60">
                                    <svg className="w-24 h-24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                    </svg>
                                </div>

                                <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />

                                {/* Badges */}
                                <div className="absolute top-3 right-3 flex flex-col gap-2">
                                    {material.is_new_release === 'Y' && (
                                        <span className="bg-green-500 text-white text-xs font-bold px-2 py-1 rounded-full shadow-lg">
                                            NEW
                                        </span>
                                    )}
                                    <span className={`text-white text-xs font-bold px-2 py-1 rounded-full shadow-lg ${material.available_copies > 0 ? 'bg-green-600' : 'bg-red-500'
                                        }`}>
                                        {material.available_copies > 0 ? 'Available' : 'Out'}
                                    </span>
                                </div>

                                {/* Hover Button */}
                                <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button className="bg-white text-indigo-600 font-bold py-2 px-6 rounded-full shadow-xl">
                                        View Details
                                    </button>
                                </div>
                            </div>

                            {/* Info */}
                            <div className="flex-1 p-5 flex flex-col">
                                <div className="flex-1">
                                    <h3 className="font-bold text-lg text-gray-900 mb-1 line-clamp-2 group-hover:text-indigo-600 transition-colors">
                                        {material.title}
                                    </h3>
                                    {material.authors && (
                                        <p className="text-sm text-gray-600 mb-2 line-clamp-1">
                                            by {material.authors}
                                        </p>
                                    )}

                                    {material.genres && (
                                        <div className="flex flex-wrap gap-1 mb-3">
                                            {material.genres.split(',').slice(0, 2).map((genre, i) => (
                                                <span key={i} className="bg-indigo-50 text-indigo-700 text-xs px-2 py-1 rounded-full">
                                                    {genre.trim()}
                                                </span>
                                            ))}
                                        </div>
                                    )}
                                </div>

                                <div className="border-t pt-3 mt-3">
                                    <div className="flex items-center justify-between text-sm">
                                        <div className="flex items-center text-gray-600">
                                            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 19a2 2 0 01-2-2V7a2 2 0 012-2h4l2 2h4a2 2 0 012 2v1M5 19h14a2 2 0 002-2v-5a2 2 0 00-2-2H9a2 2 0 00-2 2v5a2 2 0 01-2 2z" />
                                            </svg>
                                            <span className="font-medium">{material.available_copies}</span>
                                            <span className="mx-1">/</span>
                                            <span>{material.total_copies}</span>
                                        </div>
                                        <span className="text-xs text-gray-500 uppercase">
                                            {material.material_type}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    )) : (
                        <div className="col-span-full text-center py-20">
                            <svg className="mx-auto h-16 w-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <h3 className="mt-4 text-lg font-medium text-gray-900">No materials found</h3>
                            <p className="mt-2 text-gray-500">Try adjusting your search</p>
                        </div>
                    )}
                </div>
            )}
        </div>
    );

    const renderLoans = () => (
        <div className="bg-white rounded- xl p-6 shadow-md">
            <h3 className="text-xl font-bold text-gray-800 mb-4">My Loans</h3>
            <p className="text-gray-600">Coming soon...</p>
        </div>
    );

    const renderReservations = () => (
        <div className="bg-white rounded-xl p-6 shadow-md">
            <h3 className="text-xl font-bold text-gray-800 mb-4">My Reservations</h3>
            <p className="text-gray-600">Coming soon...</p>
        </div>
    );

    const renderFines = () => (
        <div className="bg-white rounded-xl p-6 shadow-md">
            <h3 className="text-xl font-bold text-gray-800 mb-4">Fines & Fees</h3>
            <p className="text-gray-600">Coming soon...</p>
        </div>
    );

    return (
        <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-indigo-50">
            {/* Header */}
            <header className="bg-white shadow-sm border-b">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between items-center py-6">
                        <div>
                            <h1 className="text-3xl font-bold text-gray-900">Patron Portal</h1>
                            <p className="text-sm text-gray-600 mt-1">Browse, reserve, and manage your library materials</p>
                        </div>
                        <button
                            onClick={handleLogout}
                            className="px-6 py-2 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-lg font-medium transition-colors"
                        >
                            Logout
                        </button>
                    </div>
                </div>
            </header>

            {/* Tabs */}
            <div className="bg-white border-b">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <nav className="flex space-x-8" aria-label="Tabs">
                        {['browse', 'loans', 'reservations', 'fines'].map((tab) => (
                            <button
                                key={tab}
                                onClick={() => setActiveTab(tab)}
                                className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab === tab
                                        ? 'border-indigo-500 text-indigo-600'
                                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                                    }`}
                            >
                                {tab.charAt(0).toUpperCase() + tab.slice(1)}
                            </button>
                        ))}
                    </nav>
                </div>
            </div>

            {/* Content */}
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {activeTab === 'browse' && renderBrowse()}
                {activeTab === 'loans' && renderLoans()}
                {activeTab === 'reservations' && renderReservations()}
                {activeTab === 'fines' && renderFines()}
            </main>
        </div>
    );
};

export default PatronDashboard;
