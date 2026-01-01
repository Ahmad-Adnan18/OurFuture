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

            <form onSubmit={submit}>
                <div>
                     <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Name</label>
                    <input
                         className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                        value={data.name}
                        autoComplete="name"
                        onChange={(e) => setData('name', e.target.value)}
                        required
                    />
                    {errors.name && <div className="text-rose-500 text-sm mt-1">{errors.name}</div>}
                </div>

                <div className="mt-4">
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
                        autoComplete="new-password"
                        onChange={(e) => setData('password', e.target.value)}
                        required
                    />
                     {errors.password && <div className="text-rose-500 text-sm mt-1">{errors.password}</div>}
                </div>

                <div className="mt-4">
                     <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Confirm Password</label>
                    <input
                        type="password"
                         className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                        value={data.password_confirmation}
                        autoComplete="new-password"
                        onChange={(e) => setData('password_confirmation', e.target.value)}
                        required
                    />
                     {errors.password_confirmation && <div className="text-rose-500 text-sm mt-1">{errors.password_confirmation}</div>}
                </div>

                <div className="flex items-center justify-end mt-4">
                    <Link
                        href={route('login')}
                        className="underline text-sm text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500"
                    >
                        Already registered?
                    </Link>

                    <button className="ms-4 inline-flex items-center px-4 py-2 bg-emerald-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-emerald-700 focus:bg-emerald-700 active:bg-emerald-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition ease-in-out duration-150" disabled={processing}>
                        Register
                    </button>
                </div>
            </form>
        </GuestLayout>
    );
}
