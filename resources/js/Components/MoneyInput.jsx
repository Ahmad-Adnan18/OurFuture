import { NumericFormat } from 'react-number-format';

export default function MoneyInput({ value, onChange, placeholder = 'Rp 0', className = '', required = false, name }) {
    return (
        <NumericFormat
            value={value}
            onValueChange={(values) => {
                onChange({ target: { name: name, value: values.floatValue } });
            }}
            thousandSeparator="."
            decimalSeparator=","
            prefix="Rp "
            placeholder={placeholder}
            className={`border-slate-300 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 focus:border-emerald-500 focus:ring-emerald-500 rounded-md shadow-sm ${className}`}
            required={required}
            allowNegative={false}
            inputMode="numeric"
        />
    );
}
