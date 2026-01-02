import { useForm, Head, router } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import Card from '@/Components/Card';

export default function Show({ team, availableRoles, auth, permissions }) {
    const { data, setData, put, processing, errors, recentlySuccessful } = useForm({
        name: team.name,
    });

    const updateTeamName = (e) => {
        e.preventDefault();
        put(route('teams.update', team), {
            preserveScroll: true,
        });
    };

    // Add Member Form
    const { data: addMemberData, setData: setAddMemberData, post: addMember, processing: addMemberProcessing, errors: addMemberErrors, recentlySuccessful: addMemberSuccessful, reset: resetAddMember } = useForm({
        email: '',
        role: 'editor',
    });

    const addTeamMember = (e) => {
        e.preventDefault();
        addMember(route('team-members.store', team.id), {
            errorBag: 'addTeamMember',
            preserveScroll: true,
            onSuccess: () => {
                resetAddMember();
                alert('Invitation sent successfully! Check the log file.');
            },
            onError: (errors) => {
                console.error('Add Member Error:', errors);
                alert('Failed: ' + JSON.stringify(errors));
            }
        });
    };

    // Remove Member Form (using router directly for simple deletes)
    const removeTeamMember = (userId) => {
        if (confirm('Are you sure you want to remove this person from the team?')) {
            router.delete(route('team-members.destroy', [team, userId]), {
                preserveScroll: true,
            });
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="text-xl font-semibold leading-tight text-slate-800 dark:text-slate-200">Team Settings</h2>}
        >
            <Head title="Team Settings" />

            <div className="max-w-4xl mx-auto space-y-6">
                {/* Update Team Name */}
                <Card>
                    <div className="md:grid md:grid-cols-3 md:gap-6">
                        <div className="md:col-span-1">
                            <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100">Team Name</h3>
                            <p className="mt-1 text-sm text-slate-600 dark:text-slate-400">
                                The team's name and owner information.
                            </p>
                        </div>
                        <div className="mt-5 md:mt-0 md:col-span-2">
                            <form onSubmit={updateTeamName}>
                                <div className="mb-4">
                                    <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Team Name</label>
                                    <div className="flex items-center gap-4">
                                        <div className="flex-1">
                                             <input
                                                type="text"
                                                className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                                value={data.name}
                                                onChange={(e) => setData('name', e.target.value)}
                                                disabled={!permissions.canUpdateTeam}
                                            />
                                        </div>
                                    </div>
                                    {errors.name && <div className="text-rose-500 text-sm mt-1">{errors.name}</div>}
                                </div>

                                {permissions.canUpdateTeam && (
                                    <div className="flex items-center justify-end gap-3">
                                        {recentlySuccessful && <span className="text-sm text-slate-600 dark:text-slate-400">Saved.</span>}
                                        <button
                                            className="inline-flex items-center px-4 py-2 bg-emerald-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-emerald-700 focus:bg-emerald-700 active:bg-emerald-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition ease-in-out duration-150 disabled:opacity-25"
                                            disabled={processing}
                                        >
                                            Save
                                        </button>
                                    </div>
                                )}
                            </form>
                        </div>
                    </div>
                </Card>
                
                {/* Add Team Member */}
                {permissions.canAddTeamMembers && (
                    <Card>
                        <div className="md:grid md:grid-cols-3 md:gap-6">
                            <div className="md:col-span-1">
                                <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100">Add Team Member</h3>
                                <p className="mt-1 text-sm text-slate-600 dark:text-slate-400">
                                    Add a new team member to your team, allowing them to collaborate with you.
                                </p>
                            </div>
                            <div className="mt-5 md:mt-0 md:col-span-2">
                                <form onSubmit={addTeamMember}>
                                    <div className="mb-4">
                                        <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Email</label>
                                        <input
                                            type="email"
                                            className="border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm mt-1 block w-full"
                                            value={addMemberData.email}
                                            onChange={(e) => setAddMemberData('email', e.target.value)}
                                        />
                                        {addMemberErrors.email && <div className="text-rose-500 text-sm mt-1">{addMemberErrors.email}</div>}
                                    </div>

                                    <div className="mb-4">
                                        <label className="block font-medium text-sm text-slate-700 dark:text-slate-300">Role</label>
                                        <div className="mt-1 relative z-0 inline-flex shadow-sm rounded-md">
                                            {availableRoles.map((role, i) => (
                                                <button
                                                    type="button"
                                                    key={role.key}
                                                    className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium focus:z-10 focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 ${
                                                        i === 0 ? 'rounded-l-md' : ''
                                                    } ${
                                                        i === availableRoles.length - 1 ? 'rounded-r-md' : ''
                                                    } ${
                                                        i !== 0 ? '-ml-px' : ''
                                                    } ${
                                                        addMemberData.role === role.key
                                                            ? 'bg-emerald-50 border-emerald-500 text-emerald-600 z-10'
                                                            : 'bg-white border-slate-300 text-slate-700 hover:bg-slate-50'
                                                    }`}
                                                    onClick={() => setAddMemberData('role', role.key)}
                                                >
                                                    {role.name}
                                                </button>
                                            ))}
                                        </div>
                                         {addMemberErrors.role && <div className="text-rose-500 text-sm mt-1">{addMemberErrors.role}</div>}
                                    </div>

                                    <div className="flex items-center justify-end gap-3">
                                        {addMemberSuccessful && <span className="text-sm text-slate-600 dark:text-slate-400">Added.</span>}
                                        <button
                                            className="inline-flex items-center px-4 py-2 bg-emerald-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-emerald-700 focus:bg-emerald-700 active:bg-emerald-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition ease-in-out duration-150 disabled:opacity-25"
                                            disabled={addMemberProcessing}
                                        >
                                            Add
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </Card>
                )}
                
                {/* Team Members List */}
                {team.users.length > 0 && (
                     <Card>
                        <div className="md:grid md:grid-cols-3 md:gap-6">
                            <div className="md:col-span-1">
                                <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100">Team Members</h3>
                                <p className="mt-1 text-sm text-slate-600 dark:text-slate-400">
                                    All of the people that are part of this team.
                                </p>
                            </div>
                            <div className="mt-5 md:mt-0 md:col-span-2">
                                <div className="space-y-6">
                                    {team.users.map((user) => (
                                        <div key={user.id} className="flex items-center justify-between">
                                            <div className="flex items-center">
                                                <img className="w-8 h-8 rounded-full object-cover" src={user.profile_photo_url || `https://ui-avatars.com/api/?name=${user.name}&color=7F9CF5&background=EBF4FF`} alt={user.name} />
                                                <div className="ml-4 truncate">
                                                    <div className="text-sm font-medium text-slate-900 dark:text-slate-200">{user.name}</div>
                                                    <div className="text-sm text-slate-500">{user.email}</div>
                                                </div>
                                            </div>

                                            <div className="flex items-center ml-2">
                                                 {permissions.canRemoveTeamMembers && (
                                                     <button
                                                        className="cursor-pointer ml-6 text-sm text-red-500 focus:outline-none"
                                                        onClick={() => removeTeamMember(user.id)}
                                                    >
                                                        Remove
                                                    </button>
                                                 )}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </Card>
                )}

                {/* Delete Team */}
                {permissions.canDeleteTeam && !team.personal_team && (
                    <Card>
                        <div className="md:grid md:grid-cols-3 md:gap-6">
                            <div className="md:col-span-1">
                                <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100">Delete Team</h3>
                                <p className="mt-1 text-sm text-slate-600 dark:text-slate-400">
                                    Permanently delete this team.
                                </p>
                            </div>
                            <div className="mt-5 md:mt-0 md:col-span-2">
                                <div className="max-w-xl text-sm text-slate-600 dark:text-slate-400">
                                    Once a team is deleted, all of its resources and data will be permanently deleted. Before deleting this team, please download any data or information regarding this team that you wish to retain.
                                </div>

                                <div className="mt-5">
                                    <button
                                        className="inline-flex items-center px-4 py-2 bg-red-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-red-500 active:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition ease-in-out duration-150"
                                        onClick={() => {
                                             if (confirm('Are you sure you want to delete this team? Once a team is deleted, all of its resources and data will be permanently deleted.')) {
                                                router.delete(route('teams.destroy', team.id));
                                            }
                                        }}
                                    >
                                        Delete Team
                                    </button>
                                </div>
                            </div>
                        </div>
                    </Card>
                )}
            </div>
        </AuthenticatedLayout>
    );
}
