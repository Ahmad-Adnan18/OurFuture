import { useState } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, Link } from '@inertiajs/react';
import Card from '@/Components/Card';
import ProgressBar from '@/Components/ProgressBar';
import MoneyInput from '@/Components/MoneyInput';
import Badge from '@/Components/Badge';
import { Dialog, Transition } from '@headlessui/react';
import { Fragment } from 'react';

export default function GoalsIndex({ auth, goals, filters }) {
    const [isOpen, setIsOpen] = useState(false);
    const [editingGoal, setEditingGoal] = useState(null);

    const { data, setData, post, put, processing, errors, reset, clearErrors } = useForm({
        title: '',
        target_amount: '',
        estimated_date: '',
        start_date: new Date().toISOString().split('T')[0],
        status: 'active',
    });

    const openModal = (goal = null) => {
        setEditingGoal(goal);
        if (goal) {
            setData({
                title: goal.title,
                target_amount: goal.target_amount,
                estimated_date: goal.estimated_date || '',
                start_date: goal.start_date,
                status: goal.status,
            });
        } else {
            reset();
            setData('start_date', new Date().toISOString().split('T')[0]);
        }
        clearErrors();
        setIsOpen(true);
    };

    const closeModal = () => {
        setIsOpen(false);
        setEditingGoal(null);
        reset();
    };

    const submit = (e) => {
        e.preventDefault();
        if (editingGoal) {
            put(route('goals.update', editingGoal.id), {
                onSuccess: closeModal,
            });
        } else {
            post(route('goals.store'), {
                onSuccess: closeModal,
            });
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <div className="flex justify-between items-center">
                    <h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">Financial Goals</h2>
                    <button
                        onClick={() => openModal()}
                        className="bg-emerald-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-emerald-700 transition"
                    >
                        New Goal
                    </button>
                </div>
            }
        >
            <Head title="Goals" />

            {/* Tabs */}
            <div className="mb-6 border-b border-slate-200 dark:border-slate-700">
                <nav className="-mb-px flex space-x-8" aria-label="Tabs">
                    <Link
                        href={route('goals.index', { status: 'active' })}
                        className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${
                            filters.status === 'active'
                                ? 'border-emerald-500 text-emerald-600 dark:text-emerald-500'
                                : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300'
                        }`}
                    >
                        Active Goals
                    </Link>
                    <Link
                        href={route('goals.index', { status: 'archived' })}
                        className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${
                            filters.status === 'archived'
                                ? 'border-emerald-500 text-emerald-600 dark:text-emerald-500'
                                : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300'
                        }`}
                    >
                        Completed / Archived
                    </Link>
                </nav>
            </div>

            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
                {goals.map((goal) => (
                    <Card key={goal.id} className="relative flex flex-col h-full">
                        <div className="flex justify-between items-start mb-4">
                            <h3 className="font-bold text-lg text-slate-800 dark:text-slate-100 truncate pr-2">{goal.title}</h3>
                            <Badge color={goal.status === 'completed' ? 'emerald' : goal.status === 'active' ? 'emerald' : 'slate'}>
                                {goal.status}
                            </Badge>
                        </div>
                        
                        <div className="mb-2">
                             <div className="flex justify-between text-sm mb-1">
                                <span className="text-slate-500 dark:text-slate-400">Progress</span>
                                <span className="font-bold text-emerald-600">{Math.round(goal.progress_percent)}%</span>
                            </div>
                            <ProgressBar percent={goal.progress_percent} />
                        </div>

                        <div className="mt-4 grid grid-cols-2 gap-4 text-sm">
                            <div>
                                <p className="text-slate-500 dark:text-slate-400 text-xs">Collected</p>
                                <p className="font-semibold text-emerald-600">
                                    {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(goal.total_collected)}
                                </p>
                            </div>
                            <div className="text-right">
                                <p className="text-slate-500 dark:text-slate-400 text-xs">Target</p>
                                <p className="font-semibold text-slate-700 dark:text-slate-300">
                                    {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(goal.target_amount)}
                                </p>
                            </div>
                        </div>
                        
                         <div className="mt-2 pt-2 border-t border-slate-100 dark:border-slate-700">
                             <div className="flex justify-between items-center">
                                 <div>
                                     <p className="text-slate-500 dark:text-slate-400 text-xs">Available Balance</p>
                                     <p className="font-bold text-slate-800 dark:text-slate-200">
                                         {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(goal.current_balance)}
                                     </p>
                                 </div>
                                 <button 
                                    onClick={() => openModal(goal)}
                                    className="text-sm bg-slate-50 dark:bg-slate-700 hover:bg-slate-100 dark:hover:bg-slate-600 text-slate-600 dark:text-slate-300 px-3 py-1 rounded"
                                 >
                                    Values
                                 </button>
                             </div>
                         </div>
                    </Card>
                ))}
            </div>

            {/* Modal */}
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
                                        {editingGoal ? 'Edit Goal' : 'Create New Goal'}
                                    </Dialog.Title>
                                    
                                    <form onSubmit={submit} className="mt-4 space-y-4">
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Goal Title</label>
                                            <input
                                                type="text"
                                                className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                                value={data.title}
                                                onChange={(e) => setData('title', e.target.value)}
                                                required
                                            />
                                            {errors.title && <p className="text-sm text-rose-500 mt-1">{errors.title}</p>}
                                        </div>

                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Target Amount</label>
                                            <MoneyInput
                                                name="target_amount"
                                                value={data.target_amount}
                                                onChange={(e) => setData('target_amount', e.target.value)}
                                                required
                                            />
                                            {errors.target_amount && <p className="text-sm text-rose-500 mt-1">{errors.target_amount}</p>}
                                        </div>

                                        <div className="grid grid-cols-2 gap-4">
                                            <div>
                                                 <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Start Date</label>
                                                 <input
                                                    type="date"
                                                    className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                                    value={data.start_date}
                                                    onChange={(e) => setData('start_date', e.target.value)}
                                                    required
                                                />
                                            </div>
                                            <div>
                                                 <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Estimated Date</label>
                                                 <input
                                                    type="date"
                                                    className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                                    value={data.estimated_date}
                                                    onChange={(e) => setData('estimated_date', e.target.value)}
                                                />
                                            </div>
                                        </div>

                                        {editingGoal && (
                                             <div>
                                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">Status</label>
                                                <select
                                                    className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 dark:bg-slate-900 dark:border-slate-700 dark:text-white"
                                                    value={data.status}
                                                    onChange={(e) => setData('status', e.target.value)}
                                                >
                                                    <option value="active">Active</option>
                                                    <option value="completed">Completed</option>
                                                    <option value="archived">Archived</option>
                                                </select>
                                            </div>
                                        )}

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
                                                {editingGoal ? 'Update' : 'Create'}
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
