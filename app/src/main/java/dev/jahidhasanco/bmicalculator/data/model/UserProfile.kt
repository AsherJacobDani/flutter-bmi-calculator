package dev.jahidhasanco.bmicalculator.data.model

import java.util.Date

data class UserProfile(
    val userId: String,
    val name: String,
    val email: String,
    val bmiHistory: List<BMIRecord> = emptyList()
)

data class BMIRecord(
    val date: Date,
    val weight: Double,
    val height: Double,
    val bmi: Double,
    val category: String
) 