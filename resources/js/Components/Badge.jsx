export default function Badge({ children, color = 'emerald' }) {
    const colorClasses = {
        emerald: 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-300',
        amber: 'bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-300',
        rose: 'bg-rose-100 text-rose-800 dark:bg-rose-900 dark:text-rose-300',
        slate: 'bg-slate-100 text-slate-800 dark:bg-slate-700 dark:text-slate-300',
    };

    return (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${colorClasses[color] || colorClasses.emerald}`}>
            {children}
        </span>
    );
}
