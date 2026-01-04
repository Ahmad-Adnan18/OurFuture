<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // SQLite doesn't support modifying enum columns directly.
        // We need to recreate the constraint for SQLite or alter for MySQL/PostgreSQL.
        
        if (DB::connection()->getDriverName() === 'sqlite') {
            // For SQLite: We need to recreate the table or use a workaround
            // The simplest workaround is to temporarily disable foreign key checks
            // and recreate the table with the new enum values.
            
            // Actually, SQLite enum is implemented as CHECK constraint.
            // We need to drop and recreate the constraint.
            
            DB::statement('PRAGMA writable_schema = ON');
            
            // Get the current table SQL and modify it
            $tableSql = DB::selectOne("SELECT sql FROM sqlite_master WHERE type='table' AND name='transactions'");
            
            if ($tableSql) {
                $sql = $tableSql->sql;
                // Replace the old enum constraint with new one including 'allocate'
                $newSql = str_replace(
                    "('deposit', 'expense', 'withdrawal', 'adjustment')",
                    "('deposit', 'expense', 'withdrawal', 'adjustment', 'allocate')",
                    $sql
                );
                
                // Can also be formatted with CHECK constraint
                $newSql = str_replace(
                    "check (\"type\" in ('deposit', 'expense', 'withdrawal', 'adjustment'))",
                    "check (\"type\" in ('deposit', 'expense', 'withdrawal', 'adjustment', 'allocate'))",
                    $newSql
                );
                
                DB::statement("UPDATE sqlite_master SET sql = ? WHERE type = 'table' AND name = 'transactions'", [$newSql]);
            }
            
            DB::statement('PRAGMA writable_schema = OFF');
            // Integrity check
            DB::statement('PRAGMA integrity_check');
        } else {
            // For MySQL/PostgreSQL: Modify the enum type
            Schema::table('transactions', function (Blueprint $table) {
                $table->enum('type', ['deposit', 'expense', 'withdrawal', 'adjustment', 'allocate'])->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Optional: Remove 'allocate' type if rolling back
        // This would require ensuring no 'allocate' transactions exist first
    }
};
