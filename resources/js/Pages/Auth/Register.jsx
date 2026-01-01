import { useEffect } from 'react';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
    });

    useEffect(() => {
        return () => {
            reset('password', 'password_confirmation');
        };
    }, []);

    const submit = (e) => {
        e.preventDefault();
        post(route('register'));
    };

    return (
        <GuestLayout>
            <Head title="Register" />

            <div className="mb-6 text-center">
                <h2 className="text-2xl font-bold text-slate-800 dark:text-white">Create Account</h2>
                <p className="text-slate-500 dark:text-slate-400 mt-2 text-sm">Join OurFuture today</p>
            </div>

            <form onSubmit={submit} className="space-y-4">
                <div>
                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300 mb-1">Full Name</label>
                    <input
                        type="text"
                        className="w-full px-4 py-2 border border-slate-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white dark:bg-slate-700 text-slate-900 dark:text-white transition-colors"
                        value={data.name}
                        autoComplete="name"
                        onChange={(e) => setData('name', e.target.value)}
                        placeholder="John Doe"
                        required
                    />
                    {errors.name && <div className="text-rose-500 text-sm mt-1">{errors.name}</div>}
                </div>

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
                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300 mb-1">Password</label>
                    <input
                        type="password"
                        className="w-full px-4 py-2 border border-slate-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white dark:bg-slate-700 text-slate-900 dark:text-white transition-colors"
                        value={data.password}
                        autoComplete="new-password"
                        onChange={(e) => setData('password', e.target.value)}
                        placeholder="••••••••"
                        required
                    />
                    {errors.password && <div className="text-rose-500 text-sm mt-1">{errors.password}</div>}
                </div>

                <div>
                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300 mb-1">Confirm Password</label>
                    <input
                        type="password"
                        className="w-full px-4 py-2 border border-slate-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white dark:bg-slate-700 text-slate-900 dark:text-white transition-colors"
                        value={data.password_confirmation}
                        autoComplete="new-password"
                        onChange={(e) => setData('password_confirmation', e.target.value)}
                        placeholder="••••••••"
                        required
                    />
                    {errors.password_confirmation && <div className="text-rose-500 text-sm mt-1">{errors.password_confirmation}</div>}
                </div>

                <div className="pt-2">
                    <button 
                        className="w-full py-2.5 px-4 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold rounded-lg shadow-md hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-75 disabled:cursor-not-allowed" 
                        disabled={processing}
                    >
                        {processing ? 'Creating account...' : 'Create Account'}
                    </button>
                </div>

                <div className="text-center mt-6">
                    <p className="text-sm text-slate-600 dark:text-slate-400">
                        Already have an account?{' '}
                        <Link href={route('login')} className="font-semibold text-emerald-600 dark:text-emerald-400 hover:text-emerald-700 dark:hover:text-emerald-300 transition-colors">
                            Sign in
                        </Link>
                    </p>
                </div>
            </form>
        </GuestLayout>
    );
}
