import { useEffect } from 'react';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

export default function Login({ status,canResetPassword }) {
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

            {status && <div className="mb-4 font-medium text-sm text-green-600">{status}</div>}

            <form onSubmit={submit}>
                <div>
                   <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Email</label>
                    <input
                        type="email"
                        className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                        value={data.email}
                        autoComplete="username"
                        onChange={(e) => setData('email', e.target.value)}
                        required
                    />
                    {errors.email && <div className="text-rose-500 text-sm mt-1">{errors.email}</div>}
                </div>

                <div className="mt-4">
                     <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Password</label>
                    <input
                        type="password"
                        className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                        value={data.password}
                        autoComplete="current-password"
                        onChange={(e) => setData('password', e.target.value)}
                        required
                    />
                     {errors.password && <div className="text-rose-500 text-sm mt-1">{errors.password}</div>}
                </div>

                <div className="block mt-4">
                    <label className="flex items-center">
                        <input
                            type="checkbox"
                             className="rounded border-slate-300 text-emerald-600 shadow-sm focus:ring-emerald-500"
                            checked={data.remember}
                            onChange={(e) => setData('remember', e.target.checked)}
                        />
                        <span className="ms-2 text-sm text-slate-600 dark:text-slate-400">Remember me</span>
                    </label>
                </div>

                <div className="flex items-center justify-end mt-4">
                    {canResetPassword && (
                        <Link
                            href={route('password.request')}
                            className="underline text-sm text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500"
                        >
                            Forgot your password?
                        </Link>
                    )}

                    <button className="ms-4 inline-flex items-center px-4 py-2 bg-emerald-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-emerald-700 focus:bg-emerald-700 active:bg-emerald-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition ease-in-out duration-150" disabled={processing}>
                        Log in
                    </button>
                </div>
            </form>
        </GuestLayout>
    );
}
