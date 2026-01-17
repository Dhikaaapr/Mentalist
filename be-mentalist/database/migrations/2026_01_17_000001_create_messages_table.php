<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Skip if table already exists
        if (Schema::hasTable('messages')) {
            return;
        }
        
        Schema::create('messages', function (Blueprint $table) {
            // UUID primary key
            $table->uuid('id')->primary();
            
            // Foreign keys
            $table->foreignUuid('sender_id')->constrained('users')->onDelete('cascade');
            $table->foreignUuid('recipient_id')->constrained('users')->onDelete('cascade');
            $table->foreignUuid('booking_id')->constrained('bookings')->onDelete('cascade');
            
            // Message content
            $table->text('content');
            $table->enum('message_type', ['text', 'image', 'file', 'audio'])->default('text');
            
            // Read status
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            
            // File attachments (optional)
            $table->string('file_url')->nullable();
            $table->string('file_name')->nullable();
            $table->unsignedInteger('file_size')->nullable();
            $table->string('mime_type')->nullable();
            
            // Edit tracking
            $table->timestamp('edited_at')->nullable();
            
            // Timestamps and soft deletes
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes for faster queries
            $table->index(['booking_id', 'created_at']);
            $table->index(['recipient_id', 'is_read']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
