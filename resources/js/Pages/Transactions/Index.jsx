import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import Card from '@/Components/Card';
import { Fragment } from 'react';

export default function TransactionsIndex({ auth, transactions }) {
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
            default: return 'text-slate-600 bg-slate-50';
        }
    };

    const formatCurrency = (amount) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(amount);
    const formatDate = (dateString) => new Date(dateString).toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <div className="flex justify-between items-center">
                    <h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">Bookkeeping</h2>
                    <Link
                        href={route('transactions.create')}
                        className="bg-emerald-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-emerald-700 transition"
                    >
                        New Transaction
                    </Link>
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
        </AuthenticatedLayout>
    );
}
