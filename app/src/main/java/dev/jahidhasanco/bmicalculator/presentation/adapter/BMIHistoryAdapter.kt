package dev.jahidhasanco.bmicalculator.presentation.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import dev.jahidhasanco.bmicalculator.data.model.BMIRecord
import dev.jahidhasanco.bmicalculator.databinding.ItemBmiHistoryBinding
import java.text.SimpleDateFormat
import java.util.Locale

class BMIHistoryAdapter : ListAdapter<BMIRecord, BMIHistoryAdapter.BMIHistoryViewHolder>(BMIRecordDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BMIHistoryViewHolder {
        val binding = ItemBmiHistoryBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return BMIHistoryViewHolder(binding)
    }

    override fun onBindViewHolder(holder: BMIHistoryViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class BMIHistoryViewHolder(
        private val binding: ItemBmiHistoryBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        private val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())

        fun bind(record: BMIRecord) {
            binding.apply {
                tvDate.text = dateFormat.format(record.date)
                tvWeight.text = String.format("%.1f kg", record.weight)
                tvHeight.text = String.format("%.1f cm", record.height)
                tvBmi.text = String.format("%.1f", record.bmi)
                tvCategory.text = record.category
            }
        }
    }

    private class BMIRecordDiffCallback : DiffUtil.ItemCallback<BMIRecord>() {
        override fun areItemsTheSame(oldItem: BMIRecord, newItem: BMIRecord): Boolean {
            return oldItem.date == newItem.date
        }

        override fun areContentsTheSame(oldItem: BMIRecord, newItem: BMIRecord): Boolean {
            return oldItem == newItem
        }
    }
} 