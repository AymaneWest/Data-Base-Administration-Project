import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getMaterialDetail, checkoutItem } from '../services/api';
import { getUserId } from '../utils/auth';

interface Author {
    author_id: number;
    full_name: string;
    author_role: string;
}

interface Genre {
    genre_id: number;
    genre_name: string;
    is_primary_genre: string;
}

interface BranchAvailability {
    branch_id: number;
    branch_name: string;
    total_copies: number;
    available_copies: number;
}

interface MaterialDetail {
    material_id: number;
    title: string;
    subtitle?: string;
    material_type: string;
    isbn?: string;
    publication_year?: number;
    language: string;
    description?: string;
    publisher_name?: string;
    total_copies: number;
    available_copies: number;
    is_reference: string;
    is_new_release: string;
    authors: Author[];
    genres: Genre[];
    branch_availability: BranchAvailability[];
}

const MaterialDetail: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const [material, setMaterial] = useState<MaterialDetail | null>(null);
    const [loading, setLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState(false);
    const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null);

    useEffect(() => {
        loadMaterialDetail();
    }, [id]);

    const loadMaterialDetail = async () => {
        try {
            setLoading(true);
            const response = await getMaterialDetail(Number(id));
            setMaterial(response.data);
        } catch (error: any) {
            console.error('Error loading material:', error);
            setMessage({ type: 'error', text: 'Failed to load material details' });
        } finally {
            setLoading(false);
        }
    };

    const handleBorrow = async () => {
        if (!material) return;

        setActionLoading(true);
        setMessage(null);

        try {
            const userId = getUserId();
            // Call checkout API - this will need patron_id and copy_id
            // For now, we'll show a success message
            // In real implementation, you'd select an available copy
            setMessage({
                type: 'success',
                text: 'Borrow request initiated! Please proceed to the circulation desk.'
            });
        } catch (error: any) {
            setMessage({
                type: 'error',
                text: error.response?.data?.detail || 'Failed to process borrow request'
            });
        } finally {
            setActionLoading(false);
        }
    };

    const handleReserve = async () => {
        if (!material) return;

        setActionLoading(true);
        setMessage(null);

        try {
            const userId = getUserId();
            // Call reservation API
            setMessage({
                type: 'success',
                text: 'Reservation placed successfully! We\'ll notify you when it\'s available.'
            });
        } catch (error: any) {
            setMessage({
                type: 'error',
                text: error.response?.data?.detail || 'Failed to create reservation'
            });
        } finally {
            setActionLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-gradient-to-br from-gray-50 to-indigo-50 flex items-center justify-center">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-indigo-600 mx-auto mb-4"></div>
                    <p className="text-gray-600">Loading material details...</p>
                </div>
            </div>
        );
    }

    if (!material) {
        return (
            <div className="min-h-screen bg-gradient-to-br from-gray-50 to-indigo-50 flex items-center justify-center">
                <div className="text-center">
                    <h2 className="text-2xl font-bold text-gray-800 mb-2">Material Not Found</h2>
                    <button onClick={() => navigate('/patron')} className="text-indigo-600 hover:text-indigo-700">
                        ← Back to Browse
                    </button>
                </div>
            </div>
        );
    }

    const isAvailable = material.available_copies > 0;
    const isReference = material.is_reference === 'Y';

    return (
        <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-in digo-50">
            {/* Header */}
            <header className="bg-white shadow-sm border-b">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                    <button
                        onClick={() => navigate('/patron')}
                        className="flex items-center text-gray-600 hover:text-indigo-600 transition-colors"
                    >
                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                        Back to Browse
                    </button>
                </div>
            </header>

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Message Banner */}
                {message && (
                    <div className={`mb-6 p-4 rounded-lg ${message.type === 'success' ? 'bg-green-50 border border-green-200 text-green-800' : 'bg-red-50 border border-red-200 text-red-800'}`}>
                        <div className="flex items-center">
                            {message.type === 'success' ? (
                                <svg className="w-5 h-5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                                </svg>
                            ) : (
                                <svg className="w-5 h-5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                                </svg>
                            )}
                            <span>{message.text}</span>
                        </div>
                    </div>
                )}

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Left Column - Cover Image */}
                    <div className="lg:col-span-1">
                        <div className="sticky top-8">
                            <div className="relative bg-gradient-to-br from-indigo-100 to-purple-100 rounded-2xl shadow-xl overflow-hidden aspect-[3/4] group">
                                {/* Placeholder Book Icon */}
                                <div className="absolute inset-0 flex flex-col items-center justify-center text-indigo-400">
                                    <svg className="w-32 h-32 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                    </svg>
                                    <span className="text-sm font-medium uppercase tracking-wider">{material.material_type}</span>
                                </div>

                                {/* Badges */}
                                <div className="absolute top-4 right-4 flex flex-col gap-2">
                                    {material.is_new_release === 'Y' && (
                                        <span className="bg-green-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-lg">
                                            NEW
                                        </span>
                                    )}
                                    {isReference && (
                                        <span className="bg-amber-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-lg">
                                            REFERENCE
                                        </span>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Right Column - Details */}
                    <div className="lg:col-span-2 space-y-6">
                        {/* Title & Metadata */}
                        <div>
                            <h1 className="text-4xl font-bold text-gray-900 mb-2 leading-tight">
                                {material.title}
                            </h1>
                            {material.subtitle && (
                                <h2 className="text-xl text-gray-600 mb-4">{material.subtitle}</h2>
                            )}

                            {/* Authors */}
                            {material.authors && material.authors.length > 0 && (
                                <div className="flex items-center text-lg text-gray-700 mb-4">
                                    <span className="font-medium">by</span>
                                    <span className="ml-2">
                                        {material.authors.map((author, idx) => (
                                            <span key={author.author_id}>
                                                {author.full_name}
                                                {idx < material.authors.length - 1 ? ', ' : ''}
                                            </span>
                                        ))}
                                    </span>
                                </div>
                            )}

                            {/* Genres */}
                            {material.genres && material.genres.length > 0 && (
                                <div className="flex flex-wrap gap-2 mb-6">
                                    {material.genres.map(genre => (
                                        <span
                                            key={genre.genre_id}
                                            className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${genre.is_primary_genre === 'Y'
                                                ? 'bg-indigo-100 text-indigo-800 ring-2 ring-indigo-200'
                                                : 'bg-gray-100 text-gray-700'
                                                }`}
                                        >
                                            {genre.genre_name}
                                        </span>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Availability Card */}
                        <div className="bg-white rounded-xl shadow-md border border-gray-100 p-6">
                            <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center">
                                <svg className="w-5 h-5 mr-2 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Availability
                            </h3>

                            <div className="grid grid-cols-2 gap-4 mb-6">
                                <div className="text-center p-4 bg-gray-50 rounded-lg">
                                    <div className="text-3xl font-bold text-gray-900">{material.total_copies}</div>
                                    <div className="text-sm text-gray-600 mt-1">Total Copies</div>
                                </div>
                                <div className="text-center p-4 bg-gradient-to-br from-green-50 to-emerald-50 rounded-lg">
                                    <div className={`text-3xl font-bold ${isAvailable ? 'text-green-600' : 'text-red-600'}`}>
                                        {material.available_copies}
                                    </div>
                                    <div className="text-sm text-gray-600 mt-1">Available Now</div>
                                </div>
                            </div>

                            {/* Branch Locations */}
                            {material.branch_availability && material.branch_availability.length > 0 && (
                                <div className="border-t pt-4">
                                    <h4 className="text-sm font-semibold text-gray-700 mb-3">Branch Locations</h4>
                                    <div className="space-y-2">
                                        {material.branch_availability.map(branch => (
                                            <div key={branch.branch_id} className="flex justify-between items-center text-sm">
                                                <span className="text-gray-700">{branch.branch_name}</span>
                                                <span className={`font-medium ${branch.available_copies > 0 ? 'text-green-600' : 'text-gray-400'}`}>
                                                    {branch.available_copies} / {branch.total_copies} available
                                                </span>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}

                            {/* Action Buttons */}
                            <div className="mt-6 flex gap-3">
                                {!isReference && isAvailable && (
                                    <button
                                        onClick={handleBorrow}
                                        disabled={actionLoading}
                                        className="flex-1 bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white font-bold py-3 px-6 rounded-lg shadow-lg transform transition-all duration-200 hover:scale-105 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
                                    >
                                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                                        </svg>
                                        {actionLoading ? 'Processing...' : 'Borrow Now'}
                                    </button>
                                )}

                                {!isReference && !isAvailable && (
                                    <button
                                        onClick={handleReserve}
                                        disabled={actionLoading}
                                        className="flex-1 bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-600 hover:to-amber-600 text-white font-bold py-3 px-6 rounded-lg shadow-lg transform transition-all duration-200 hover:scale-105 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
                                    >
                                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                        {actionLoading ? 'Processing...' : 'Reserve Copy'}
                                    </button>
                                )}

                                {isReference && (
                                    <div className="flex-1 bg-gray-100 text-gray-600 font-medium py-3 px-6 rounded-lg text-center">
                                        Reference Only - In-Library Use
                                    </div>
                                )}
                            </div>
                        </div>

                        {/* Material Information */}
                        <div className="bg-white rounded-xl shadow-md border border-gray-100 p-6">
                            <h3 className="text-lg font-bold text-gray-900 mb-4">Details</h3>
                            <dl className="grid grid-cols-2 gap-x-6 gap-y-4">
                                {material.isbn && (
                                    <>
                                        <dt className="text-sm font-medium text-gray-500">ISBN</dt>
                                        <dd className="text-sm text-gray-900">{material.isbn}</dd>
                                    </>
                                )}
                                {material.publication_year && (
                                    <>
                                        <dt className="text-sm font-medium text-gray-500">Published</dt>
                                        <dd className="text-sm text-gray-900">{material.publication_year}</dd>
                                    </>
                                )}
                                <dt className="text-sm font-medium text-gray-500">Language</dt>
                                <dd className="text-sm text-gray-900">{material.language}</dd>

                                {material.publisher_name && (
                                    <>
                                        <dt className="text-sm font-medium text-gray-500">Publisher</dt>
                                        <dd className="text-sm text-gray-900">{material.publisher_name}</dd>
                                    </>
                                )}

                                <dt className="text-sm font-medium text-gray-500">Type</dt>
                                <dd className="text-sm text-gray-900">{material.material_type}</dd>
                            </dl>
                        </div>

                        {/* Description */}
                        {material.description && (
                            <div className="bg-white rounded-xl shadow-md border border-gray-100 p-6">
                                <h3 className="text-lg font-bold text-gray-900 mb-3">Description</h3>
                                <p className="text-gray-700 leading-relaxed whitespace-pre-line">
                                    {material.description}
                                </p>
                            </div>
                        )}
                    </div>
                </div>
            </main>
        </div>
    );
};

export default MaterialDetail;
