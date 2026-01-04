import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import Card from '@/Components/Card';
import { Fragment, useState } from 'react';

export default function TransactionsIndex({ auth, transactions }) {
    const [exporting, setExporting] = useState(false);
    const [showExportModal, setShowExportModal] = useState(false);
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');

    // Utility to group transactions by date
    const groupedTransactions = transactions.data.reduce((groups, transaction) => {
        const date = transaction.date;
        if (!groups[date]) {
            groups[date] = [];
        }
        groups[date].push(transaction);
        return groups;
    }, {});

    const sortedDates = Object.keys(groupedTransactions).sort((a, b) => new Date(b) - new Date(a));

    const getTypeColor = (type) => {
        switch (type) {
            case 'deposit': return 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20';
            case 'adjustment': return 'text-sky-600 bg-sky-50 dark:bg-sky-900/20';
            case 'expense': return 'text-rose-600 bg-rose-50 dark:bg-rose-900/20';
            case 'withdrawal': return 'text-amber-600 bg-amber-50 dark:bg-amber-900/20';
            case 'allocate': return 'text-violet-600 bg-violet-50 dark:bg-violet-900/20';
            default: return 'text-slate-600 bg-slate-50';
        }
    };

    const formatCurrency = (amount) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(amount);
    const formatDate = (dateString) => new Date(dateString).toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });

    const handleExport = () => {
        setExporting(true);
        const params = new URLSearchParams();
        if (startDate) params.append('start_date', startDate);
        if (endDate) params.append('end_date', endDate);
        
        window.location.href = `/export/transactions?${params.toString()}`;
        
        setTimeout(() => {
            setExporting(false);
            setShowExportModal(false);
        }, 1000);
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <div className="flex justify-between items-center">
                    <h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">Bookkeeping</h2>
                    <div className="flex gap-2">
                        <button
                            onClick={() => setShowExportModal(true)}
                            className="bg-slate-100 text-slate-700 px-4 py-2 rounded-lg text-sm font-medium hover:bg-slate-200 transition dark:bg-slate-700 dark:text-slate-200 dark:hover:bg-slate-600"
                        >
                            📤 Export
                        </button>
                        <Link
                            href={route('transactions.create')}
                            className="bg-emerald-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-emerald-700 transition"
                        >
                            New Transaction
                        </Link>
                    </div>
                </div>
            }
        >
            <Head title="Transactions" />

            {transactions.data.length === 0 ? (
                <div className="text-center py-10 text-slate-500">
                    No transactions found. Start by recording one!
                </div>
            ) : (
                <div className="space-y-6">
                    {sortedDates.map((date) => (
                        <div key={date}>
                            <h3 className="text-sm font-bold text-slate-500 uppercase tracking-wider mb-2 sticky top-16 bg-slate-50 dark:bg-slate-900 py-2 z-10">
                                {formatDate(date)}
                            </h3>
                            <div className="space-y-3">
                                {groupedTransactions[date].map((tx) => (
                                    <Card key={tx.id} className="!p-4 flex items-center justify-between shadow-sm hover:shadow transition">
                                        <div className="flex items-center gap-3">
                                            {/* User Profile Photo */}
                                            <div className="h-10 w-10 shrink-0 overflow-hidden rounded-full bg-slate-200 ring-2 ring-offset-2 ring-offset-white dark:ring-offset-slate-800" style={{ '--tw-ring-color': tx.type === 'deposit' || tx.type === 'adjustment' ? '#10b981' : tx.type === 'expense' ? '#f43f5e' : '#f59e0b' }}>
                                                {tx.user?.profile_photo_url ? (
                                                    <img 
                                                        src={tx.user.profile_photo_url} 
                                                        alt={tx.user.name} 
                                                        className="h-full w-full object-cover object-center" 
                                                    />
                                                ) : (
                                                    <div className="h-full w-full flex items-center justify-center text-slate-400 text-sm font-medium">
                                                        {tx.user?.name?.charAt(0)?.toUpperCase() || '?'}
                                                    </div>
                                                )}
                                            </div>
                                            <div>
                                                <p className="font-semibold text-slate-800 dark:text-slate-200 capitalize">
                                                    {tx.notes || tx.type}
                                                </p>
                                                <div className="text-xs text-slate-500 flex gap-2">
                                                    <span>{tx.storage_account?.name}</span>
                                                    {tx.goal && (
                                                        <>
                                                            <span>•</span>
                                                            <span className="text-emerald-600">{tx.goal.title}</span>
                                                        </>
                                                    )}
                                                </div>
                                            </div>
                                        </div>
                                        <div className={`font-bold ${
                                            ['expense', 'withdrawal'].includes(tx.type) || (tx.type === 'adjustment' && tx.amount < 0)
                                                ? 'text-slate-900 dark:text-white' 
                                                : 'text-emerald-600'
                                        }`}>
                                            {['expense', 'withdrawal'].includes(tx.type) || (tx.type === 'adjustment' && tx.amount < 0) ? '-' : '+'} {formatCurrency(Math.abs(tx.amount))}
                                        </div>
                                    </Card>
                                ))}
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Export Modal */}
            {showExportModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-white dark:bg-slate-800 rounded-2xl p-6 w-full max-w-md mx-4 shadow-xl">
                        <h3 className="text-lg font-bold text-slate-800 dark:text-white mb-4">📤 Export Transactions</h3>
                        
                        <div className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Start Date (Optional)</label>
                                <input
                                    type="date"
                                    value={startDate}
                                    onChange={(e) => setStartDate(e.target.value)}
                                    className="w-full rounded-lg border-slate-300 dark:border-slate-600 dark:bg-slate-700 dark:text-white"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">End Date (Optional)</label>
                                <input
                                    type="date"
                                    value={endDate}
                                    onChange={(e) => setEndDate(e.target.value)}
                                    className="w-full rounded-lg border-slate-300 dark:border-slate-600 dark:bg-slate-700 dark:text-white"
                                />
                            </div>
                            <p className="text-xs text-slate-500">Leave empty to export all transactions.</p>
                        </div>

                        <div className="flex gap-3 mt-6">
                            <button
                                onClick={() => setShowExportModal(false)}
                                className="flex-1 px-4 py-2 text-slate-700 bg-slate-100 rounded-lg hover:bg-slate-200 dark:bg-slate-700 dark:text-slate-200"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleExport}
                                disabled={exporting}
                                className="flex-1 px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 disabled:opacity-50"
                            >
                                {exporting ? 'Downloading...' : 'Download PDF'}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </AuthenticatedLayout>
    );
}
