import { useForm, Head } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import Card from '@/Components/Card';

export default function Show({ auth, mustVerifyEmail, status }) {
    const user = auth.user;
    
    // Update Profile Info Form
    const { data: infoData, setData: setInfoData, patch: patchInfo, errors: infoErrors, processing: infoProcessing, recentlySuccessful: infoSuccessful } = useForm({
        name: user.name,
        email: user.email,
    });

    const submitInfo = (e) => {
        e.preventDefault();
        patchInfo(route('profile.update'));
    };

    // Update Password Form
    const { data: passData, setData: setPassData, put: updatePassword, errors: passErrors, processing: passProcessing, recentlySuccessful: passSuccessful, reset: resetPass } = useForm({
        current_password: '',
        password: '',
        password_confirmation: '',
    });

    const submitPassword = (e) => {
        e.preventDefault();
        updatePassword(route('password.update'), {
            preserveScroll: true,
            onSuccess: () => resetPass(),
            onError: () => {
                if (passErrors.password) {
                    resetPass('password', 'password_confirmation');
                }
                if (passErrors.current_password) {
                    resetPass('current_password');
                }
            },
        });
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">Profile</h2>}
        >
            <Head title="Profile" />

            <div className="max-w-4xl mx-auto space-y-6">
                {/* Update Profile Information */}
                <Card>
                    <div className="md:grid md:grid-cols-3 md:gap-6">
                        <div className="md:col-span-1">
                            <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100">Profile Information</h3>
                            <p className="mt-1 text-sm text-slate-600 dark:text-slate-400">
                                Update your account's profile information and email address.
                            </p>
                        </div>
                        <div className="mt-5 md:mt-0 md:col-span-2">
                             <form onSubmit={submitInfo}>
                                <div className="mb-4">
                                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Name</label>
                                    <input
                                        type="text"
                                        className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                        value={infoData.name}
                                        onChange={(e) => setInfoData('name', e.target.value)}
                                        required
                                    />
                                    {infoErrors.name && <div className="text-rose-500 text-sm mt-1">{infoErrors.name}</div>}
                                </div>
                                <div className="mb-4">
                                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Email</label>
                                    <input
                                        type="email"
                                        className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                        value={infoData.email}
                                        onChange={(e) => setInfoData('email', e.target.value)}
                                        required
                                    />
                                    {infoErrors.email && <div className="text-rose-500 text-sm mt-1">{infoErrors.email}</div>}
                                </div>
                                <div className="flex items-center justify-end gap-3">
                                    {infoSuccessful && <span className="text-sm text-slate-600 dark:text-slate-400">Saved.</span>}
                                    <button
                                        className="inline-flex items-center px-4 py-2 bg-emerald-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-emerald-700 focus:bg-emerald-700 active:bg-emerald-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition ease-in-out duration-150 disabled:opacity-25"
                                        disabled={infoProcessing}
                                    >
                                        Save
                                    </button>
                                </div>
                             </form>
                        </div>
                    </div>
                </Card>

                {/* Update Password */}
                <Card>
                    <div className="md:grid md:grid-cols-3 md:gap-6">
                        <div className="md:col-span-1">
                            <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100">Update Password</h3>
                            <p className="mt-1 text-sm text-slate-600 dark:text-slate-400">
                                Ensure your account is using a long, random password to stay secure.
                            </p>
                        </div>
                        <div className="mt-5 md:mt-0 md:col-span-2">
                             <form onSubmit={submitPassword}>
                                <div className="mb-4">
                                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Current Password</label>
                                    <input
                                        type="password"
                                        className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                        value={passData.current_password}
                                        onChange={(e) => setPassData('current_password', e.target.value)}
                                        autoComplete="current-password"
                                    />
                                    {passErrors.current_password && <div className="text-rose-500 text-sm mt-1">{passErrors.current_password}</div>}
                                </div>
                                <div className="mb-4">
                                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">New Password</label>
                                    <input
                                        type="password"
                                        className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                        value={passData.password}
                                        onChange={(e) => setPassData('password', e.target.value)}
                                        autoComplete="new-password"
                                    />
                                    {passErrors.password && <div className="text-rose-500 text-sm mt-1">{passErrors.password}</div>}
                                </div>
                                <div className="mb-4">
                                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Confirm Password</label>
                                    <input
                                        type="password"
                                        className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                        value={passData.password_confirmation}
                                        onChange={(e) => setPassData('password_confirmation', e.target.value)}
                                        autoComplete="new-password"
                                    />
                                    {passErrors.password_confirmation && <div className="text-rose-500 text-sm mt-1">{passErrors.password_confirmation}</div>}
                                </div>

                                <div className="flex items-center justify-end gap-3">
                                    {passSuccessful && <span className="text-sm text-slate-600 dark:text-slate-400">Saved.</span>}
                                    <button
                                        className="inline-flex items-center px-4 py-2 bg-emerald-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-emerald-700 focus:bg-emerald-700 active:bg-emerald-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition ease-in-out duration-150 disabled:opacity-25"
                                        disabled={passProcessing}
                                    >
                                        Save
                                    </button>
                                </div>
                             </form>
                        </div>
                    </div>
                </Card>
            </div>
        </AuthenticatedLayout>
    );
}
