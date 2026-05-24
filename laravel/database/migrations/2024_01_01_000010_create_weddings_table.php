<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('weddings', function (Blueprint $table) {
            $table->id();
            $table->string('groom_name')->default('');
            $table->string('bride_name')->default('');
            $table->date('wedding_date')->nullable();
            $table->string('location')->default('');
            $table->decimal('total_budget', 15, 2)->default(0);
            $table->string('primary_color')->default('#FF69B4');
            $table->string('secondary_color')->default('#FFB6C1');
            $table->string('accent_color')->default('#FFD700');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weddings');
    }
};
