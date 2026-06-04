package dev.jahidhasanco.bmicalculator.data.repository

import android.content.Context
import com.google.gson.Gson
import dev.jahidhasanco.bmicalculator.data.model.UserProfile
import dev.jahidhasanco.bmicalculator.data.model.BMIRecord
import java.io.File
import java.util.Date

class UserProfileRepository(private val context: Context) {
    private val gson = Gson()
    private val sharedPreferences = context.getSharedPreferences("user_profile", Context.MODE_PRIVATE)
    private val userProfileFile = File(context.filesDir, "user_profile.json")

    fun saveUserProfile(userProfile: UserProfile) {
        val json = gson.toJson(userProfile)
        sharedPreferences.edit().putString("user_profile", json).apply()
    }

    fun getUserProfile(): UserProfile? {
        val json = sharedPreferences.getString("user_profile", null)
        return json?.let { gson.fromJson(it, UserProfile::class.java) }
    }

    fun addBMIRecord(userId: String, record: BMIRecord) {
        val currentProfile = getUserProfile()
        if (currentProfile != null && currentProfile.userId == userId) {
            val updatedProfile = currentProfile.copy(
                bmiHistory = currentProfile.bmiHistory + record
            )
            saveUserProfile(updatedProfile)
        }
    }

    fun getBMIHistory(userId: String): List<BMIRecord> {
        return getUserProfile()?.bmiHistory ?: emptyList()
    }
} 