package org.remoteone.app.ir

import android.content.Context
import android.hardware.ConsumerIrManager
import android.os.Build
import android.util.Log

/**
 * Native Android Consumer IR Bridge
 * Encapsulates communication with the device's hardware IR blaster.
 */
class ConsumerIrBridge(private val context: Context) {

    private val TAG = "ConsumerIrBridge"
    private var irManager: ConsumerIrManager? = null

    init {
        try {
            irManager = context.getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize ConsumerIrManager: ${e.message}")
        }
    }

    /**
     * Checks if the phone hardware contains a physical IR blaster.
     * Returns false gracefully if unsupported.
     */
    fun hasIrEmitter(): Boolean {
        return try {
            irManager?.hasIrEmitter() == true
        } catch (e: Exception) {
            Log.w(TAG, "Error checking IR emitter: ${e.message}")
            false
        }
    }

    /**
     * Returns supported carrier frequency ranges (min, max in Hz).
     */
    fun getCarrierFrequencies(): List<Map<String, Int>> {
        val result = mutableListOf<Map<String, Int>>()
        try {
            irManager?.carrierFrequencies?.forEach { range ->
                result.add(
                    mapOf(
                        "minFrequency" to range.minFrequency,
                        "maxFrequency" to range.maxFrequency
                    )
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error retrieving carrier frequencies: ${e.message}")
        }
        return result
    }

    /**
     * Transmits an alternating mark/space pattern in microseconds at the specified carrier frequency.
     */
    fun transmit(carrierFrequency: Int, pattern: IntArray): Boolean {
        return try {
            if (!hasIrEmitter()) {
                Log.w(TAG, "Cannot transmit IR: Device has no IR blaster")
                return false
            }
            irManager?.transmit(carrierFrequency, pattern)
            Log.d(TAG, "Transmitted IR signal: freq=${carrierFrequency}Hz, pulses=${pattern.size}")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to transmit IR signal: ${e.message}")
            false
        }
    }
}
