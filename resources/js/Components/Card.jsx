export default function Card({ children, className = '' }) {
    return (
        <div className={`bg-white dark:bg-slate-800 shadow-sm rounded-xl ${className}`}>
            <div className="p-6 text-slate-900 dark:text-slate-100">
                {children}
            </div>
        </div>
    );
}
