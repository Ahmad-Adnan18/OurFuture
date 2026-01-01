import { useState } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, router } from '@inertiajs/react'; // Import router for manual visits if needed
import Card from '@/Components/Card';
import MoneyInput from '@/Components/MoneyInput';
import { Dialog, Transition } from '@headlessui/react';
import { Fragment } from 'react';

export default function StorageIndex({ auth, accounts }) {
    const [isOpen, setIsOpen] = useState(false);
    const [editingAccount, setEditingAccount] = useState(null);

    const { data, setData, post, put, delete: destroy, processing, errors, reset, clearErrors } = useForm({
        name: '',
        type: 'bank',
        balance: '',
    });

    const openModal = (account = null) => {
        setEditingAccount(account);
        if (account) {
            setData({
                name: account.name,
                type: account.type,
                balance: account.balance,
            });
        } else {
            reset();
        }
        clearErrors();
        setIsOpen(true);
    };

    const closeModal = () => {
        setIsOpen(false);
        setEditingAccount(null);
        reset();
    };

    const submit = (e) => {
        e.preventDefault();
        if (editingAccount) {
            put(route('storage.update', editingAccount.id), {
                onSuccess: closeModal,
            });
        } else {
            post(route('storage.store'), {
                onSuccess: closeModal,
            });
        }
    };

    const handleDelete = (account) => {
        if (confirm('Are you sure you want to delete this account?')) {
            destroy(route('storage.destroy', account.id));
        }
    };

    // Calculate total balance
    const totalBalance = accounts.reduce((sum, account) => sum + parseFloat(account.balance), 0);

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <div className="flex justify-between items-center">
                    <h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">Storage Accounts</h2>
                    <button
                        onClick={() => openModal()}
                        className="bg-emerald-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-emerald-700 transition"
                    >
                        Add New Account
                    </button>
                </div>
            }
        >
            <Head title="Storage Accounts" />

            {/* Summary Card */}
            <div className="mb-6">
                <Card className="bg-gradient-to-br from-slate-900 to-slate-800 text-white border-none">
                    <h3 className="text-slate-400 text-sm font-medium">Total Liquidity</h3>
                    <p className="text-3xl font-bold mt-1">
                         {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR' }).format(totalBalance)}
                    </p>
                </Card>
            </div>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {accounts.map((account) => (
                    <Card key={account.id} className="relative group">
                        <div className="flex justify-between items-start">
                            <div>
                                <h3 className="font-bold text-lg text-slate-800 dark:text-slate-100">{account.name}</h3>
                                <span className="inline-block bg-slate-100 dark:bg-slate-700 text-slate-600 dark:text-slate-400 text-xs px-2 py-1 rounded capitalize mt-1">
                                    {account.type}
                                </span>
                            </div>
                            <div className="text-right">
                                <p className="font-bold text-emerald-600 text-lg">
                                    {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR' }).format(account.balance)}
                                </p>
                            </div>
                        </div>
                        
                        <div className="mt-4 flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button 
                                onClick={() => openModal(account)}
                                className="text-sm text-slate-500 hover:text-emerald-600"
                            >
                                Edit
                            </button>
                            <button 
                                onClick={() => handleDelete(account)}
                                className="text-sm text-rose-500 hover:text-rose-700"
                            >
                                Delete
                            </button>
                        </div>
                    </Card>
                ))}
            </div>

            {/* Create/Edit Modal */}
            <Transition appear show={isOpen} as={Fragment}>
                <Dialog as="div" className="relative z-10" onClose={closeModal}>
                    <Transition.Child
                        as={Fragment}
                        enter="ease-out duration-300"
                        enterFrom="opacity-0"
                        enterTo="opacity-100"
                        leave="ease-in duration-200"
                        leaveFrom="opacity-100"
                        leaveTo="opacity-0"
                    >
                        <div className="fixed inset-0 bg-black/25" />
                    </Transition.Child>

                    <div className="fixed inset-0 overflow-y-auto">
                        <div className="flex min-h-full items-center justify-center p-4 text-center">
                            <Transition.Child
                                as={Fragment}
                                enter="ease-out duration-300"
                                enterFrom="opacity-0 scale-95"
                                enterTo="opacity-100 scale-100"
                                leave="ease-in duration-200"
                                leaveFrom="opacity-100 scale-100"
                                leaveTo="opacity-0 scale-95"
                            >
                                <Dialog.Panel className="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all dark:bg-slate-800">
                                    <Dialog.Title
                                        as="h3"
                                        className="text-lg font-medium leading-6 text-slate-900 dark:text-white"
                                    >
                                        {editingAccount ? 'Edit Account' : 'Add New Account'}
                                    </Dialog.Title>
                                    
                                    <form onSubmit={submit} className="mt-4 space-y-4">
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Name</label>
                                            <input
                                                type="text"
                                                className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                                value={data.name}
                                                onChange={(e) => setData('name', e.target.value)}
                                                required
                                            />
                                            {errors.name && <p className="text-sm text-rose-500 mt-1">{errors.name}</p>}
                                        </div>

                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Type</label>
                                            <select
                                                className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                                value={data.type}
                                                onChange={(e) => setData('type', e.target.value)}
                                            >
                                                <option value="bank">Bank</option>
                                                <option value="e-wallet">E-Wallet</option>
                                                <option value="investment">Investment</option>
                                                <option value="cash">Cash</option>
                                            </select>
                                            {errors.type && <p className="text-sm text-rose-500 mt-1">{errors.type}</p>}
                                        </div>

                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Balance</label>
                                            <MoneyInput
                                                name="balance"
                                                value={data.balance}
                                                onChange={(e) => setData('balance', e.target.value)}
                                                required
                                            />
                                            {errors.balance && <p className="text-sm text-rose-500 mt-1">{errors.balance}</p>}
                                        </div>

                                        <div className="mt-6 flex justify-end gap-3">
                                            <button
                                                type="button"
                                                className="px-4 py-2 text-sm font-medium text-slate-700 bg-slate-100 rounded-md hover:bg-slate-200 dark:bg-slate-700 dark:text-slate-200 dark:hover:bg-slate-600"
                                                onClick={closeModal}
                                            >
                                                Cancel
                                            </button>
                                            <button
                                                type="submit"
                                                className="px-4 py-2 text-sm font-medium text-white bg-emerald-600 rounded-md hover:bg-emerald-700 disabled:opacity-50"
                                                disabled={processing}
                                            >
                                                {editingAccount ? 'Update' : 'Create'}
                                            </button>
                                        </div>
                                    </form>
                                </Dialog.Panel>
                            </Transition.Child>
                        </div>
                    </div>
                </Dialog>
            </Transition>
        </AuthenticatedLayout>
    );
}
