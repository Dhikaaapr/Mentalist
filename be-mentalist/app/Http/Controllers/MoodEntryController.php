<?php

namespace App\Http\Controllers;

use App\Models\MoodEntry;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class MoodEntryController extends Controller
{
    /**
     * Get user mood entries (default: this week).
     */
    public function index(Request $request)
    {
        $userId = Auth::id();
        
        // Ambil mood 7 hari terakhir secara default
        $startDate = Carbon::now()->startOfWeek()->format('Y-m-d');
        $endDate = Carbon::now()->endOfWeek()->format('Y-m-d');

        $moods = MoodEntry::where('user_id', $userId)
            ->whereBetween('entry_date', [$startDate, $endDate])
            ->get();

        return response()->json([
            'success' => true,
            'data' => $moods,
            'week_range' => [
                'start' => $startDate,
                'end' => $endDate
            ]
        ]);
    }

    /**
     * Store or update today's mood.
     */
    public function store(Request $request)
    {
        $request->validate([
            'mood' => 'required|string',
            'date' => 'nullable|date', // Optional, default today
        ]);

        $userId = Auth::id();
        $date = $request->date ? Carbon::parse($request->date)->format('Y-m-d') : Carbon::now()->format('Y-m-d');

        $moodEntry = MoodEntry::updateOrCreate(
            [
                'user_id' => $userId,
                'entry_date' => $date,
            ],
            [
                'mood_label' => $request->mood,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Mood saved successfully',
            'data' => $moodEntry
        ]);
    }
}
