export default function ProgressBar({ percent, color = 'emerald' }) {
    // Ensuring percent is between 0 and 100
    const validPercent = Math.min(Math.max(percent, 0), 100);

    const colorClasses = {
        emerald: 'bg-emerald-600',
        amber: 'bg-amber-500', 
        rose: 'bg-rose-500',
        slate: 'bg-slate-500',
    };

    return (
        <div className="w-full bg-slate-200 rounded-full h-2.5 dark:bg-slate-700">
            <div 
                className={`h-2.5 rounded-full transition-all duration-500 ease-out ${colorClasses[color] || colorClasses.emerald}`} 
                style={{ width: `${validPercent}%` }}
            ></div>
        </div>
    );
}
