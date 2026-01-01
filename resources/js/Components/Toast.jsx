import { Transition } from '@headlessui/react';
import { useState, useEffect, Fragment } from 'react';
import { usePage } from '@inertiajs/react';

export default function Toast() {
    const { flash = {} } = usePage().props;
    const [show, setShow] = useState(false);
    const [message, setMessage] = useState(null);
    const [type, setType] = useState('success'); // success, error

    useEffect(() => {
        if (flash.message || flash.success || flash.error) {
            setMessage(flash.message || flash.success || flash.error);
            setType(flash.error ? 'error' : 'success');
            setShow(true);
            const timer = setTimeout(() => setShow(false), 3000);
            return () => clearTimeout(timer);
        }
    }, [flash]);

    return (
        <div
            aria-live="assertive"
            className="pointer-events-none fixed inset-0 flex items-end px-4 py-6 sm:items-start sm:p-6 z-50"
        >
            <div className="flex w-full flex-col items-center space-y-4 sm:items-end">
                <Transition
                    show={show}
                    as={Fragment}
                    enter="transform ease-out duration-300 transition"
                    enterFrom="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
                    enterTo="translate-y-0 opacity-100 sm:translate-x-0"
                    leave="transition ease-in duration-100"
                    leaveFrom="opacity-100"
                    leaveTo="opacity-0"
                >
                    <div className="pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg bg-white shadow-lg ring-1 ring-black ring-opacity-5 dark:bg-slate-800">
                        <div className="p-4">
                            <div className="flex items-start">
                                <div className="flex-shrink-0">
                                    {type === 'success' ? (
                                       <svg className="h-6 w-6 text-emerald-400" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                    ) : (
                                        <svg className="h-6 w-6 text-rose-400" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                    )}
                                </div>
                                <div className="ml-3 w-0 flex-1 pt-0.5">
                                    <p className="text-sm font-medium text-slate-900 dark:text-slate-100">
                                        {type === 'success' ? 'Success' : 'Error'}
                                    </p>
                                    <p className="mt-1 text-sm text-slate-500 dark:text-slate-400">
                                        {message}
                                    </p>
                                </div>
                                <div className="ml-4 flex flex-shrink-0">
                                    <button
                                        type="button"
                                        className="inline-flex rounded-md bg-white text-slate-400 hover:text-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 dark:bg-slate-800 dark:text-slate-500 dark:hover:text-slate-400"
                                        onClick={() => setShow(false)}
                                    >
                                        <span className="sr-only">Close</span>
                                        <svg className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                                            <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z" />
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </Transition>
            </div>
        </div>
    );
}
