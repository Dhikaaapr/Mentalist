<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ChatController extends Controller
{
    /**
     * Get list of conversations (chat list).
     * Returns users that have confirmed bookings with the authenticated user.
     */
    public function index()
    {
        $user = Auth::user();

        // Get confirmed bookings where user is either client or counselor
        $confirmedBookings = Booking::where('status', 'confirmed')
            ->where(function ($query) use ($user) {
                $query->where('user_id', $user->id)
                      ->orWhere('counselor_id', $user->id);
            })
            ->with(['user', 'counselor', 'counselor.counselorProfile'])
            ->orderBy('booking_date', 'desc')
            ->orderBy('booking_time', 'desc')
            ->get();

        // Build conversation list
        $conversations = [];
        foreach ($confirmedBookings as $booking) {
            // Determine the other party in the conversation
            $isUserClient = $booking->user_id == $user->id;
            $otherUser = $isUserClient ? $booking->counselor : $booking->user;

            // Get last message for this booking
            $lastMessage = Message::where('booking_id', $booking->id)
                ->orderBy('created_at', 'desc')
                ->first();

            // Count unread messages
            $unreadCount = Message::where('booking_id', $booking->id)
                ->where('recipient_id', $user->id)
                ->where('is_read', false)
                ->count();

            $conversations[] = [
                'booking_id' => $booking->id,
                'other_user' => [
                    'id' => $otherUser->id,
                    'name' => $otherUser->name,
                    'picture' => $otherUser->picture,
                ],
                'scheduled_at' => $booking->scheduled_at ? $booking->scheduled_at->toIso8601String() : null,
                'last_message' => $lastMessage ? [
                    'content' => $lastMessage->content,
                    'created_at' => $lastMessage->created_at,
                    'is_mine' => $lastMessage->sender_id == $user->id,
                ] : null,
                'unread_count' => $unreadCount,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $conversations,
        ]);
    }

    /**
     * Get messages for a specific booking/conversation.
     */
    public function messages($bookingId)
    {
        $user = Auth::user();

        // Validate user is part of this booking
        $booking = Booking::where('id', $bookingId)
            ->where('status', 'confirmed')
            ->where(function ($query) use ($user) {
                $query->where('user_id', $user->id)
                      ->orWhere('counselor_id', $user->id);
            })
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan atau belum dikonfirmasi',
            ], 404);
        }

        // Get messages for this booking
        $messages = Message::where('booking_id', $bookingId)
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) use ($user) {
                return [
                    'id' => $message->id,
                    'content' => $message->content,
                    'message_type' => $message->message_type,
                    'is_mine' => $message->sender_id == $user->id,
                    'is_read' => $message->is_read,
                    'file_url' => $message->file_url,
                    'file_name' => $message->file_name,
                    'created_at' => $message->created_at,
                ];
            });

        // Mark received messages as read
        try {
            Message::where('booking_id', $bookingId)
                ->where('recipient_id', $user->id)
                ->where('is_read', false)
                ->update([
                    'is_read' => true,
                    'read_at' => now(),
                ]);
        } catch (\Exception $e) {
            // Log error but don't fail the request
            \Illuminate\Support\Facades\Log::error('Failed to mark messages as read: ' . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Send a message.
     */
    public function sendMessage(Request $request, $bookingId)
    {
        $user = Auth::user();

        $request->validate([
            'content' => 'required|string|max:5000',
            'message_type' => 'nullable|in:text,image,file,audio',
        ]);

        // Validate user is part of this booking
        $booking = Booking::where('id', $bookingId)
            ->where('status', 'confirmed')
            ->where(function ($query) use ($user) {
                $query->where('user_id', $user->id)
                      ->orWhere('counselor_id', $user->id);
            })
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan atau belum dikonfirmasi',
            ], 404);
        }

        // Determine recipient
        $recipientId = $booking->user_id == $user->id
            ? $booking->counselor_id
            : $booking->user_id;

        \Illuminate\Support\Facades\Log::info("Chat Send: Sender {$user->id}, Recipient {$recipientId}, Booking {$bookingId}");

        // Create message
        $message = Message::create([
            'sender_id' => $user->id,
            'recipient_id' => $recipientId,
            'booking_id' => $bookingId,
            'content' => $request->input('content'),
            'message_type' => $request->input('message_type', 'text'),
            'is_read' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pesan terkirim',
            'data' => [
                'id' => $message->id,
                'content' => $message->content,
                'message_type' => $message->message_type,
                'is_mine' => true,
                'created_at' => $message->created_at,
            ],
        ], 201);
    }
}
