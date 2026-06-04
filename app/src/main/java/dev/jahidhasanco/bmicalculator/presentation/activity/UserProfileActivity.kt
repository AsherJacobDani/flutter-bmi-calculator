package dev.jahidhasanco.bmicalculator.presentation.activity

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import dev.jahidhasanco.bmicalculator.data.model.BMIRecord
import dev.jahidhasanco.bmicalculator.data.model.UserProfile
import dev.jahidhasanco.bmicalculator.data.repository.UserProfileRepository
import dev.jahidhasanco.bmicalculator.databinding.ActivityUserProfileBinding
import dev.jahidhasanco.bmicalculator.presentation.adapter.BMIHistoryAdapter
import java.text.SimpleDateFormat
import java.util.Locale

class UserProfileActivity : AppCompatActivity() {
    private lateinit var binding: ActivityUserProfileBinding
    private lateinit var userProfileRepository: UserProfileRepository
    private lateinit var bmiHistoryAdapter: BMIHistoryAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityUserProfileBinding.inflate(layoutInflater)
        setContentView(binding.root)

        userProfileRepository = UserProfileRepository(this)
        setupRecyclerView()
        loadUserProfile()
    }

    private fun setupRecyclerView() {
        bmiHistoryAdapter = BMIHistoryAdapter()
        binding.rvBmiHistory.apply {
            layoutManager = LinearLayoutManager(this@UserProfileActivity)
            adapter = bmiHistoryAdapter
        }
    }

    private fun loadUserProfile() {
        val userProfile = userProfileRepository.getUserProfile()
        if (userProfile != null) {
            displayUserProfile(userProfile)
        } else {
            binding.tvNoHistory.visibility = View.VISIBLE
            binding.rvBmiHistory.visibility = View.GONE
        }
    }

    private fun displayUserProfile(userProfile: UserProfile) {
        binding.tvUserName.text = userProfile.name
        binding.tvUserEmail.text = userProfile.email

        if (userProfile.bmiHistory.isEmpty()) {
            binding.tvNoHistory.visibility = View.VISIBLE
            binding.rvBmiHistory.visibility = View.GONE
        } else {
            binding.tvNoHistory.visibility = View.GONE
            binding.rvBmiHistory.visibility = View.VISIBLE
            bmiHistoryAdapter.submitList(userProfile.bmiHistory.sortedByDescending { it.date })
        }
    }
} 