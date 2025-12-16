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
    const [error, setError] = useState('');

    useEffect(() => {
        loadMaterials();
    }, []);

    const loadMaterials = async (search?: string) => {
        try {
            setLoading(true);
            setError('');
            const response = await browseMaterials(search);
            console.log('Materials response:', response.data); // Debug log
            if (response.data) {
                setMaterials(response.data);
            }
        } catch (error: any) {
            console.error("Error loading materials", error);
            setError(error.response?.data?.detail || 'Failed to load materials');
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
        <div className="space-y-8">
            {/* Search Bar */}
            <form onSubmit={handleSearch} className="relative">
                <div className="absolute inset-y-0 left-0 pl-5 flex items-center pointer-events-none">
                    <svg className="h-6 w-6 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
                <input
                    type="text"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    placeholder="Search by title, author, or ISBN..."
                    className="block w-full pl-14 pr-6 py-5 text-lg border-0 rounded-2xl bg-white placeholder-gray-400 focus:outline-none focus:ring-4 focus:ring-indigo-200 shadow-lg transition-all"
                />
            </form>

            {/* Error Message */}
            {error && (
                <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-lg">
                    <div className="flex">
                        <div className="flex-shrink-0">
                            <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                            </svg>
                        </div>
                        <div className="ml-3">
                            <p className="text-sm text-red-700">{error}</p>
                        </div>
                    </div>
                </div>
            )}

            {/* Loading */}
            {loading && (
                <div className="flex flex-col justify-center items-center py-32">
                    <div className="relative">
                        <div className="animate-spin rounded-full h-16 w-16 border-4 border-indigo-200"></div>
                        <div className="animate-spin rounded-full h-16 w-16 border-t-4 border-indigo-600 absolute top-0 left-0"></div>
                    </div>
                    <span className="mt-6 text-lg text-gray-600 font-medium">Loading amazing books...</span>
                </div>
            )}

            {/* Material Cards */}
            {!loading && materials.length > 0 && (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                    {materials.map((material) => {
                        const isAvailable = material.available_copies > 0;
                        const stockPercent = (material.available_copies / material.total_copies) * 100;

                        return (
                            <div
                                key={material.material_id}
                                onClick={() => navigate(`/patron/material/${material.material_id}`)}
                                className="group bg-white flex flex-col rounded-3xl shadow-lg hover:shadow-2xl transition-all duration-500 overflow-hidden border-2 border-transparent hover:border-indigo-200 transform hover:-translate-y-3 cursor-pointer"
                            >
                                {/* Cover */}
                                <div className="relative h-80 bg-gradient-to-br from-violet-500 via-purple-500 to-fuchsia-500 overflow-hidden">
                                    {/* Book Icon */}
                                    <div className="absolute inset-0 flex items-center justify-center text-white/30">
                                        <svg className="w-32 h-32 transform group-hover:scale-110 transition-transform duration-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                        </svg>
                                    </div>

                                    {/* Gradient Overlay */}
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

                                    {/* Badges */}
                                    <div className="absolute top-4 right-4 flex flex-col gap-2">
                                        {material.is_new_release === 'Y' && (
                                            <span className="bg-yellow-400 text-yellow-900 text-xs font-black px-3 py-1.5 rounded-full shadow-xl animate-pulse">
                                                ⭐ NEW
                                            </span>
                                        )}
                                        {isAvailable ? (
                                            <span className="bg-emerald-500 text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-xl">
                                                ✓ Available
                                            </span>
                                        ) : (
                                            <span className="bg-red-500 text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-xl">
                                                ✗ Out of Stock
                                            </span>
                                        )}
                                    </div>

                                    {/* Hover: View Details Button */}
                                    <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-500 transform scale-90 group-hover:scale-100">
                                        <button className="bg-white text-indigo-600 font-bold py-3 px-8 rounded-full shadow-2xl flex items-center gap-2">
                                            <span>View Details</span>
                                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                                            </svg>
                                        </button>
                                    </div>
                                </div>

                                {/* Info Card */}
                                <div className="flex-1 p-6 flex flex-col bg-gradient-to-b from-white to-gray-50">
                                    <div className="flex-1 mb-4">
                                        <h3 className="font-bold text-xl text-gray-900 mb-2 line-clamp-2 group-hover:text-indigo-600 transition-colors leading-tight">
                                            {material.title}
                                        </h3>
                                        {material.authors && (
                                            <p className="text-sm text-gray-600 mb-3 line-clamp-1 flex items-center">
                                                <svg className="w-4 h-4 mr-1.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                                </svg>
                                                {material.authors}
                                            </p>
                                        )}

                                        {/* Genres */}
                                        {material.genres && (
                                            <div className="flex flex-wrap gap-1.5 mb-3">
                                                {material.genres.split(',').slice(0, 2).map((genre, i) => (
                                                    <span key={i} className="bg-indigo-100 text-indigo-700 text-xs font-semibold px-3 py-1 rounded-full">
                                                        {genre.trim()}
                                                    </span>
                                                ))}
                                                {material.genres.split(',').length > 2 && (
                                                    <span className="bg-gray-100 text-gray-600 text-xs font-semibold px-3 py-1 rounded-full">
                                                        +{material.genres.split(',').length - 2}
                                                    </span>
                                                )}
                                            </div>
                                        )}
                                    </div>

                                    {/* Stock Progress Bar */}
                                    <div className="mb-3">
                                        <div className="flex justify-between items-center mb-1.5">
                                            <span className="text-xs font-medium text-gray-600">Stock Level</span>
                                            <span className="text-xs font-bold text-gray-900">{material.available_copies}/{material.total_copies}</span>
                                        </div>
                                        <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                                            <div
                                                className={`h-full transition-all duration-500 ${stockPercent > 50 ? 'bg-green-500' : stockPercent > 25 ? 'bg-yellow-500' : 'bg-red-500'
                                                    }`}
                                                style={{ width: `${stockPercent}%` }}
                                            />
                                        </div>
                                    </div>

                                    {/* Footer */}
                                    <div className="flex items-center justify-between text-xs text-gray-500 pt-3 border-t border-gray-200">
                                        <span className="uppercase font-semibold tracking-wider">
                                            {material.material_type}
                                        </span>
                                        {material.publication_year && (
                                            <span className="flex items-center">
                                                <svg className="w-3.5 h-3.5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                </svg>
                                                {material.publication_year}
                                            </span>
                                        )}
                                    </div>
                                </div>
                            </div>
                        );
                    })}
                </div>
            )}

            {/* Empty State */}
            {!loading && materials.length === 0 && (
                <div className="text-center py-32">
                    <div className="inline-flex items-center justify-center w-24 h-24 bg-gradient-to-br from-indigo-100 to-purple-100  rounded-full mb-6">
                        <svg className="w-12 h-12 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                        </svg>
                    </div>
                    <h3 className="text-2xl font-bold text-gray-900 mb-2">No Materials Found</h3>
                    <p className="text-gray-500 mb-6 max-w-md mx-auto">
                        We couldn't find any materials in our catalog. Try adjusting your search or check back later.
                    </p>
                    <button
                        onClick={() => { setSearchTerm(''); loadMaterials(); }}
                        className="inline-flex items-center px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-xl transition-colors shadow-lg"
                    >
                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                        </svg>
                        Refresh
                    </button>
                </div>
            )}
        </div>
    );

    const renderLoans = () => (
        <div className="bg-white rounded-2xl p-8 shadow-lg">
            <h3 className="text-2xl font-bold text-gray-800 mb-4">My Loans</h3>
            <p className="text-gray-600">Coming soon...</p>
        </div>
    );

    const renderReservations = () => (
        <div className="bg-white rounded-2xl p-8 shadow-lg">
            <h3 className="text-2xl font-bold text-gray-800 mb-4">My Reservations</h3>
            <p className="text-gray-600">Coming soon...</p>
        </div>
    );

    const renderFines = () => (
        <div className="bg-white rounded-2xl p-8 shadow-lg">
            <h3 className="text-2xl font-bold text-gray-800 mb-4">Fines & Fees</h3>
            <p className="text-gray-600">Coming soon...</p>
        </div>
    );

    return (
        <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50">
            {/* Header */}
            <header className="bg-white/80 backdrop-blur-lg shadow-sm border-b border-indigo-100 sticky top-0 z-50">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between items-center py-6">
                        <div>
                            <h1 className="text-4xl font-extrabold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                                Patron Portal
                            </h1>
                            <p className="text-sm text-gray-600 mt-1.5 font-medium">Discover your next great read</p>
                        </div>
                        <button
                            onClick={handleLogout}
                            className="px-6 py-3 bg-gradient-to-r from-gray-100 to-gray-200 hover:from-gray-200 hover:to-gray-300 text-gray-800 rounded-xl font-semibold transition-all shadow-md hover:shadow-lg transform hover:scale-105"
                        >
                            Logout
                        </button>
                    </div>
                </div>
            </header>

            {/* Tabs */}
            <div className="bg-white/60 backdrop-blur-sm border-b border-indigo-100 sticky top-[88px] z-40">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <nav className="flex space-x-2" aria-label="Tabs">
                        {[
                            { id: 'browse', label: 'Browse', icon: 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z' },
                            { id: 'loans', label: 'My Loans', icon: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z' },
                            { id: 'reservations', label: 'Reservations', icon: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z' },
                            { id: 'fines', label: 'Fines', icon: 'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z' }
                        ].map((tab) => (
                            <button
                                key={tab.id}
                                onClick={() => setActiveTab(tab.id)}
                                className={`flex items-center gap-2 py-4 px-6 border-b-4 font-semibold text-sm transition-all ${activeTab === tab.id
                                        ? 'border-indigo-600 text-indigo-600 bg-indigo-50/50'
                                        : 'border-transparent text-gray-600 hover:text-gray-800 hover:border-gray-300 hover:bg-gray-50/30'
                                    }`}
                            >
                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={tab.icon} />
                                </svg>
                                {tab.label}
                            </button>
                        ))}
                    </nav>
                </div>
            </div>

            {/* Content */}
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
                {activeTab === 'browse' && renderBrowse()}
                {activeTab === 'loans' && renderLoans()}
                {activeTab === 'reservations' && renderReservations()}
                {activeTab === 'fines' && renderFines()}
            </main>
        </div>
    );
};

export default PatronDashboard;
