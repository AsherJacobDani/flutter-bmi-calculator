package dev.jahidhasanco.bmicalculator.presentation.activity

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ShareCompat
import androidx.core.content.ContextCompat
import androidx.core.view.drawToBitmap
import androidx.core.view.setPadding
import androidx.databinding.DataBindingUtil
import dev.jahidhasanco.bmicalculator.R
import dev.jahidhasanco.bmicalculator.databinding.ActivityResultBinding
import dev.jahidhasanco.bmicalculator.utils.displayToast
import dev.jahidhasanco.bmicalculator.utils.saveBitmap

class ResultActivity : AppCompatActivity() {

    private lateinit var binding: ActivityResultBinding
    private val _binding get() = binding

    private var result: Double = 0.0

    private val requestLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) shareImage() else showErrorDialog()
        }

    private fun showErrorDialog() {
        displayToast("Please allow External Storage Read and Write Permissions.")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_result)

        result = intent.getDoubleExtra("bmi", 0.0)

        showResult()
        animationView()

        _binding.reloadBtn.setOnClickListener {
            backPreviousPage()
        }

        _binding.deleteBtn.setOnClickListener {
            backPreviousPage()
        }

        _binding.shareBtn.setOnClickListener {
            shareImage()
        }
    }

    private fun shareImage() {
        if (!isStoragePermissionGranted()) {
            requestLauncher.launch(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            return
        }

        val imageURI = _binding.detailView.drawToBitmap().let { bitmap ->
            saveBitmap(this, bitmap)
        } ?: run {
            displayToast("Error occurred!")
            return
        }

        val intent = ShareCompat.IntentBuilder(this)
            .setType("image/jpeg")
            .setStream(imageURI)
            .intent

        startActivity(Intent.createChooser(intent, null))
    }

    private fun isStoragePermissionGranted(): Boolean = ContextCompat.checkSelfPermission(
        this,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    ) == PackageManager.PERMISSION_GRANTED

    private fun backPreviousPage() {
        animationViewUp()
        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, 600)
    }

    private fun animationView() {
        _binding.apply {
            deskImage.translationY = 100f
            resultText.translationY = 40f
            bmiText.translationY = 50f
            bmiTextNormal.translationY = 50f
            deleteBtn.translationY = 70f
            reloadCardView.translationY = 70f
            shareBtn.translationY = 70f

            deskImage.alpha = 0f
            resultText.alpha = 0f
            bmiText.alpha = 0f
            bmiTextNormal.alpha = 0f
            deleteBtn.alpha = 0f
            reloadCardView.alpha = 0f
            shareBtn.alpha = 0f

            deskImage.setPadding(100)

            deskImage.animate().translationY(0f).alpha(1f).setDuration(500).setStartDelay(300).start()
            deskImage.setPadding(0)
            resultText.animate().translationY(0f).alpha(1f).setDuration(500).setStartDelay(500).start()
            bmiText.animate().translationY(0f).alpha(1f).setDuration(500).setStartDelay(450).start()
            bmiTextNormal.animate().translationY(0f).alpha(.3f).setDuration(500).setStartDelay(500).start()
            deleteBtn.animate().translationY(0f).alpha(.3f).setDuration(500).setStartDelay(600).start()
            reloadCardView.animate().translationY(0f).alpha(1f).setDuration(500).setStartDelay(750).start()
            shareBtn.animate().translationY(0f).alpha(.3f).setDuration(500).setStartDelay(900).start()
        }
    }

    private fun animationViewUp() {
        _binding.apply {
            textView.animate().translationY(0f).alpha(0f).setDuration(500).setStartDelay(0).start()
            deskImage.animate().translationY(-250f).alpha(0f).setDuration(500).setStartDelay(0).start()
            resultText.animate().translationY(-250f).alpha(0f).setDuration(500).setStartDelay(50).start()
            bmiText.animate().translationY(-250f).alpha(0f).setDuration(500).setStartDelay(100).start()
            bmiTextNormal.animate().translationY(-250f).alpha(0f).setDuration(500).setStartDelay(150).start()
            deleteBtn.animate().translationY(-250f).alpha(0f).setDuration(300).setStartDelay(200).start()
            reloadCardView.animate().translationY(-250f).alpha(0f).setDuration(300).setStartDelay(250).start()
            shareBtn.animate().translationY(-250f).alpha(0f).setDuration(300).setStartDelay(300).start()
        }
    }

    @SuppressLint("SetTextI18n")
    private fun showResult() {
        val solution = String.format("%.1f", result)
        _binding.resultText.text = solution
        _binding.bmiText.apply {
            text = when {
                result < 18.5 -> "You are Under Weight"
                result < 24.9 -> "You are Healthy"
                result < 30 -> "You are Overweight"
                else -> "You are Suffering from Obesity"
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        backPreviousPage()
    }
}
