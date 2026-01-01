import { useForm, Head } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import Card from '@/Components/Card';

export default function Create({ auth }) {
    const { data, setData, post, processing, errors } = useForm({
        name: '',
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('teams.store'));
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">Create Team</h2>}
        >
            <Head title="Create Team" />

            <div className="max-w-2xl mx-auto">
                <Card>
                    <div className="mb-4">
                        <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100">Team Details</h3>
                        <p className="text-sm text-slate-600 dark:text-slate-400">Create a new team to collaborate with others on projects.</p>
                    </div>

                    <form onSubmit={submit}>
                        <div className="mb-4">
                            <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Team Name</label>
                            <input
                                type="text"
                                className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                value={data.name}
                                onChange={(e) => setData('name', e.target.value)}
                                autoFocus
                            />
                            {errors.name && <div className="text-rose-500 text-sm mt-1">{errors.name}</div>}
                        </div>

                        <div className="flex items-center justify-end">
                             <button
                                className="inline-flex items-center px-4 py-2 bg-emerald-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-emerald-700 focus:bg-emerald-700 active:bg-emerald-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition ease-in-out duration-150 disabled:opacity-25"
                                disabled={processing}
                            >
                                Create
                            </button>
                        </div>
                    </form>
                </Card>
            </div>
        </AuthenticatedLayout>
    );
}
