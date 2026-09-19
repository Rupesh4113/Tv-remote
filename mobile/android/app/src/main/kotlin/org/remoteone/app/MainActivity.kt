package org.remoteone.app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.remoteone.app.ir.ConsumerIrBridge

class MainActivity: FlutterActivity() {
    private val IR_CHANNEL = "org.remoteone.app/ir"
    private lateinit var irBridge: ConsumerIrBridge

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        irBridge = ConsumerIrBridge(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IR_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasIrEmitter" -> {
                    result.success(irBridge.hasIrEmitter())
                }
                "getCarrierFrequencies" -> {
                    result.success(irBridge.getCarrierFrequencies())
                }
                "transmit" -> {
                    val frequency = call.argument<Int>("frequency") ?: 38000
                    val patternList = call.argument<List<Int>>("pattern")
                    if (patternList == null) {
                        result.error("INVALID_ARGUMENT", "Missing pattern array", null)
                        return@setMethodCallHandler
                    }
                    val pattern = patternList.toIntArray()
                    val success = irBridge.transmit(frequency, pattern)
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
