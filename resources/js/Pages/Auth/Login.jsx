import { useEffect } from 'react';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

export default function Login({ status, canResetPassword }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    useEffect(() => {
        return () => {
            reset('password');
        };
    }, []);

    const submit = (e) => {
        e.preventDefault();
        post(route('login'));
    };

    return (
        <GuestLayout>
            <Head title="Log in" />

            <div className="mb-6 text-center">
                <h2 className="text-2xl font-bold text-slate-800 dark:text-white">Welcome Back</h2>
                <p className="text-slate-500 dark:text-slate-400 mt-2 text-sm">Please sign in to your account</p>
            </div>

            {status && <div className="mb-4 font-medium text-sm text-green-600 p-3 bg-green-50 rounded-lg border border-green-100">{status}</div>}

            <form onSubmit={submit} className="space-y-5">
                <div>
                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300 mb-1">Email Address</label>
                    <input
                        type="email"
                        className="w-full px-4 py-2 border border-slate-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white dark:bg-slate-700 text-slate-900 dark:text-white transition-colors"
                        value={data.email}
                        autoComplete="username"
                        onChange={(e) => setData('email', e.target.value)}
                        placeholder="you@example.com"
                        required
                    />
                    {errors.email && <div className="text-rose-500 text-sm mt-1">{errors.email}</div>}
                </div>

                <div>
                    <div className="flex justify-between items-center mb-1">
                        <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Password</label>
                        {canResetPassword && (
                            <Link
                                href={route('password.request')}
                                className="text-xs text-emerald-600 dark:text-emerald-400 hover:text-emerald-700 dark:hover:text-emerald-300 transition-colors"
                            >
                                Forgot password?
                            </Link>
                        )}
                    </div>
                    <input
                        type="password"
                        className="w-full px-4 py-2 border border-slate-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white dark:bg-slate-700 text-slate-900 dark:text-white transition-colors"
                        value={data.password}
                        autoComplete="current-password"
                        onChange={(e) => setData('password', e.target.value)}
                        placeholder="••••••••"
                        required
                    />
                    {errors.password && <div className="text-rose-500 text-sm mt-1">{errors.password}</div>}
                </div>

                <div className="block">
                    <label className="flex items-center cursor-pointer">
                        <input
                            type="checkbox"
                            className="rounded border-slate-300 dark:border-slate-600 text-emerald-600 shadow-sm focus:ring-emerald-500 w-4 h-4 cursor-pointer"
                            checked={data.remember}
                            onChange={(e) => setData('remember', e.target.checked)}
                        />
                        <span className="ms-2 text-sm text-slate-600 dark:text-slate-400">Remember me for 30 days</span>
                    </label>
                </div>

                <div className="pt-2">
                    <button 
                        className="w-full py-2.5 px-4 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold rounded-lg shadow-md hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-75 disabled:cursor-not-allowed" 
                        disabled={processing}
                    >
                        {processing ? 'Signing in...' : 'Sign In'}
                    </button>
                </div>

                <div className="text-center mt-6">
                    <p className="text-sm text-slate-600 dark:text-slate-400">
                        Don't have an account?{' '}
                        <Link href={route('register')} className="font-semibold text-emerald-600 dark:text-emerald-400 hover:text-emerald-700 dark:hover:text-emerald-300 transition-colors">
                            Create account
                        </Link>
                    </p>
                </div>
            </form>
        </GuestLayout>
    );
}
