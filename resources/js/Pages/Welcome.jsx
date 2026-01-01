import { Head, Link } from '@inertiajs/react';

export default function Welcome({ auth, laravelVersion, phpVersion }) {
    return (
        <div className="min-h-screen bg-gradient-to-br from-slate-50 via-emerald-50/30 to-slate-100 dark:from-slate-950 dark:via-slate-900 dark:to-slate-950 flex flex-col items-center justify-center px-4 selection:bg-emerald-500 selection:text-white">
            <Head title="Welcome" />
            <h1 className="text-5xl md:text-6xl text-transparent bg-clip-text bg-gradient-to-r from-emerald-600 to-teal-500 font-extrabold mb-10 tracking-tight text-center">
                OurFuture
            </h1>
            <div className="bg-white/70 dark:bg-slate-800/50 backdrop-blur-xl p-10 md:p-12 rounded-3xl shadow-xl shadow-slate-200/50 dark:shadow-slate-900/50 border border-white/50 dark:border-slate-700/50 max-w-md w-full text-center">
                <p className="mb-8 text-lg text-slate-600 dark:text-slate-300 leading-relaxed">
                    Welcome to your couple finance app.
                </p>
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <Link 
                        href={route('login')} 
                        className="px-8 py-3 bg-gradient-to-r from-emerald-500 to-teal-500 text-white font-semibold rounded-xl shadow-lg shadow-emerald-500/30 hover:shadow-emerald-500/50 hover:scale-[1.02] transition-all duration-300 ease-out"
                    >
                        Log in
                    </Link>
                    <Link 
                        href={route('register')} 
                        className="px-8 py-3 bg-slate-100 dark:bg-slate-700/50 text-slate-700 dark:text-slate-200 font-semibold rounded-xl border border-slate-200 dark:border-slate-600 hover:bg-slate-200 dark:hover:bg-slate-700 hover:scale-[1.02] transition-all duration-300 ease-out"
                    >
                        Register
                    </Link>
                </div>
            </div>
        </div>
    );
}
