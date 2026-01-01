import { useState } from 'react';
import { Link, usePage } from '@inertiajs/react';
import Toast from '@/Components/Toast';

import Dropdown from '@/Components/Dropdown';

export default function AuthenticatedLayout({ user, header, children }) {
    const [showingNavigationDropdown, setShowingNavigationDropdown] = useState(false);
    const { url } = usePage();

    const navLinks = [
        { name: 'Dashboard', route: 'dashboard', icon: (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
                <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z" />
            </svg>
        )},
        { name: 'Transactions', route: 'transactions.index', icon: (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
                <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0l-1 3m8.5-3l1 3m0 0l.5 1.5m-.5-1.5h-9.5m0 0l-.5 1.5M9 11.25v1.5M12 9v3.75m3-6v6" />
            </svg>
        )},
        { name: 'Goals', route: 'goals.index', icon: (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
                <path strokeLinecap="round" strokeLinejoin="round" d="M3 3v1.5M3 21v-6m0 0l2.77-.693a9 9 0 016.208.682l.108.054a9 9 0 006.086.71l3.114-.732a48.524 48.524 0 01-.005-10.499l-3.11.732a9 9 0 01-6.085-.711l-.108-.054a9 9 0 00-6.208-.682L3 4.5M3 15V4.5" />
            </svg>
        )},
        { name: 'Wallet', route: 'storage.index', icon: (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
                <path strokeLinecap="round" strokeLinejoin="round" d="M21 12a2.25 2.25 0 00-2.25-2.25H15a3 3 0 11-6 0H5.25A2.25 2.25 0 003 12m18 0v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 9m18 0V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v3" />
            </svg>
        )},
    ];

    const UserMenu = () => (
        <>
            <div className="block px-4 py-2 text-xs text-slate-400">
                Manage Account
            </div>
            <Dropdown.Link href={route('profile.show')}>
                Profile
            </Dropdown.Link>

            {user.current_team_id && (
                <>
                     <div className="border-t border-slate-200 dark:border-slate-800 my-1"></div>
                    <div className="block px-4 py-2 text-xs text-slate-400">
                        Manage Team
                    </div>
                    <Dropdown.Link href={route('teams.show', user.current_team_id)}>
                        Team Settings
                    </Dropdown.Link>
                    <Dropdown.Link href={route('teams.create')}>
                        Create New Team
                    </Dropdown.Link>
                </>
            )}

            <div className="border-t border-slate-200 dark:border-slate-800 my-1"></div>
            <Dropdown.Link href={route('logout')} method="post" as="button">
                Log Out
            </Dropdown.Link>
        </>
    );

    return (
        <div className="min-h-screen bg-slate-50 dark:bg-slate-900">
            <Toast />
            {/* Desktop Sidebar */}
            <aside className="fixed inset-y-0 left-0 hidden w-64 border-r border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900 md:flex md:flex-col">
                <div className="flex h-16 items-center justify-center border-b border-slate-200 dark:border-slate-800">
                    <span className="text-xl font-bold text-emerald-600">OurFuture</span>
                </div>
                <nav className="mt-6 px-4 space-y-2 flex-1">
                    {navLinks.map((link) => (
                        <Link
                            key={link.name}
                            href={route(link.route)}
                            className={`flex items-center rounded-lg px-4 py-3 text-sm font-medium transition-colors gap-3 ${
                                route().current(link.route)
                                    ? 'bg-emerald-50 text-emerald-600 dark:bg-emerald-900/10 dark:text-emerald-500'
                                    : 'text-slate-600 hover:bg-slate-50 dark:text-slate-400 dark:hover:bg-slate-800'
                            }`}
                        >
                            {link.icon}
                            {link.name}
                        </Link>
                    ))}
                </nav>
                {/* Desktop User Dropdown (Bottom) */}
                <div className="p-4 border-t border-slate-200 dark:border-slate-800">
                    <Dropdown align="top-left" width="48">
                        <Dropdown.Trigger>
                            <button className="flex items-center gap-3 w-full rounded-lg p-2 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                                <div className="h-9 w-9 overflow-hidden rounded-full bg-slate-200 shrink-0">
                                    <img src={`https://ui-avatars.com/api/?name=${user.name}`} alt={user.name} />
                                </div>
                                <div className="flex-1 text-left">
                                    <p className="text-sm font-medium text-slate-700 dark:text-slate-200 truncate">{user.name}</p>
                                    <p className="text-xs text-slate-500 truncate">{user.email}</p>
                                </div>
                                <svg className="w-5 h-5 text-slate-400" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 15L12 18.75 15.75 15m-7.5-6L12 5.25 15.75 9" />
                                </svg>
                            </button>
                        </Dropdown.Trigger>
                        <Dropdown.Content>
                            <UserMenu />
                        </Dropdown.Content>
                    </Dropdown>
                </div>
            </aside>

            {/* Mobile Header */}
            <header className="sticky top-0 z-50 flex h-16 items-center justify-between border-b border-slate-200 bg-white px-4 dark:border-slate-800 dark:bg-slate-900 md:hidden">
                <span className="text-lg font-bold text-emerald-600">OurFuture</span>
                <div className="flex items-center gap-2">
                     <Dropdown align="right" width="48">
                        <Dropdown.Trigger>
                             <button className="h-8 w-8 overflow-hidden rounded-full bg-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2">
                                <img src={`https://ui-avatars.com/api/?name=${user.name}`} alt={user.name} />
                            </button>
                        </Dropdown.Trigger>
                        <Dropdown.Content>
                            <UserMenu />
                        </Dropdown.Content>
                    </Dropdown>
                </div>
            </header>

            {/* Main Content */}
            <main className="pb-24 md:ml-64 md:pb-0">
                {header && (
                    <header className="bg-white shadow dark:bg-slate-800">
                        <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">{header}</div>
                    </header>
                )}
                <div className="p-4 md:p-8">{children}</div>
            </main>

            {/* Mobile Bottom Navigation */}
            <nav className="fixed bottom-0 left-0 right-0 z-20 flex h-20 items-center justify-around border-t border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900 md:hidden pb-safe">
                {navLinks.map((link) => (
                    <Link
                        key={link.name}
                        href={route(link.route)}
                        className={`flex flex-col items-center justify-center w-16 h-full text-[10px] font-medium transition-colors ${
                            route().current(link.route)
                                ? 'text-emerald-600 dark:text-emerald-500'
                                : 'text-slate-400 dark:text-slate-500'
                        }`}
                    >
                        <div className={`p-1 rounded-full ${route().current(link.route) ? 'bg-emerald-50 dark:bg-emerald-900/20' : ''}`}>
                            {link.icon}
                        </div>
                        <span className="mt-1">{link.name}</span>
                    </Link>
                ))}
            </nav>
            
            {/* Extended FAB for Mobile Transaction - Floats above Bottom Nav */}
            <div className="fixed bottom-24 right-4 z-30 md:hidden">
                 <Link 
                    href={route('transactions.create')} 
                    className="flex items-center justify-center w-14 h-14 rounded-full bg-emerald-600 text-white shadow-lg shadow-emerald-600/30 hover:bg-emerald-700 transition-transform active:scale-95"
                 >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor" className="w-8 h-8">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                    </svg>
                 </Link>
            </div>
        </div>
    );
}
