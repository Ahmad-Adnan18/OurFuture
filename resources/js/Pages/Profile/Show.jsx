import { useState, useRef } from 'react';
import { useForm, Head, router } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import Card from '@/Components/Card';

export default function Show({ auth, mustVerifyEmail, status }) {
    const user = auth.user;
    
    // Update Profile Info Form
    const photoInput = useRef(null);
    const [photoPreview, setPhotoPreview] = useState(null);

    const { data: infoData, setData: setInfoData, post: postInfo, errors: infoErrors, processing: infoProcessing, recentlySuccessful: infoSuccessful, clearErrors } = useForm({
        _method: 'PUT',
        name: user.name,
        email: user.email,
        photo: null,
    });

    const submitInfo = (e) => {
        e.preventDefault();
        postInfo('/user/profile-information', {
           forceFormData: true,
           preserveScroll: true,
           onSuccess: () => clearPhotoFileInput(),
        });
    };

    const selectNewPhoto = () => {
        photoInput.current.click();
    };

    const updatePhotoPreview = () => {
        const photo = photoInput.current.files[0];

        if (!photo) return;

        setInfoData('photo', photo);

        const reader = new FileReader();

        reader.onload = (e) => {
            setPhotoPreview(e.target.result);
        };

        reader.readAsDataURL(photo);
    };

    const deletePhoto = () => {
        router.delete(route('current-user-photo.destroy'), {
            preserveScroll: true,
            onSuccess: () => {
                setPhotoPreview(null);
                clearPhotoFileInput();
            },
        });
    };

    const clearPhotoFileInput = () => {
        if (photoInput.current) {
            photoInput.current.value = null;
        }
    };

    // Update Password Form
    const { data: passData, setData: setPassData, put: updatePassword, errors: passErrors, processing: passProcessing, recentlySuccessful: passSuccessful, reset: resetPass } = useForm({
        current_password: '',
        password: '',
        password_confirmation: '',
    });

    const submitPassword = (e) => {
        e.preventDefault();
        updatePassword(route('user-password.update'), {
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
                                {/* Profile Photo */}
                                <div className="mb-6">
                                    <input
                                        type="file"
                                        className="hidden"
                                        ref={photoInput}
                                        onChange={updatePhotoPreview}
                                    />

                                    <div className="mb-2">
                                        <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Photo</label>
                                    </div>

                                    <div className="flex items-center gap-4">
                                        {/* Current Profile Photo */}
                                        {!photoPreview && (
                                            <div className="mt-2">
                                                <img
                                                    src={user.profile_photo_url}
                                                    alt={user.name}
                                                    className="rounded-full h-20 w-20 object-cover"
                                                />
                                            </div>
                                        )}

                                        {/* New Profile Photo Preview */}
                                        {photoPreview && (
                                            <div className="mt-2">
                                                <span
                                                    className="block rounded-full w-20 h-20 bg-cover bg-no-repeat bg-center"
                                                    style={{
                                                        backgroundImage: `url('${photoPreview}')`,
                                                    }}
                                                />
                                            </div>
                                        )}

                                        <div className="flex flex-col gap-2">
                                            <button
                                                type="button"
                                                className="inline-flex items-center px-4 py-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-600 rounded-md font-semibold text-xs text-slate-700 dark:text-slate-300 uppercase tracking-widest shadow-sm hover:bg-slate-50 dark:hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 disabled:opacity-25 transition ease-in-out duration-150"
                                                onClick={selectNewPhoto}
                                            >
                                                Select A New Photo
                                            </button>

                                            {user.profile_photo_path && (
                                                <button
                                                    type="button"
                                                    className="inline-flex items-center px-4 py-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-600 rounded-md font-semibold text-xs text-rose-600 dark:text-rose-400 uppercase tracking-widest shadow-sm hover:bg-slate-50 dark:hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 disabled:opacity-25 transition ease-in-out duration-150"
                                                    onClick={deletePhoto}
                                                >
                                                    Remove Photo
                                                </button>
                                            )}
                                        </div>
                                    </div>
                                    {infoErrors.photo && <div className="text-rose-500 text-sm mt-1">{infoErrors.photo}</div>}
                                </div>
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
