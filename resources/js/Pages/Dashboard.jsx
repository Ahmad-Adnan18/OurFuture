import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import Card from '@/Components/Card';
import ProgressBar from '@/Components/ProgressBar';

export default function Dashboard({ auth, totalAssets, unallocatedFunds, activeGoals, recentTransactions }) {
    const formatCurrency = (amount) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(amount);
    
    // Greeting Logic
    const hour = new Date().getHours();
    const greeting = hour < 12 ? 'Good Morning' : hour < 18 ? 'Good Afternoon' : 'Good Evening';

    // Helper to get transaction icon/color based on type
    const getTypeStyles = (type) => {
        switch (type) {
            case 'deposit': 
                return { 
                    bg: 'bg-emerald-100 text-emerald-600 dark:bg-emerald-900/30 dark:text-emerald-400',
                    icon: <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
                };
            case 'expense': 
                return {
                    bg: 'bg-rose-100 text-rose-600 dark:bg-rose-900/30 dark:text-rose-400',
                    icon: <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 7.5L12 3 7.5 7.5m4.5 9V3" />
                };
            case 'withdrawal': 
                return {
                    bg: 'bg-amber-100 text-amber-600 dark:bg-amber-900/30 dark:text-amber-400',
                    icon: <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75" />
                };
            default: 
                return {
                    bg: 'bg-slate-100 text-slate-600 dark:bg-slate-700 dark:text-slate-400',
                    icon: <path strokeLinecap="round" strokeLinejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5" />
                };
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <div className="flex flex-col md:flex-row justify-between md:items-center gap-4">
                    <div>
                        <h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">
                             {greeting}, {auth.user.name.split(' ')[0]}!
                        </h2>
                        <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
                            {new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                        </p>
                    </div>
                </div>
            }
        >
            <Head title="Dashboard" />

            <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                {/* Asset Summary Cards - Enhanced */}
                <Card className="relative overflow-hidden !bg-gradient-to-br !from-emerald-500 !to-emerald-700 !text-white !p-0 border-0 shadow-lg shadow-emerald-500/30">
                    <div className="absolute top-0 right-0 p-4 opacity-10">
                         <svg className="w-32 h-32" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                         </svg>
                    </div>
                    <div className="relative p-6 z-10">
                         <h3 className="text-sm font-medium text-emerald-100 mb-1">Total Assets</h3>
                        <p className="text-4xl font-bold tracking-tight">
                            {formatCurrency(totalAssets)}
                        </p>
                        <p className="mt-4 text-xs font-medium text-emerald-100 inline-flex items-center gap-1 bg-emerald-600/50 px-2 py-1 rounded-full border border-emerald-400/30">
                            <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" strokeWidth="3" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M12 19.5v-15m0 0l-6.75 6.75M12 4.5l6.75 6.75" />
                            </svg>
                            Updated just now
                        </p>
                    </div>
                </Card>

                <Card className="relative overflow-hidden !bg-gradient-to-br !from-slate-800 !to-slate-900 !text-white !p-0 border-0 shadow-md">
                   <div className="absolute top-0 right-0 p-4 opacity-5">
                         <svg className="w-32 h-32" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M21 12a2.25 2.25 0 00-2.25-2.25H15a3 3 0 11-6 0H5.25A2.25 2.25 0 003 12m18 0v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 9m18 0V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v3" />
                         </svg>
                    </div>
                    <div className="relative p-6 z-10">
                        <h3 className="text-sm font-medium text-slate-400 mb-1">Unallocated Funds</h3>
                        <p className="text-4xl font-bold tracking-tight text-white dark:text-emerald-400">
                             {formatCurrency(unallocatedFunds)}
                        </p>
                        <div className="mt-4 flex gap-2">
                             <p className="text-xs text-slate-300">Available to be assigned to goals.</p>
                             {unallocatedFunds > 0 && (
                                <Link href={route('transactions.create', { type: 'deposit' })} className="text-xs font-bold text-emerald-400 hover:text-emerald-300 underline">Allocate Now</Link>
                             )}
                        </div>
                    </div>
                </Card>
            </div>

            <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Active Goals */}
                <div>
                     <div className="flex justify-between items-center mb-4 px-1">
                        <h3 className="text-lg font-bold text-slate-800 dark:text-slate-200">Active Goals</h3>
                        <Link href={route('goals.index')} className="text-sm text-emerald-600 hover:text-emerald-700 font-medium flex items-center gap-1 group">
                            View All 
                            <svg className="w-4 h-4 transition-transform group-hover:translate-x-1" viewBox="0 0 20 20" fill="currentColor">
                                <path fillRule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clipRule="evenodd" />
                            </svg>
                        </Link>
                    </div>
                    
                    <div className="flex flex-col gap-4">
                        {activeGoals.length === 0 ? (
                             <Card className="text-center py-12 flex flex-col items-center justify-center border-dashed border-2 border-slate-200 dark:border-slate-700 bg-transparent shadow-none">
                                <div className="p-3 bg-slate-50 dark:bg-slate-800 rounded-full mb-3">
                                   <svg className="w-8 h-8 text-slate-400" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor">
                                     <path strokeLinecap="round" strokeLinejoin="round" d="M3 3v1.5M3 21v-6m0 0l2.77-.693a9 9 0 016.208.682l.108.054a9 9 0 006.086.71l3.114-.732a48.524 48.524 0 01-.005-10.499l-3.11.732a9 9 0 01-6.085-.711l-.108-.054a9 9 0 00-6.208-.682L3 4.5M3 15V4.5" />
                                   </svg>
                                </div>
                                <p className="text-slate-500 dark:text-slate-400">You have no active goals.</p>
                                <Link href={route('goals.index')} className="text-emerald-600 font-bold hover:underline mt-1">Create your first goal</Link>
                             </Card>
                        ) : (
                            activeGoals.slice(0, 3).map((goal) => (
                                <Card key={goal.id} className="!p-5 hover:shadow-md transition-shadow cursor-pointer group border border-slate-100 dark:border-slate-800">
                                    <div className="flex justify-between items-center mb-3">
                                        <div className="flex items-center gap-3">
                                            <div className="w-10 h-10 rounded-full bg-indigo-50 dark:bg-indigo-900/20 flex items-center justify-center text-indigo-600 dark:text-indigo-400">
                                                 <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                                                   <path strokeLinecap="round" strokeLinejoin="round" d="M3 3v1.5M3 21v-6m0 0l2.77-.693a9 9 0 016.208.682l.108.054a9 9 0 006.086.71l3.114-.732a48.524 48.524 0 01-.005-10.499l-3.11.732a9 9 0 01-6.085-.711l-.108-.054a9 9 0 00-6.208-.682L3 4.5M3 15V4.5" />
                                                 </svg>
                                            </div>
                                            <h4 className="font-bold text-slate-800 dark:text-white truncate text-base">{goal.title}</h4>
                                        </div>
                                        <span className="text-xs font-bold bg-slate-100 dark:bg-slate-700 text-slate-600 dark:text-slate-400 px-2.5 py-1 rounded-full">{Math.round(goal.progress_percent)}%</span>
                                    </div>
                                    <ProgressBar percent={goal.progress_percent} />
                                    <div className="flex justify-between text-xs mt-3 text-slate-500 font-medium">
                                        <span className="text-slate-700 dark:text-slate-300">{formatCurrency(goal.current_balance)}</span>
                                        <span className="opacity-70">Target: {formatCurrency(goal.target_amount)}</span>
                                    </div>
                                </Card>
                            ))
                        )}
                    </div>
                </div>

                {/* Recent Transactions */}
                <div>
                    <div className="flex justify-between items-center mb-4 px-1">
                        <h3 className="text-lg font-bold text-slate-800 dark:text-slate-200">Recent Activity</h3>
                        <Link href={route('transactions.index')} className="text-sm text-emerald-600 hover:text-emerald-700 font-medium flex items-center gap-1 group">
                            View All
                             <svg className="w-4 h-4 transition-transform group-hover:translate-x-1" viewBox="0 0 20 20" fill="currentColor">
                                <path fillRule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clipRule="evenodd" />
                            </svg>
                        </Link>
                    </div>

                    <div className="space-y-3">
                        {recentTransactions.length === 0 ? (
                             <Card className="text-center py-12 flex flex-col items-center justify-center border-dashed border-2 border-slate-200 dark:border-slate-700 bg-transparent shadow-none">
                                <div className="p-3 bg-slate-50 dark:bg-slate-800 rounded-full mb-3">
                                   <svg className="w-8 h-8 text-slate-400" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor">
                                     <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
                                   </svg>
                                </div>
                                <p className="text-slate-500 dark:text-slate-400">No transactions yet.</p>
                                <Link href={route('transactions.create')} className="text-emerald-600 font-bold hover:underline mt-1">Record your first expense</Link>
                             </Card>
                        ) : (
                            recentTransactions.map((tx) => {
                                const styles = getTypeStyles(tx.type);
                                return (
                                    <div key={tx.id} className="relative group bg-white dark:bg-slate-800 p-4 rounded-xl shadow-sm border border-slate-100 dark:border-slate-800 hover:border-emerald-500/30 flex items-center justify-between transition-all">
                                        <div className="flex items-center gap-4 min-w-0 flex-1 mr-4">
                                            <div className={`p-3 rounded-full ${styles.bg} shrink-0`}>
                                                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                                                    {styles.icon}
                                                </svg>
                                            </div>
                                            <div className="min-w-0">
                                                <p className="font-semibold text-sm text-slate-900 dark:text-slate-100 capitalize truncate">
                                                    {tx.notes || tx.type}
                                                </p>
                                                <p className="text-xs text-slate-500 mt-0.5 flex items-center gap-1">
                                                    <span>{new Date(tx.date).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' })}</span>
                                                    <span>•</span>
                                                    <span className="truncate max-w-[100px]">{tx.storage_account?.name}</span>
                                                </p>
                                            </div>
                                        </div>
                                        <div className={`font-bold text-sm whitespace-nowrap ${['expense', 'withdrawal'].includes(tx.type) ? 'text-slate-900 dark:text-white' : 'text-emerald-600'}`}>
                                            {formatCurrency(tx.amount)}
                                        </div>
                                    </div>
                                );
                            })
                        )}
                    </div>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}
