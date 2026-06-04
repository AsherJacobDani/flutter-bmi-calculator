package dev.jahidhasanco.bmicalculator.presentation.activity

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import dev.jahidhasanco.bmicalculator.databinding.ActivityLoginBinding
import dev.jahidhasanco.bmicalculator.data.model.UserProfile
import dev.jahidhasanco.bmicalculator.data.repository.UserProfileRepository

class LoginActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoginBinding
    private lateinit var auth: FirebaseAuth
    private lateinit var userProfileRepository: UserProfileRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Correct View Binding Initialization
        binding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)
        supportActionBar?.hide() // Hide the app bar

        auth = FirebaseAuth.getInstance()
        userProfileRepository = UserProfileRepository(this)

        // Auto-login if user is already authenticated
        auth.currentUser?.let {
            navigateToMainActivity(it.email ?: "")
        }

        setupClickListeners()
    }

    private fun setupClickListeners() {
        binding.btnLogin.setOnClickListener {
            val email = binding.etEmail.text.toString()
            val password = binding.etPassword.text.toString()

            if (email.isNotEmpty() && password.isNotEmpty()) {
                loginUser(email, password)
            } else {
                Toast.makeText(this, "Please enter email and password", Toast.LENGTH_SHORT).show()
            }
        }

        binding.btnRegister.setOnClickListener {
            startActivity(Intent(this, RegisterActivity::class.java))
        }
    }

    private fun loginUser(email: String, password: String) {
        auth.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    val user = auth.currentUser
                    if (user != null) {
                        // Create or update user profile
                        val userProfile = UserProfile(
                            userId = user.uid,
                            name = user.displayName ?: "User",
                            email = user.email ?: ""
                        )
                        userProfileRepository.saveUserProfile(userProfile)

                        startActivity(Intent(this, MainActivity::class.java))
                        finish()
                    }
                } else {
                    Toast.makeText(this, "Login failed: ${task.exception?.message}", Toast.LENGTH_SHORT).show()
                }
            }
    }

    private fun navigateToMainActivity(userEmail: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            putExtra("USER_EMAIL", userEmail) // Pass user email
        }
        startActivity(intent)
        finish()
    }
}
