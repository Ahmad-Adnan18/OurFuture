import { Head, Link } from '@inertiajs/react';

export default function Welcome({ auth, laravelVersion, phpVersion }) {
    return (
        <div className="min-h-screen bg-slate-100 dark:bg-slate-900 flex flex-col items-center justify-center">
            <Head title="Welcome" />
            <h1 className="text-4xl text-emerald-600 font-bold mb-8">OurFuture SaaS</h1>
            <div className="bg-white dark:bg-slate-800 p-8 rounded-lg shadow-lg">
                <p className="mb-4 text-slate-600 dark:text-slate-300">Welcome to your couple finance app.</p>
                <div className="flex gap-4">
                     <Link href={route('login')} className="px-4 py-2 bg-emerald-600 text-white rounded hover:bg-emerald-700">Log in</Link>
                     <Link href={route('register')} className="px-4 py-2 bg-slate-200 text-slate-800 rounded hover:bg-slate-300">Register</Link>
                </div>
            </div>
        </div>
    );
}
