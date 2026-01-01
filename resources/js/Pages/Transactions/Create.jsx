import { useState, useEffect } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, Link } from '@inertiajs/react';
import Card from '@/Components/Card';
import MoneyInput from '@/Components/MoneyInput';

export default function TransactionCreate({ auth, storageAccounts, goals }) {
    const { data, setData, post, processing, errors } = useForm({
        date: new Date().toISOString().split('T')[0],
        type: 'expense',
        amount: '',
        storage_account_id: storageAccounts.length > 0 ? storageAccounts[0].id : '',
        goal_id: '',
        notes: '',
    });

    const [availableBalance, setAvailableBalance] = useState(0);

    // Update available balance warning logic
    useEffect(() => {
        const account = storageAccounts.find(acc => acc.id == data.storage_account_id);
        if (account) {
            setAvailableBalance(parseFloat(account.balance));
        }
    }, [data.storage_account_id, storageAccounts]);

    const isExpenseOrWithdrawal = ['expense', 'withdrawal'].includes(data.type);
    const insufficientBalance = isExpenseOrWithdrawal && data.amount > availableBalance;

    const submit = (e) => {
        e.preventDefault();
        post(route('transactions.store'));
    };

    const types = [
        { id: 'deposit', label: 'Income / Deposit', color: 'bg-emerald-100 text-emerald-700 ring-emerald-600' },
        { id: 'expense', label: 'Expense', color: 'bg-rose-100 text-rose-700 ring-rose-600' },
        { id: 'withdrawal', label: 'Withdrawal', color: 'bg-amber-100 text-amber-700 ring-amber-600' },
        { id: 'adjustment', label: 'Adjustment', color: 'bg-sky-100 text-sky-700 ring-sky-600' },
    ];

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">New Transaction</h2>}
        >
            <Head title="New Transaction" />

            <div className="max-w-xl mx-auto">
                <Card>
                    <form onSubmit={submit} className="space-y-6">
                        {/* Type Selector */}
                        <div>
                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Transaction Type</label>
                            <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
                                {types.map((type) => (
                                    <button
                                        key={type.id}
                                        type="button"
                                        onClick={() => setData('type', type.id)}
                                        className={`px-3 py-2 text-sm font-medium rounded-md border ${
                                            data.type === type.id
                                                ? `border-transparent ring-2 ${type.color}`
                                                : 'border-slate-200 bg-white text-slate-600 hover:bg-slate-50 dark:bg-slate-800 dark:border-slate-700 dark:text-slate-400'
                                        }`}
                                    >
                                        {type.label}
                                    </button>
                                ))}
                            </div>
                            {errors.type && <p className="text-sm text-rose-500 mt-1">{errors.type}</p>}
                        </div>

                        {/* Amount */}
                        <div>
                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Amount</label>
                            <div className="relative mt-1">
                                <MoneyInput
                                    name="amount"
                                    value={data.amount}
                                    onChange={(e) => setData('amount', e.target.value)}
                                    required
                                    className="text-2xl font-bold py-3"
                                    placeholder="Rp 0"
                                />
                            </div>
                            {errors.amount && <p className="text-sm text-rose-500 mt-1">{errors.amount}</p>}
                            {insufficientBalance && (
                                <p className="text-sm text-rose-600 mt-1 font-medium">
                                    ⚠️ Try not to exceed available balance ({new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR' }).format(availableBalance)})
                                </p>
                            )}
                        </div>

                        {/* Storage Account */}
                        <div>
                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Wallet / Account</label>
                            <select
                                className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                value={data.storage_account_id}
                                onChange={(e) => setData('storage_account_id', e.target.value)}
                                required
                            >
                                <option value="" disabled>Select Account</option>
                                {storageAccounts.map((acc) => (
                                    <option key={acc.id} value={acc.id}>
                                        {acc.name} ({new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR' }).format(acc.balance)})
                                    </option>
                                ))}
                            </select>
                            {errors.storage_account_id && <p className="text-sm text-rose-500 mt-1">{errors.storage_account_id}</p>}
                        </div>

                        {/* Goal Selection - Conditional */}
                        {/* Logic: 
                            - Deposit: Optional (Unallocated if empty)
                            - Expense: Required (Must pick a goal)
                            - Withdrawal: Required (Which goal to pull back from?)
                            - Adjustment: Disabled/Hidden
                         */}
                        {data.type !== 'adjustment' && (
                            <div className={`transition-all duration-300 ${data.type === 'adjustment' ? 'opacity-50 grayscale' : ''}`}>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">
                                    Allocation Goal {data.type === 'expense' || data.type === 'withdrawal' ? <span className="text-rose-500">*</span> : <span className="text-slate-400 font-normal">(Optional)</span>}
                                </label>
                                <select
                                    className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                    value={data.goal_id}
                                    onChange={(e) => setData('goal_id', e.target.value)}
                                    disabled={data.type === 'adjustment'}
                                    required={['expense', 'withdrawal'].includes(data.type)}
                                >
                                    <option value="">
                                        {['deposit'].includes(data.type) ? 'Unallocated (Dana Bebas)' : 'Select Goal'}
                                    </option>
                                    {goals.map((goal) => (
                                        <option key={goal.id} value={goal.id}>
                                            {goal.title}
                                        </option>
                                    ))}
                                </select>
                                {errors.goal_id && <p className="text-sm text-rose-500 mt-1">{errors.goal_id}</p>}
                                <p className="text-xs text-slate-500 mt-1">
                                    {data.type === 'deposit' && "Leave empty if this money is not for a specific goal yet."}
                                    {data.type === 'expense' && "Which goal is this expense for?"}
                                </p>
                            </div>
                        )}

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Date</label>
                                <input
                                    type="date"
                                    className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                    value={data.date}
                                    onChange={(e) => setData('date', e.target.value)}
                                    required
                                />
                                {errors.date && <p className="text-sm text-rose-500 mt-1">{errors.date}</p>}
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Notes</label>
                            <textarea
                                className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                value={data.notes}
                                onChange={(e) => setData('notes', e.target.value)}
                                rows="3"
                                placeholder="Optional notes..."
                            ></textarea>
                            {errors.notes && <p className="text-sm text-rose-500 mt-1">{errors.notes}</p>}
                        </div>

                        <div className="flex justify-end gap-3 pt-4 border-t border-slate-100 dark:border-slate-700">
                            <Link
                                href={route('dashboard')}
                                className="px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-300 rounded-md hover:bg-slate-50 dark:bg-slate-800 dark:text-slate-200 dark:border-slate-600 dark:hover:bg-slate-700 shadow-sm"
                            >
                                Cancel
                            </Link>
                            <button
                                type="submit"
                                className="px-6 py-2 text-sm font-medium text-white bg-emerald-600 rounded-md hover:bg-emerald-700 shadow-sm disabled:opacity-50"
                                disabled={processing}
                            >
                                Save Transaction
                            </button>
                        </div>
                    </form>
                </Card>
            </div>
        </AuthenticatedLayout>
    );
}
